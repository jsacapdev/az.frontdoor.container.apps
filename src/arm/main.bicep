@description('Azure Location/Region')
param location string = resourceGroup().location

@description('Basename for all resources')
@minLength(4)
@maxLength(12)
param baseName string

module network './modules/network.bicep' = {
  name: 'network'
  params: {
    location: location
    baseName: baseName
  }
}

module logAnalytics './modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    location: location
    baseName: baseName
  }
}

// Prepare Output
var subId = network.outputs.containerappsSubnetid

// outputs
output subnetIdOut string = subId

output result object = {
  subId: subId
}
