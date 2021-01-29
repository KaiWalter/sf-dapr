#!/bin/bash

. ./common.sh

az configure --defaults location=$LOCATION group=$RESOURCE_GROUP
az account set --subscription $SUBSCRIPTION_ID

if [[ ! $(az keyvault show --name $VaultName) ]]
then
    az keyvault create --name $VaultName --enable-rbac-authorization --enabled-for-deployment --enabled-for-template-deployment
fi

if [[ ! $(az acr show --name $RegistryName) ]]
then
    az acr create --name $RegistryName --admin-enabled --sku basic
fi

if [[ ! $(az servicebus namespace show --name $ServiceBusNamespace) ]]
then
    az servicebus namespace create -n $ServiceBusNamespace
fi

if [[ ! $(az sf cluster show --cluster-name $ClusterName) ]]
then
    . ./install-cluster.sh
fi

VmssName=$(az sf cluster show --cluster-name $ClusterName --query nodeTypes[0].name -o tsv)
az vmss identity assign -n $VmssName
AcrResourceId=$(az acr show -n $RegistryName --query id -o tsv)
VmssIdentity=$(az vmss show -n $VmssName --query identity.principalId -o tsv)
az role assignment create --assignee $VmssIdentity --role AcrPull --scope $AcrResourceId

SbResourceId=$(az servicebus namespace show -n $ServiceBusNamespace --query id -o tsv)

az role assignment create --role "Azure Service Bus Data Receiver" --assignee $VmssIdentity --scope $SbResourceId
az role assignment create --role "Azure Service Bus Data Sender" --assignee $VmssIdentity --scope $SbResourceId