## prepare jump VM

- Ubuntu 20.10
- System Managed Identity
- VNET

### install Azure CLI

```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### prepare subscription (optional)

```
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.ServiceFabric
```

### install SF CLI

from https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-cli

```
sudo apt-get update
sudo apt-get install python3 -y
sudo apt-get install python3-pip -y
pip3 install sfctl
export PATH=$PATH:~/.local/bin
echo "export PATH=$PATH:~/.local/bin" >> .shellrc
```

### install Dapr

```
wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash
```

### install tools

```
sudo apt-get install pwgen -y
```

### set environment variables

```
export SUBSCRIPTION_ID={subscription-id}
export RESOURCE_GROUP={resource-group-name}
export LOCATION={azure-location}
export VNET=sf-{vnet-name}
export SUBNET={subnet-name}
```

## install cluster

###

```
az login --use-device-code
az configure --defaults location=$LOCATION group=$RESOURCE_GROUP
az account set --subscription $SUBSCRIPTION_ID
```