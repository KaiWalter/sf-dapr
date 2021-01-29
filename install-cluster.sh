#!/bin/bash

. ./common.sh

VmPassword=$(pwgen 20 1)
VmUserName=sfadminuser

az configure --defaults location=$LOCATION group=$RESOURCE_GROUP
az account set --subscription $SUBSCRIPTION_ID

bicep build ./infrastructure/sf.bicep

VaultId=$(az keyvault show --name $VaultName --query id -o tsv)

# create cluster certificate 
CertificatePolicy=$(az keyvault certificate get-default-policy | sed "s/CLIGetDefaultPolicy/$ClusterCertificateSubject/g")
az keyvault certificate create -n $(echo $ClusterCertificateSubject | sed 's/\.//g') -p "$CertificatePolicy" --vault-name $VaultName
CertificateThumbprint=$(az keyvault certificate show --vault-name $VaultName -n $(echo $ClusterCertificateSubject | sed 's/\.//g') --query x509ThumbprintHex -o tsv)
CertificateSId=$(az keyvault certificate show --vault-name $VaultName -n $(echo $ClusterCertificateSubject | sed 's/\.//g') --query sid -o tsv)

# create client certificate and download certificate locally for Explorer/sfctl authentication
CertificatePolicy=$(az keyvault certificate get-default-policy | sed "s/CLIGetDefaultPolicy/$AdminCertificateSubject/g")
az keyvault certificate create -n $(echo $AdminCertificateSubject | sed 's/\.//g') -p "$CertificatePolicy" --vault-name $VaultName
AdminCertificateThumbprint=$(az keyvault certificate show --vault-name $VaultName -n $(echo $AdminCertificateSubject | sed 's/\.//g') --query x509ThumbprintHex -o tsv)
AdminCertificateSId=$(az keyvault certificate show --vault-name $VaultName -n $(echo $AdminCertificateSubject | sed 's/\.//g') --query sid -o tsv)
AdminCertificateId=$(az keyvault certificate show --vault-name $VaultName -n $(echo $AdminCertificateSubject | sed 's/\.//g') --query id -o tsv)

if [[ -f $AdminCertificatePfxPath ]]; then rm $AdminCertificatePfxPath; fi
az keyvault secret download --vault-name $VaultName -n $AdminCertificateSubject -e base64 -f $AdminCertificatePfxPath

if [[ -f $AdminCertificatePemPath ]]; then rm $AdminCertificatePemPath; fi
openssl pkcs12 -in $AdminCertificatePfxPath -nocerts  -nodes -out $AdminCertificatePemPath -passin pass:''

if [[ -f $AdminCertificateCrtPath ]]; then rm $AdminCertificateCrtPath; fi
openssl pkcs12 -in $AdminCertificatePfxPath -clcerts -nokeys -out $AdminCertificateCrtPath -passin pass:''

# set VMSS node secrets
az keyvault secret set --vault-name $VaultName -n VmUserName --value $VmUserName
az keyvault secret set --vault-name $VaultName -n VmPassword --value $VmPassword

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
