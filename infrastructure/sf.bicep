param clusterLocation string {
  metadata: {
    description: 'Location of the Cluster'
  }
  default: 'westeurope'
}
param clusterName string {
  metadata: {
    description: 'Name of your cluster - Between 3 and 23 characters. Letters and numbers only'
  }
  default: 'GEN-UNIQUE'
}
param adminUserName string {
  metadata: {
    description: 'Remote desktop user Id'
  }
  default: 'GEN-UNIQUE'
}
param adminPassword string {
  metadata: {
    description: 'Remote desktop user password. Must be a strong password'
  }
  secure: true
  default: 'GEN-PASSWORD'
}
param vmImagePublisher string {
  metadata: {
    description: 'VM image Publisher'
  }
  default: 'Canonical'
}
param vmImageOffer string {
  metadata: {
    description: 'VM image offer'
  }
  default: 'UbuntuServer'
}
param vmImageSku string {
  metadata: {
    description: 'VM image SKU'
  }
  default: '16.04-LTS'
}
param vmImageVersion string {
  metadata: {
    description: 'VM image version'
  }
  default: 'latest'
}
param clusterProtectionLevel string {
  allowed: [
    'None'
    'Sign'
    'EncryptAndSign'
  ]
  metadata: {
    description: 'Protection level.Three values are allowed - EncryptAndSign, Sign, None. It is best to keep the default of EncryptAndSign, unless you have a need not to'
  }
  default: 'EncryptAndSign'
}
param sourceVaultValue string {
  metadata: {
    description: 'Resource Id of the key vault, is should be in the format of /subscriptions/<Sub ID>/resourceGroups/<Resource group name>/providers/Microsoft.KeyVault/vaults/<vault name>'
  }
  default: 'GEN-KEYVAULT-RESOURCE-ID'
}

param certificateThumbprint string {
  metadata: {
    description: 'Certificate Thumbprint'
  }
  default: 'GEN-CUSTOM-DOMAIN-SSLCERT-THUMBPRINT'
}
param certificateUrlValue string {
  metadata: {
    description: 'Refers to the location URL in your key vault where the certificate was uploaded, it is should be in the format of https://<name of the vault>.vault.azure.net:443/secrets/<exact location>'
  }
  default: 'GEN-KEYVAULT-SSL-SECRET-URI'
}
param certificateStoreValue string {
  allowed: [
    'My'
    'Root'
  ]
  metadata: {
    description: 'The store name where the cert will be deployed in the virtual machine'
  }
  default: 'My'
}

param adminCertificateThumbprint string {
  metadata: {
    description: 'Admin/Client Certificate Thumbprint'
  }
  default: 'GEN-CUSTOM-DOMAIN-SSLCERT-THUMBPRINT'
}
param adminCertificateUrlValue string {
  metadata: {
    description: 'Refers to the location URL in your key vault where the certificate was uploaded, it is should be in the format of https://<name of the vault>.vault.azure.net:443/secrets/<exact location>'
  }
  default: 'GEN-KEYVAULT-SSL-SECRET-URI'
}
param adminCertificateStoreValue string {
  allowed: [
    'My'
    'Root'
  ]
  metadata: {
    description: 'The store name where the cert will be deployed in the virtual machine'
  }
  default: 'Root'
}


param storageAccountType string {
  allowed: [
    'Standard_LRS'
  ]
  metadata: {
    description: 'Replication option for the VM image storage account'
  }
  default: 'Standard_LRS'
}
param supportLogStorageAccountType string {
  allowed: [
    'Standard_LRS'
  ]
  metadata: {
    description: 'Replication option for the support log storage account'
  }
  default: 'Standard_LRS'
}
param applicationDiagnosticsStorageAccountType string {
  allowed: [
    'Standard_LRS'
  ]
  metadata: {
    description: 'Replication option for the application diagnostics storage account'
  }
  default: 'Standard_LRS'
}

param nt0InstanceCount int {
  metadata: {
    description: 'Instance count for node type'
  }
  default: 3
}
param vmNodeType0Size string = 'Standard_D2s_v3'
param overProvision bool = false

param subNetId string
param subNetPrefix string

// common variables

var computeLocation = clusterLocation

var nt0applicationStartPort = 20000
var nt0applicationEndPort = 30000
var nt0ephemeralStartPort = 49152
var nt0ephemeralEndPort = 65534
var nt0fabricTcpGatewayPort = 19000
var nt0fabricHttpGatewayPort = 19080

var lbName = 'LB-${clusterName}-${vmss_nodetype0_name}'

// cluster and node support logs

var supportLog_storageAccount_name = toLower('${uniqueString(resourceGroup().id)}2')

resource supportLog_storageAccount_resource 'Microsoft.Storage/storageAccounts@2018-07-01' = {
  name: supportLog_storageAccount_name
  location: computeLocation
  properties: {}
  kind: 'Storage'
  sku: {
    name: supportLogStorageAccountType
  }
  tags: {
    resourceType: 'Service Fabric'
    clusterName: clusterName
  }
  dependsOn: []
}

var applicationDiagnistics_storage_name = toLower('wad${uniqueString(resourceGroup().id)}3')

resource applicationDiagnistics_storage_resource 'Microsoft.Storage/storageAccounts@2018-07-01' = {
  name: applicationDiagnistics_storage_name
  location: computeLocation
  properties: {}
  kind: 'Storage'
  sku: {
    name: applicationDiagnosticsStorageAccountType
  }
  tags: {
    resourceType: 'Service Fabric'
    clusterName: clusterName
  }
  dependsOn: []
}

resource lb_resource 'Microsoft.Network/loadBalancers@2018-08-01' = {
  name: lbName
  location: computeLocation
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerIPConfig'
        properties: {
          subnet: {
            id: subNetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'LoadBalancerBEAddressPool'
        properties: {}
      }
    ]
    loadBalancingRules: [
      {
        name: 'LBRule'
        properties: {
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'LoadBalancerBEAddressPool')
          }
          backendPort: nt0fabricTcpGatewayPort
          enableFloatingIP: false
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'LoadBalancerIPConfig')
          }
          frontendPort: nt0fabricTcpGatewayPort
          idleTimeoutInMinutes: 5
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'FabricGatewayProbe')
          }
          protocol: 'Tcp'
        }
      }
      {
        name: 'LBHttpRule'
        properties: {
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'LoadBalancerBEAddressPool')
          }
          backendPort: nt0fabricHttpGatewayPort
          enableFloatingIP: false
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'LoadBalancerIPConfig')
          }
          frontendPort: nt0fabricHttpGatewayPort
          idleTimeoutInMinutes: 5
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'FabricHttpGatewayProbe')
          }
          protocol: 'Tcp'
        }
      }
    ]
    probes: [
      {
        name: 'FabricGatewayProbe'
        properties: {
          intervalInSeconds: 5
          numberOfProbes: 2
          port: nt0fabricTcpGatewayPort
          protocol: 'Tcp'
        }
      }
      {
        name: 'FabricHttpGatewayProbe'
        properties: {
          intervalInSeconds: 5
          numberOfProbes: 2
          port: nt0fabricHttpGatewayPort
          protocol: 'Tcp'
        }
      }
    ]
    inboundNatPools: []
  }
  tags: {
    resourceType: 'Service Fabric'
    clusterName: clusterName
  }
}

var vmss_nodetype0_name = '${clusterName}-nt0'
var vmss_nodetype0_vmprefix = 'nt0'
var nicName = 'NIC'
var wadlogs = '<WadCfg><DiagnosticMonitorConfiguration>'
var wadperfcounters1 = '<PerformanceCounters scheduledTransferPeriod="PT1M"><PerformanceCounterConfiguration counterSpecifier="\\Memory\\AvailableMemory" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory available" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\PercentAvailableMemory" sampleRate="PT15S" unit="Percent"><annotation displayName="Mem. percent available" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\UsedMemory" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory used" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\PercentUsedMemory" sampleRate="PT15S" unit="Percent"><annotation displayName="Memory percentage" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\PercentUsedByCache" sampleRate="PT15S" unit="Percent"><annotation displayName="Mem. used by cache" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Processor\\PercentIdleTime" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU idle time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Processor\\PercentUserTime" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU user time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Processor\\PercentProcessorTime" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU percentage guest OS" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Processor\\PercentIOWaitTime" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU IO wait time" locale="en-us"/></PerformanceCounterConfiguration>'
var wadperfcounters2 = '<PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk\\BytesPerSecond" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk total bytes" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk\\ReadBytesPerSecond" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk read guest OS" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk\\WriteBytesPerSecond" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk write guest OS" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk\\TransfersPerSecond" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk transfers" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk\\ReadsPerSecond" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk reads" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk\\WritesPerSecond" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk writes" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk\\AverageReadTime" sampleRate="PT15S" unit="Seconds"><annotation displayName="Disk read time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk\\AverageWriteTime" sampleRate="PT15S" unit="Seconds"><annotation displayName="Disk write time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk\\AverageTransferTime" sampleRate="PT15S" unit="Seconds"><annotation displayName="Disk transfer time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk\\AverageDiskQueueLength" sampleRate="PT15S" unit="Count"><annotation displayName="Disk queue length" locale="en-us"/></PerformanceCounterConfiguration></PerformanceCounters>'
var wadcfgxstart = '${wadlogs}${wadperfcounters1}${wadperfcounters2}<Metrics resourceId="'
var wadcfgxend = '"><MetricAggregation scheduledTransferPeriod="PT1H"/><MetricAggregation scheduledTransferPeriod="PT1M"/></Metrics></DiagnosticMonitorConfiguration></WadCfg>'
var wadmetricsresourceid0 = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Compute/virtualMachineScaleSets/${vmss_nodetype0_name}'

resource vmss_nodetype0_resource 'Microsoft.Compute/virtualMachineScaleSets@2018-10-01' = {
  name: vmss_nodetype0_name
  location: computeLocation
  properties: {
    overprovision: overProvision
    upgradePolicy: {
      mode: 'Automatic'
    }
    virtualMachineProfile: {
      extensionProfile: {
        extensions: [
          {
            name: 'ServiceFabricNodeVmExt_vmNodeType0Name'
            properties: {
              type: 'ServiceFabricLinuxNode'
              autoUpgradeMinorVersion: true
              protectedSettings: {
                StorageAccountKey1: listKeys(supportLog_storageAccount_resource.id, '2015-05-01-preview').key1
                StorageAccountKey2: listKeys(supportLog_storageAccount_resource.id, '2015-05-01-preview').key2
              }
              publisher: 'Microsoft.Azure.ServiceFabric'
              settings: {
                clusterEndpoint: reference(clusterName).clusterEndpoint
                nodeTypeRef: vmss_nodetype0_name
                durabilityLevel: 'Bronze'
                enableParallelJobs: true
                nicPrefixOverride: subNetPrefix
                certificate: {
                  thumbprint: certificateThumbprint
                  x509StoreName: certificateStoreValue
                }
              }
              typeHandlerVersion: '1.1'
            }
          }
          {
            name: 'VMDiagnosticsVmExt_vmNodeType0Name'
            properties: {
              type: 'LinuxDiagnostic'
              autoUpgradeMinorVersion: true
              protectedSettings: {
                storageAccountName: applicationDiagnistics_storage_name
                storageAccountKey: listKeys(applicationDiagnistics_storage_resource.id, '2015-05-01-preview').key1
                storageAccountEndPoint: 'https://core.windows.net/'
              }
              publisher: 'Microsoft.OSTCExtensions'
              settings: {
                xmlCfg: base64(concat(wadcfgxstart, wadmetricsresourceid0, wadcfgxend))
                StorageAccount: applicationDiagnistics_storage_name
              }
              typeHandlerVersion: '2.3'
            }
          }
        ]
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: '${nicName}-0'
            properties: {
              ipConfigurations: [
                {
                  name: '${nicName}-0'
                  properties: {
                    loadBalancerBackendAddressPools: [
                      {
                        id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'LoadBalancerBEAddressPool')
                      }
                    ]
                    subnet: {
                      id: subNetId
                    }
                  }
                }
              ]
              primary: true
            }
          }
        ]
      }
      osProfile: {
        adminPassword: adminPassword
        adminUsername: adminUserName
        computerNamePrefix: vmss_nodetype0_vmprefix
        secrets: [
          {
            sourceVault: {
              id: sourceVaultValue
            }
            vaultCertificates: [
              {
                certificateUrl: certificateUrlValue
              }
              {
                certificateUrl: adminCertificateUrlValue
              }
            ]
          }
        ]
      }
      storageProfile: {
        imageReference: {
          publisher: vmImagePublisher
          offer: vmImageOffer
          sku: vmImageSku
          version: vmImageVersion
        }
        osDisk: {
          caching: 'ReadOnly'
          createOption: 'FromImage'
          managedDisk: {
            storageAccountType: storageAccountType
          }
        }
      }
    }
  }
  sku: {
    name: vmNodeType0Size
    capacity: nt0InstanceCount
    tier: 'Standard'
  }
  tags: {
    resourceType: 'Service Fabric'
    clusterName: clusterName
  }
  dependsOn: [
    lb_resource
    supportLog_storageAccount_resource
    applicationDiagnistics_storage_resource
  ]
}

var reliabilityLevel = nt0InstanceCount < 5 ? 'Bronze' : 'Silver'

resource clusterName_resource 'Microsoft.ServiceFabric/clusters@2018-02-01' = {
  name: clusterName
  location: clusterLocation
  properties: {
    addOnFeatures: [
      'DnsService'
      'RepairManager'
    ]
    certificate: {
      thumbprint: certificateThumbprint
      x509StoreName: certificateStoreValue
    }
    clientCertificateThumbprints: [
      {
        certificateThumbprint: adminCertificateThumbprint
        isAdmin: true
      }
    ]
    diagnosticsStorageAccountConfig: {
      blobEndpoint: supportLog_storageAccount_resource.properties.primaryEndpoints.blob
      protectedAccountKeyName: 'StorageAccountKey1'
      queueEndpoint: supportLog_storageAccount_resource.properties.primaryEndpoints.queue
      storageAccountName: supportLog_storageAccount_name
      tableEndpoint: supportLog_storageAccount_resource.properties.primaryEndpoints.table
    }
    fabricSettings: [
      {
        parameters: [
          {
            name: 'ClusterProtectionLevel'
            value: clusterProtectionLevel
          }
        ]
        name: 'Security'
      }
      // https://github.com/microsoft/service-fabric/blob/7f30ccea5cbca3e6ecf3a55b3d1cf34d7c3bd143/src/prod/src/Hosting2/HostingConfig.h#L402
      {
        parameters: [
          {
            name: 'ContainerServiceArguments'
            value: '--default-ipc-mode shareable -H localhost:2375 -H unix:///var/run/docker.sock'
          }
        ]
        name: 'Hosting'
      }
    ]
    managementEndpoint: 'https://${lb_resource.properties.frontendIPConfigurations[0].properties.privateIPAddress}:${nt0fabricHttpGatewayPort}'
    nodeTypes: [
      {
        name: vmss_nodetype0_name
        applicationPorts: {
          endPort: nt0applicationEndPort
          startPort: nt0applicationStartPort
        }
        clientConnectionEndpointPort: nt0fabricTcpGatewayPort
        durabilityLevel: 'Bronze'
        ephemeralPorts: {
          endPort: nt0ephemeralEndPort
          startPort: nt0ephemeralStartPort
        }
        httpGatewayEndpointPort: nt0fabricHttpGatewayPort
        isPrimary: true
        vmInstanceCount: nt0InstanceCount
      }
    ]
    reliabilityLevel: reliabilityLevel
    upgradeMode: 'Automatic'
    vmImage: 'Linux'
  }
  tags: {
    resourceType: 'Service Fabric'
    clusterName: clusterName
  }
  dependsOn: [
    supportLog_storageAccount_resource
  ]
}

output clusterProperties object = reference(clusterName)