param location string = resourceGroup().location
param prefix string = replace(resourceGroup().name, '-', '')

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: prefix
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: '${prefix}ServicePlan'
  location: location
  sku: {
    name: 'Y1'
  }
  kind: 'linux'
}

resource azureFunction 'Microsoft.Web/sites@2020-12-01' = {
  name: '${prefix}Funcion'
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0]}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'nodejs'
        }
      ]
    }
    httpsOnly: true
  }
}

resource function 'Microsoft.Web/sites/functions@2022-03-01' = {
  name: '${azureFunction.name}/CrossOriginResourceProxy'
  properties: {
    config: {
      bindings: [
        {
          name: 'req'
          type: 'httpTrigger'
          direction: 'in'
          authLevel: 'function'
          methods: [
            'get'
          ]
        }
        {
          name: '$return'
          type: 'http'
          direction: 'out'
        }
      ]
    }
    files: {
      'index.js': loadTextContent('./functions/dist/CrossOriginResourceProxy/index.js')
    }
  }
}
