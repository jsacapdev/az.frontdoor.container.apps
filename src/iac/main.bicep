@description('Azure Location/Region')
param location string = resourceGroup().location

@description('Basename for all resources')
@minLength(4)
@maxLength(12)
param baseName string

@description('Basename for all resources')
@minLength(4)
@maxLength(12)
param baseName2 string

module network './modules/network.bicep' = {
  name: 'network'
  params: {
    location: location
    baseName: baseName
  }
}

module logAnalytics './modules/loganalytics.bicep' = {
  name: 'loganalytics'
  params: {
    location: location
    baseName: baseName
  }
}

module containerAppsEnv './modules/containerappsenv.bicep' = {
  name: 'containerapps'
  params: {
    location: location
    baseName: baseName
    logAnalyticsWorkspaceName: logAnalytics.outputs.logAnalyticsWorkspaceName
    infrastructureSubnetId: network.outputs.containerappsSubnetid
  }
}

module containerApp './modules/containerapp.bicep' = {
  name: 'containerapp'
  params: {
    location: location
    baseName: baseName
    containerAppsEnvironmentId: containerAppsEnv.outputs.containerAppsEnvironmentId
    containerImage: 'ghcr.io/jsacapdev/nodeapp:latest'
  }
}

module privateLinkService './modules/privatelinkservice.bicep' = {
  name: 'privatelink'
  params: {
    location: location
    baseName: baseName
    vnetSubnetId: network.outputs.containerappsSubnetid
    containerAppsDefaultDomainName: containerAppsEnv.outputs.containerAppsEnvironmentDefaultDomain
  }
}

module frontDoor './modules/frontdoor.bicep' = {
  name: 'frontdoor'
  params: {
    baseName: baseName
    location: location
    privateLinkServiceId: privateLinkService.outputs.privateLinkServiceId
    frontDoorAppHostName: containerApp.outputs.containerFqdn
  }
}

// Re-Read Private Link Service to get Pending Approval status
// module readPrivateLinkService './modules/readPrivateEndpoint.bicep' = {
//   name: 'readprivatelink'
//   params: {
//     privateLinkServiceName: privateLinkService.outputs.privateLinkServiceName
//   }

//   dependsOn: [
//     frontDoor
//   ]
// }

// Prepare Output
// var privateLinkEndpointConnectionId = readPrivateLinkService.outputs.privateLinkEndpointConnectionId
var fqdn = frontDoor.outputs.fqdn

// Outputs
output frontdoor_fqdn string = fqdn
// output privateLinkEndpointConnectionId string = privateLinkEndpointConnectionId

output result object = {
  fqdn: fqdn
  privateLinkServiceId: privateLinkService.outputs.privateLinkServiceId
  // privateLinkEndpointConnectionId: privateLinkEndpointConnectionId
}

