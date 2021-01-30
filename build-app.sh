#!/bin/bash

. ./common.sh

SourcePath=./$AppName
ImageTag=$AppName:$AppVersion

az acr build -t $ImageTag -r $RegistryName $SourcePath
