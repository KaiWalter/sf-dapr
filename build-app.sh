#!/bin/bash

. ./common.sh

SourcePath=./simple-server
ImageTag=simple-server:$AppVersion

az acr build -t $ImageTag -r $RegistryName $SourcePath
