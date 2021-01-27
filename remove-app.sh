#!/bin/bash

. ./common.sh

sfctl cluster select --endpoint https://$Subject:19080 --pem $CertPath --no-verify

sfctl application delete --application-id $AppName
sfctl application unprovision --application-type-name $AppName --application-type-version $AppVersion
