#!/bin/bash

. ./common.sh

SourcePath=./invoke-simple
ImageTag=invoke-receiver:$AppVersion

az acr build -t $ImageTag -r $RegistryName $SourcePath
