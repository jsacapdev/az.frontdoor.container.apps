@description('Basename / Prefix of all resources')
param baseName2 string

@description('Azure Location/Region')
param location string 

@description('Private Link Service Id')
param privateLinkServiceId string

@description('Hostname of App')
param frontDoorAppHostName string

// Define names
var frontDoorProfileName = 'fd-${baseName2}-002'

var app1EndpointName = 'fd-endpoint-${baseName2}-002'
var app1OriginGroupName = 'fd-og-${baseName2}-002'
var app1OriginName = 'fd-origin-${baseName2}-002'
var app1OriginRouteName = 'fd-route-${baseName2}-002'

resource frontDoorProfile 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: frontDoorProfileName
  location: 'Global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
    originResponseTimeoutSeconds: 120
  }
}

resource app1Endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2022-11-01-preview' = {
  parent: frontDoorProfile
  name: app1EndpointName
  location: 'Global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource app1OriginGroup 'Microsoft.Cdn/profiles/originGroups@2022-11-01-preview' = {
  parent: frontDoorProfile
  name: app1OriginGroupName
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/health'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
  }
}

resource app1Origin 'Microsoft.Cdn/profiles/originGroups/origins@2022-11-01-preview' = {
  parent: app1OriginGroup
  name: app1OriginName
  properties: {
    hostName: frontDoorAppHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: frontDoorAppHostName
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    sharedPrivateLinkResource: {
      privateLink: {
        id: privateLinkServiceId
      }
      privateLinkLocation: location
      requestMessage: 'frontdoor'
    }
    enforceCertificateNameCheck: true
  }
}

resource api1OriginRoute 'Microsoft.Cdn/profiles/afdendpoints/routes@2022-05-01-preview' = {
  parent: app1Endpoint
  name: app1OriginRouteName
  properties: {
    originGroup: {
      id: app1OriginGroup.id
    }
    originPath: '/'
    ruleSets: []
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }

  dependsOn: [
    app1Origin
  ]
}

output fqdn string = app1Endpoint.properties.hostName
