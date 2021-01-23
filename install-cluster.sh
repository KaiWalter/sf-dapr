#!/bin/bash

# Variables
ClusterName=sf-dapr
Password=$(pwgen 20 1)
Subject=$ClusterName.$LOCATION.cloudapp.azure.com
VaultName=$ClusterName-vault
VmPassword=$(pwgen 20 1)
VmUserName=sfadminuser

if [[ ! $(az keyvault show --name $VaultName) ]]; 
then
    az keyvault create --name $VaultName --enable-rbac-authorization --enabled-for-deployment --enabled-for-template-deployment
fi

# Create secure five node Linux cluster. Creates a key vault in a resource group
# and creates a certficate in the key vault. The certificate's subject name must match 
# the domain that you use to access the Service Fabric cluster.  The certificate is downloaded locally.
az sf cluster create --cluster-name $ClusterName --cluster-size 3 --os UbuntuServer1604 \
    --certificate-output-folder ~ --certificate-password $Password --certificate-subject-name $Subject \
    --vault-name $VaultName --vault-resource-group $RESOURCE_GROUP --vm-password $VmPassword --vm-user-name $VmUserName