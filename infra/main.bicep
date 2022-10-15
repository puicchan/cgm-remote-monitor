targetScope = 'subscription'

@minLength(1)
@maxLength(16)
@description('Prefix for all resources, i.e. {name}storage')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
//param location string = deployment().location
param location string

var tags = { 'azd-env-name': environmentName }

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${environmentName}-rg'
  location: location
  tags: tags
}

module db './app/db.bicep' = {
  name: '${environmentName}-db'
  scope: rg
  params: {
    nameprefix: toLower(environmentName)
    location: rg.location
  }
}

module web './app/web.bicep' = {
  name: '${environmentName}-web'
  scope: rg
  params: {
    nameprefix: toLower(environmentName)
    location: rg.location
    cosmosConnectionString: db.outputs.cosmosConnectionStringKey 
  }

}
