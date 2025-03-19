

// common
targetScope = 'resourceGroup'

// parameters
////////////////////////////////////////////////////////////////////////////////

// common
param env string

@secure()
@description('A password which will be set on all SQL Azure DBs.')


param resourceLocation string = resourceGroup().location

// tenant
param tenantId string = subscription().tenantId


param prefix string = 'contosotraders'

param prefixHyphenated string = 'contoso-traders'



// variables
////////////////////////////////////////////////////////////////////////////////

// key vault
var kvName = '${prefix}kv${env}'
var kvSecretNameAppInsightsConnStr = 'appInsightsConnectionString'



// application insights
var logAnalyticsWorkspaceName = '${prefixHyphenated}-loganalytics${env}'
var appInsightsName = '${prefixHyphenated}-ai${env}'

// portal dashboard
var portalDashboardName = '${prefixHyphenated}-dashboard${env}'



// tags
var resourceTags = {
  Product: prefixHyphenated
  Environment: 'testing'
}

// resources
////////////////////////////////////////////////////////////////////////////////

//
// key vault
//
resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvName

  // secret
  resource kv_secretAppInsightsConnStr 'secrets' = {
    name: kvSecretNameAppInsightsConnStr
    tags: resourceTags
    properties: {
      contentType: 'connection string to the app insights instance'
      value: appinsights.properties.ConnectionString
    }
  }
}



//
// application insights
//

// log analytics workspace
resource loganalyticsworkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: resourceLocation
  tags: resourceTags
  properties: {
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    sku: {
      name: 'PerGB2018' // pay-as-you-go
    }
  }
}

// app insights instance
resource appinsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: resourceLocation
  tags: resourceTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: loganalyticsworkspace.id
  }
}

//
// portal dashboard
//

resource dashboard 'Microsoft.Portal/dashboards@2020-09-01-preview' = {
  name: portalDashboardName
  location: resourceLocation
  tags: resourceTags
  properties: {
    lenses: [
      {
        order: 0
        parts: [
          {
            position: {
              x: 0
              y: 0
              rowSpan: 4
              colSpan: 2
            }
          }
        ]
      }
    ]
  }
}
