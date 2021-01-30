#!/bin/bash

. ./common.sh

VmssName=$(az sf cluster show --cluster-name $ClusterName --query nodeTypes[0].name -o tsv)

NodeIp=$(az vmss nic list --vmss-name $VmssName --query "[$1].ipConfigurations[0].privateIpAddress" -o tsv)

if [ -n "${NodeIp}" ]
then
    echo connecting to node $1 ip $NodeIp

    # get VMSS node secrets
    VmUserName=$(az keyvault secret show --vault-name $VaultName -n VmUserName --query value -o tsv)
    VmPassword=$(az keyvault secret show --vault-name $VaultName -n VmPassword --query value -o tsv)

    sshpass -p "$VmPassword" ssh -o StrictHostKeyChecking=no $VmUserName@$NodeIp
fi

