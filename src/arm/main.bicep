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
