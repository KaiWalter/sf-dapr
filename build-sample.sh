#!/bin/bash

. ./common.sh

ClusterName=cz-kw-sf-dapr
RegistryName=$(echo $ClusterName | sed 's/-//g')reg

SamplePath=~/src/python-sdk/examples/invoke-simple
ImageTag=invoke-receiver:$AppVersion

az acr login --name $RegistryName

az acr build -t $ImageTag -r $RegistryName $SamplePath
