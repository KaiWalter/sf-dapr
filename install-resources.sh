#!/bin/bash

. ./common.sh

Password=$(pwgen 20 1)
RegistryName=$(echo $ClusterName | sed 's/-//g')reg
VmPassword=$(pwgen 20 1)
VmUserName=sfadminuser

az configure --defaults location=$LOCATION group=$RESOURCE_GROUP
az account set --subscription $SUBSCRIPTION_ID

if [[ ! $(az keyvault show --name $VaultName) ]]; 
then
    az keyvault create --name $VaultName --enable-rbac-authorization --enabled-for-deployment --enabled-for-template-deployment
fi

if [[ ! $(az acr show --name $RegistryName) ]]; 
then
    az acr create --name $RegistryName --admin-enabled --sku basic
fi

if [[ ! $(az servicebus namespace show --name $ServiceBusNamespace) ]]; 
then
    az servicebus namespace create -n $ServiceBusNamespace
fi

az keyvault secret set --vault-name $VaultName -n CertificatePassword --value $Password
az keyvault secret set --vault-name $VaultName -n VmUserName --value $VmUserName
az keyvault secret set --vault-name $VaultName -n VmPassword --value $VmPassword

az sf cluster create --cluster-name $ClusterName --cluster-size 3 --os UbuntuServer1604 \
    --certificate-output-folder ~ --certificate-password $Password --certificate-subject-name $Subject \
    --vault-name $VaultName --vault-resource-group $RESOURCE_GROUP --vm-password $VmPassword --vm-user-name $VmUserName

VmssName=$(az sf cluster show --cluster-name $ClusterName --query nodeTypes[0].name -o tsv)
az vmss identity assign -n $VmssName
AcrResourceId=$(az acr show -n $RegistryName --query id -o tsv)
VmssIdentity=$(az vmss show -n $VmssName --query identity.principalId -o tsv)
az role assignment create --assignee $VmssIdentity --role AcrPull --scope $AcrResourceId

SbResourceId=$(az servicebus namespace show -n $ServiceBusNamespace --query id -o tsv)

az role assignment create --role "Azure Service Bus Data Receiver" --assignee $VmssIdentity --scope $SbResourceId
az role assignment create --role "Azure Service Bus Data Sender" --assignee $VmssIdentity --scope $SbResourceId