#!/bin/bash

# Variables
ClusterName=cz-kw-sf-dapr
Subject=$ClusterName.$LOCATION.cloudapp.azure.com
CertPath=~/$(echo $Subject | sed 's/\.//g').pem

sfctl cluster select --endpoint https://$Subject:19080 --pem $CertPath --no-verify

# https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-quickstart-containers-linux#get-the-application-package