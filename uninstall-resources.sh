#!/bin/bash

. ./common.sh

VmssName=$(az sf cluster show --cluster-name $ClusterName --query nodeTypes[0].name -o tsv)

# delete primary resources
az resource delete --ids $(az sf cluster show --cluster-name $ClusterName --query id -o tsv) --verbose
az resource delete --ids $(az vmss show -n $VmssName --query id -o tsv) --verbose

# delete the rest
az configure --defaults location='' group=''

az resource list --tag clusterName=$ClusterName --query [].id -o tsv | while read -r id
do
    echo delete $id
    az resource delete --ids $id
done

az configure --defaults location=$LOCATION group=$RESOURCE_GROUP