param nameprefix string
param location string = resourceGroup().location
  
resource cosmodb 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: '${nameprefix}cosmos'
  location: location
  tags: {
    defaultExperience: 'Azure Cosmos DB for MongoDB API'
    'hidden-cosmos-mmspecial': ''
  }
  kind: 'MongoDB'
  identity: {
    type: 'None'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: false
    virtualNetworkRules: []
    disableKeyBasedMetadataWriteAccess: false
    enableFreeTier: true
    enableAnalyticalStorage: false
    analyticalStorageConfiguration: {
      schemaType: 'FullFidelity'
    }
    databaseAccountOfferType: 'Standard'
    defaultIdentity: 'FirstPartyIdentity'
    networkAclBypass: 'None'
    disableLocalAuth: false
    enablePartitionMerge: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    apiProperties: {
      serverVersion: '4.0'
    }
    locations: [
      {
        locationName: location
        //provisioningState: 'Succeeded'
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    cors: []
    capabilities: [
      {
        name: 'EnableMongo'
      }
      {
        name: 'DisableRateLimitingResponses'
      }
    ]
    ipRules: []
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Geo'
      }
    }
    networkAclBypassResourceIds: []
    capacity: {
      totalThroughputLimit: 1000
    }
    //keysMetadata: {
    //}
  }
}

resource cosmodb_test 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2022-08-15' = {
  parent: cosmodb
  name: 'test'
  properties: {
    resource: {
      id: 'test'
    }
  }
}

output cosmosConnectionStringKey string = cosmodb.listConnectionStrings().connectionStrings[0].connectionString
