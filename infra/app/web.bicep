param nameprefix string
param location string = resourceGroup().location
param cosmosConnectionString string

param cosmosConnetcionStringKey string = replace(cosmosConnectionString, '==', '%3D%3D')
param consmosConnectStringKeyFinal string = replace(cosmosConnetcionStringKey, 'maxIdleTime', 'socketTimeout')

resource serverfarms 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${nameprefix}serverfarm'
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
    size: 'F1'
    family: 'F'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

var appConfig = {
  MONGODB_URI: consmosConnectStringKeyFinal
  DOCKER_ENABLE_CI: 'true'
  DOCKER_REGISTRY_SERVER_PASSWORD: ''
  DOCKER_REGISTRY_SERVER_URL: 'https://index.docker.io/v1/'
  DOCKER_REGISTRY_SERVER_USERNAME: ''
  WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
  API_SECRET: 'mysecretivesecret'
}

resource web 'Microsoft.Web/sites@2022-03-01' = {
  name: '${nameprefix}web'
  location: location
  kind: 'app,linux,container'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${nameprefix}web.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${nameprefix}web.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms.id
    reserved: true
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'DOCKER|nightscout/cgm-remote-monitor:14.2.6'
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }

  resource appSettingsConfig 'config' = {
    name: 'appsettings'
    properties: appConfig
  }
}
