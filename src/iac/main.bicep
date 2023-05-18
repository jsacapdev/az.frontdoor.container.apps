@description('Azure Location/Region')
param location string = resourceGroup().location

@description('Basename for all resources')
param baseName string

@description('Basename for all resources')
param baseName2 string

@description('Product Owner Name')
param productOwner string

param tags object = {
  productOwner: productOwner
  application: 'container apps'
  environment: 'dev'
  projectCode: 'nonbillable'
}

module network './modules/network.bicep' = {
  name: 'network'
  params: {
    location: location
    baseName: baseName
    tags: tags
  }
}

module logAnalytics './modules/loganalytics.bicep' = {
  name: 'loganalytics'
  params: {
    location: location
    baseName: baseName
    tags: tags
  }
}

module containerAppsEnv './modules/containerappsenv.bicep' = {
  name: 'containerapps'
  params: {
    location: location
    baseName: baseName
    tags: tags
    logAnalyticsWorkspaceName: logAnalytics.outputs.logAnalyticsWorkspaceName
    infrastructureSubnetId: network.outputs.containerappsSubnetid
  }
}

module containerApp './modules/containerapp.bicep' = {
  name: 'containerapp'
  params: {
    location: location
    baseName: baseName
    tags: tags
    containerAppsEnvironmentId: containerAppsEnv.outputs.containerAppsEnvironmentId
    containerImage: 'ghcr.io/jsacapdev/nodeapp:latest'
  }
}

module privateLinkService './modules/privatelinkservice.bicep' = {
  name: 'privatelink'
  params: {
    location: location
    baseName: baseName
    tags: tags
    vnetSubnetId: network.outputs.containerappsSubnetid
    containerAppsDefaultDomainName: containerAppsEnv.outputs.containerAppsEnvironmentDefaultDomain
  }
}

module frontDoor './modules/frontdoor.bicep' = {
  name: 'frontdoor'
  params: {
    baseName2: baseName2
    location: location
    tags: tags
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

