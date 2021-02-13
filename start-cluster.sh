#!/bin/bash

. ./common.sh

az configure --defaults location=$LOCATION group=$RESOURCE_GROUP
az account set --subscription $SUBSCRIPTION_ID

VmssName=$(az sf cluster show --cluster-name $ClusterName --query nodeTypes[0].name -o tsv)

az vmss start -n $VmssName