#!/bin/bash

. ./common.sh

sfctl cluster select --endpoint https://$Subject:19080 --pem $CertPath --no-verify

sfctl application delete --application-id invoke-receiver
sfctl application unprovision --application-type-name invoke-receiver --application-type-version $AppVersion
