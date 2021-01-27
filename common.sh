#!/bin/bash

# variables
ClusterName=$RESOURCE_PREFIX-sf-dapr
ServiceBusNamespace=$RESOURCE_PREFIX-sf-dapr
Subject=$ClusterName.$LOCATION.cloudapp.azure.com
VaultName=$ClusterName-vault
RegistryName=$(echo $ClusterName | sed 's/-//g')reg
CertPath=~/$(echo $Subject | sed 's/\.//g').pem
AppVersion=20210127.1

# environment variables
export PYTHONWARNINGS="ignore:Unverified HTTPS request"