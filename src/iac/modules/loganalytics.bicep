@description('Basename / Prefix of all resources')
param baseName string

@description('Azure Location/Region')
param location string 

@description('Tags')
param tags object

// Define names
var logAnalyticsName = 'log-${baseName}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
