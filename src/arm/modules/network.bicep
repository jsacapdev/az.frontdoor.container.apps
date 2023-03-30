@description('Basename / Prefix of all resources')
param baseName string

@description('Azure Location/Region')
param location string 

// Define names
var vnetName = 'vnet-${baseName}'
var subnetNsgName = 'nsg-snet-ca-${baseName}'

// Create Network Security Group
resource subnetNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: subnetNsgName
  location: location
  properties: {
    securityRules: [
    ]
  }
}

// Create VNET
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: vnetName
  location: location
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
