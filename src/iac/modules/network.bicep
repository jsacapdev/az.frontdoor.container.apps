@description('Basename / Prefix of all resources')
param baseName string

@description('Azure Location/Region')
param location string 

@description('Tags')
param tags object

// Define names
var vnetName = 'vnet-${baseName}'
var subnetNsgName = 'nsg-snet-ca-${baseName}'

// Create Network Security Group
resource subnetNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: subnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
    ]
  }
}

// Create VNET
resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-ca'
        properties: {
          addressPrefix: '10.0.0.0/23'
          networkSecurityGroup: {
            id: subnetNsg.id
          }
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output containerappsSubnetid string = vnet.properties.subnets[0].id
