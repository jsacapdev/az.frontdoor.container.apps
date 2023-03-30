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

module containerAppsEnv './modules/containerAppsEnv.bicep' = {
  name: 'containerapps'
  params: {
    location: location
    baseName: baseName
    logAnalyticsWorkspaceName: logAnalytics.outputs.logAnalyticsWorkspaceName
    infrastructureSubnetId: network.outputs.containerappsSubnetid
  }
}

module containerApp './modules/containerApp.bicep' = {
  name: 'containerApp'
  params: {
    location: location
    baseName: baseName
    containerAppsEnvironmentId: containerAppsEnv.outputs.containerAppsEnvironmentId
    containerImage: 'jsacapdev/nodeapp:v1'
  }
}

// Prepare Output
var subId = network.outputs.containerappsSubnetid

// outputs
output subnetIdOut string = subId

output result object = {
  subId: subId
}
