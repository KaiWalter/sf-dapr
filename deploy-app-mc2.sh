#!/bin/bash

. ./common.sh

DeploymentFolder=./dist
AppFolder=app-mc2

if [[ -d $DeploymentFolder ]]; then rm -rf $DeploymentFolder; fi
mkdir $DeploymentFolder
cp -r ./$AppFolder $DeploymentFolder

RegistryLoginServer=$(az acr show -n $RegistryName --query loginServer -o tsv)
ImageTag=$AppName:$AppVersion

sed -i "s/<APP VERSION>/$AppVersion/g" $DeploymentFolder/$AppFolder/ApplicationManifest.xml
sed -i "s/<APP NAME>/$AppName/g" $DeploymentFolder/$AppFolder/ApplicationManifest.xml

sed -i "s/<APP VERSION>/$AppVersion/g" $DeploymentFolder/$AppFolder/Package/ServiceManifest.xml
sed -i "s/<APP NAME>/$AppName/g" $DeploymentFolder/$AppFolder/Package/ServiceManifest.xml
sed -i "s/<LOGIN SERVER>/$RegistryLoginServer/g" $DeploymentFolder/$AppFolder/Package/ServiceManifest.xml
sed -i "s/<IMAGE TAG>/$ImageTag/g" $DeploymentFolder/$AppFolder/Package/ServiceManifest.xml

sed -i "s/<NAMESPACE NAME>/$ServiceBusNamespace/g" $DeploymentFolder/$AppFolder/Package/CodeDapr/pubsub.yaml

ClusterEndpoint=$(az sf cluster show -c $ClusterName --query managementEndpoint -o tsv)
sfctl cluster select --endpoint $ClusterEndpoint --key $AdminCertificatePemPath --cert $AdminCertificateCrtPath --no-verify

sfctl application upload --path $DeploymentFolder/$AppFolder --show-progress
sfctl application provision --application-type-build-path $AppFolder
sfctl application create --app-name fabric:/$AppName --app-type $AppName --app-version $AppVersion

