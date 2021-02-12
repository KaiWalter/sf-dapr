# Service Fabric Dapr

Goal is to figure out how far Dapr sidecars can be utilized when deployed on Service Fabric - instead of the "regular" Kubernetes.

## next challenge

- [x] bring Dapr sidecar up in container
- [ ] invoke method from outside
- [ ] use input binding or pub/sub from outside

## prepare subscription

- add role assignments `Key Vault Certificates Officer` & `Key Vault Secrets Officer` for your user on the resource group you use; will be picked up by `az keyvault create --name $VaultName --enable-rbac-authorization` when resources are installed
- register resource types `Microsoft.KeyVault` and `Microsoft.ServiceFabric`

```
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.ServiceFabric
```


## prepare jump VM

- Ubuntu 20.04 or 20.10
- own VNET which will also contain Service Fabric

### install Azure CLI

> see https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt

```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### install SF CLI

from https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-cli

```
sudo apt-get update
sudo apt-get install python3 -y
sudo apt-get install python3-pip -y
pip3 install sfctl
export PATH=$PATH:~/.local/bin
echo "export PATH=$PATH:~/.local/bin" >> ~/.shellrc
```

### install Dapr

> https://docs.dapr.io/getting-started/install-dapr-cli/

```
wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash
```

### install Bicep

> see https://github.com/Azure/bicep/blob/main/docs/installing.md

```
curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
chmod +x ./bicep
sudo mv ./bicep /usr/local/bin/bicep
bicep --help
```

### install tools

```
sudo apt-get install pwgen sshpass -y
```

### set environment variables

e.g. in `~/.bash_rc` ...

```
export SUBSCRIPTION_ID={subscription id to place resources in}
export RESOURCE_GROUP={resource group name to place resources in}
export LOCATION={azure location to place resources in}
export VNET=sf-{vnet name}
export SUBNET={subnet name}
export RESOURCE_PREFIX={short prefix to make resources unique}
```

## install cluster

### login to subscription and set defaults

```
az login --use-device-code
. ~/.bash_rc
az configure --defaults location=$LOCATION group=$RESOURCE_GROUP
az account set --subscription $SUBSCRIPTION_ID
./install-resources.sh
```

## build & deploy app

> some samples apps are copied from Dapr Python SDK with `cp -r ../python-sdk/examples/invoke-simple/ .`

### build

- adjust `AppVersion` in `./common.sh`
- execute `./build-app.sh`

### deploy

- execute `./deploy-app-mc2.sh`

### remove

- execute `./remove-app.sh`

---

## Links

- [Service model XML schema documentation](https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-service-model-schema)