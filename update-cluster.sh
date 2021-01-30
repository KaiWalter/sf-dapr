#!/bin/bash

. ./common.sh

az configure --defaults location=$LOCATION group=$RESOURCE_GROUP
az account set --subscription $SUBSCRIPTION_ID

bicep build ./infrastructure/sf.bicep

VaultId=$(az keyvault show --name $VaultName --query id -o tsv)

# get certificates info
CertificateThumbprint=$(az keyvault certificate show --vault-name $VaultName -n $(echo $ClusterCertificateSubject | sed 's/\.//g') --query x509ThumbprintHex -o tsv)
CertificateSId=$(az keyvault certificate show --vault-name $VaultName -n $(echo $ClusterCertificateSubject | sed 's/\.//g') --query sid -o tsv)

AdminCertificateThumbprint=$(az keyvault certificate show --vault-name $VaultName -n $(echo $AdminCertificateSubject | sed 's/\.//g') --query x509ThumbprintHex -o tsv)
AdminCertificateSId=$(az keyvault certificate show --vault-name $VaultName -n $(echo $AdminCertificateSubject | sed 's/\.//g') --query sid -o tsv)

# get VMSS node secrets
VmUserName=$(az keyvault secret show --vault-name $VaultName -n VmUserName --query value -o tsv)
VmPassword=$(az keyvault secret show --vault-name $VaultName -n VmPassword --query value -o tsv)

# reference to (current host) JumpVm subnet
JumpVmNicId=$(az vm show --name $(hostname) --query networkProfile.networkInterfaces[0].id -o tsv)
SubNetId=$(az network nic show --ids $JumpVmNicId --query ipConfigurations[0].subnet.id -o tsv)
SubNetPrefix=$(az network vnet subnet show --ids $SubNetId --query addressPrefix -o tsv)

az deployment group create \
  --name sf$(date +%Y%M%d%H%m%s) \
  --resource-group $RESOURCE_GROUP \
  --verbose \
  --template-file ./infrastructure/sf.json \
  --parameters clusterLocation=$LOCATION \
    clusterName=$ClusterName \
    adminUserName=$VmUserName \
    adminPassword=$VmPassword \
    sourceVaultValue=$VaultId \
    certificateThumbprint=$CertificateThumbprint \
    certificateUrlValue=$CertificateSId \
    adminCertificateThumbprint=$AdminCertificateThumbprint \
    adminCertificateUrlValue=$AdminCertificateSId \
    subNetId=$SubNetId \
    subNetPrefix=$SubNetPrefix
