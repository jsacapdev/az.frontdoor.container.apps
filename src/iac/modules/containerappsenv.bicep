@description('Basename / Prefix of all resources')
param baseName string

@description('Azure Location/Region')
param location string 

@description('Subnet resource ID for the Container App environment')
param infrastructureSubnetId string

@description('Tags')
param tags object

@description('Name of the log analytics workspace')
param logAnalyticsWorkspaceName string = 'log-${baseName}'

// Define names
var environmentName = 'cae-${baseName}'

// Read Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
}

// Container Apps Environment
resource environment 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: environmentName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    vnetConfiguration: {
      infrastructureSubnetId: infrastructureSubnetId
      internal: true
    }
  }
}

output containerAppsEnvironmentId string = environment.id
output containerAppsEnvironmentStaticIp string = environment.properties.staticIp
output containerAppsEnvironmentDefaultDomain string = environment.properties.defaultDomain
