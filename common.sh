#!/bin/bash

# variables
ClusterName=$RESOURCE_PREFIX-sf-dapr
ServiceBusNamespace=$RESOURCE_PREFIX-sf-dapr
ClusterCertificateSubject=$ClusterName.$LOCATION.cloudapp.azure.com
AdminCertificateSubject="Cluster-Admin-Client-$ClusterName-$LOCATION"
VaultName=$ClusterName-vault
RegistryName=$(echo $ClusterName | sed 's/-//g')reg
ClusterCertificatePath=.cert/$(echo $ClusterCertificateSubject | sed 's/\.//g').pem
AdminCertificatePfxPath=.cert/$(echo $AdminCertificateSubject | sed 's/\.//g').pfx
AdminCertificatePemPath=.cert/$(echo $AdminCertificateSubject | sed 's/\.//g').pem
AdminCertificateCrtPath=.cert/$(echo $AdminCertificateSubject | sed 's/\.//g').crt
AppName=simple-server
AppVersion=20210128.2

if [[ ! -d .cert ]]; then mkdir .cert; fi


# environment variables
export PYTHONWARNINGS="ignore:Unverified HTTPS request"