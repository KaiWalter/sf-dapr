#!/bin/bash

# Variables
ClusterName=sf-dapr
Password=$(pwgen 20 1)
Subject=$ClusterName.$LOCATION.cloudapp.azure.com
VaultName=$ClusterName-vault
VmPassword=$(pwgen 20 1)
VmUserName=sfadminuser
CertPath=~/$(echo $Subject | sed 's/\.//g').pem

sfctl cluster select --endpoint https://$Subject:19080 --pem $CertPath --no-verify

# https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-quickstart-containers-linux#get-the-application-package