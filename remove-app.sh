#!/bin/bash

. ./common.sh

ClusterEndpoint=$(az sf cluster show -c $ClusterName --query managementEndpoint -o tsv)
sfctl cluster select --endpoint $ClusterEndpoint --key $AdminCertificatePemPath --cert $AdminCertificateCrtPath --no-verify

sfctl application delete --application-id $AppName
sfctl application unprovision --application-type-name $AppName --application-type-version $AppVersion
