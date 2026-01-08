targetScope = 'resourceGroup'
param environment string = 'production'
param location string = resourceGroup().location
param uniqueSuffix string = uniqueString(resourceGroup().id)

var containerAppEnvName = 'cae-lazarus-${uniqueSuffix}'
var containerAppName = 'ca-lazarus-omega-brief'

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: containerAppEnvName
  location: location
  properties:  {
    appLogsConfiguration: { destination: 'azure-monitor' }
  }
}

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name:  containerAppName
  location: location
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: { external: true, targetPort: 80, allowInsecure: false }
    }
    template: {
      containers: [{
        name: 'lazarus-omega-brief'
        image: 'mcr.microsoft. com/azuredocs/containerapps-helloworld:latest'
        resources: { cpu: json('0.5'), memory: '1.0Gi' }
      }]
      scale: { minReplicas: 1, maxReplicas: 10 }
    }
  }
}

output containerAppUrl string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
