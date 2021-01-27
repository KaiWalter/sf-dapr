#!/bin/bash

. ./common.sh

DeploymentFolder=./deploy

if [[ -d $DeploymentFolder ]]; then rm -rf $DeploymentFolder; fi
mkdir $DeploymentFolder
cp -r ./app $DeploymentFolder

RegistryLoginServer=$(az acr show -n $RegistryName --query loginServer -o tsv)
ImageTag=$AppName:$AppVersion

sed -i "s/<APP VERSION>/$AppVersion/g" $DeploymentFolder/app/ApplicationManifest.xml
sed -i "s/<APP NAME>/$AppName/g" $DeploymentFolder/app/ApplicationManifest.xml
sed -i "s/<APP VERSION>/$AppVersion/g" $DeploymentFolder/app/Package/ServiceManifest.xml
sed -i "s/<APP NAME>/$AppName/g" $DeploymentFolder/app/Package/ServiceManifest.xml
sed -i "s/<LOGIN SERVER>/$RegistryLoginServer/g" $DeploymentFolder/app/Package/ServiceManifest.xml
sed -i "s/<IMAGE TAG>/$ImageTag/g" $DeploymentFolder/app/Package/ServiceManifest.xml
sed -i "s/<NAMESPACE NAME>/$ServiceBusNamespace/g" $DeploymentFolder/app/Package/CodeDapr/pubsub.yaml


sfctl cluster select --endpoint https://$Subject:19080 --pem $CertPath --no-verify
sfctl application upload --path $DeploymentFolder/app --show-progress
sfctl application provision --application-type-build-path app
sfctl application create --app-name fabric:/$AppName --app-type $AppName --app-version $AppVersion

