@description('Basename / Prefix of all resources')
param baseName string

@description('Azure Location/Region')
param location string 

// Define names
var logAnalyticsName = 'log-${baseName}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'hiphop'
    }
  }
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
