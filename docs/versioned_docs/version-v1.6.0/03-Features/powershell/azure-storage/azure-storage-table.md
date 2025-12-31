---
title: " Azure Table Storage"
layout: default
---

# Azure Storage - Tables

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.Storage.Table
```

## Creating a new table in an Azure Storage Account

(Re)Create a Azure Table Storage within an Azure Storage Account.

| Parameter              | Mandatory | Description                                                                                                                |
| ---------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`    | yes       | The resource group where the Azure Storage Account is located                                                              |
| `StorageAccountName`   | yes       | The name of the Azure Storage Account to add the table to                                                                  |
| `TableName`            | yes       | The name of the table to add on the Azure Storage Account                                                                  |
| `Recreate`             | no        | The optional flag to indicate whether or not a possible already existing table should be deleted and re-created            |
| `RetryIntervalSeconds` | no        | The optional amount of seconds to wait each retry-run when a failure occurs during the re-creating process (default: 10s)  |
| `MaxRetryCount`        | no        | The optional maximum amount of retry-runs should happen when a failure occurs during the re-creating process (default: 10) |

**Example**

With non-existing table:

```powershell
PS> Create-AzStorageTable `
-ResourceGroupName "stock" `
-StorageAccountName "admin" `
-TableName "products"
# Azure storage table 'products' does not exist yet in the Azure storage account 'admin', so will create one
# Azure storage table 'products' created in Azure storage account 'admin'
```

With existing table and re-create:

```powershell
PS> Create-AzStorageTable `
-ResourceGroupName "stock" `
-StorageAccountName "admin" `
-TableName "products" `
-Recreate `
-RetryIntervalSeconds 3
# Azure storage table 'products' has been removed from Azure storage account 'admin'
# Failed to re-create the Azure storage table 'products' in Azure storage account 'admin', retrying in 3 seconds...
# Failed to re-create the Azure storage table 'products' in Azure storage account 'admin', retrying in 3 seconds...
# Azure storage table 'products' created in Azure storage account 'admin'
```


## Set the entities in a table of an Azure Storage Account

Deletes all entities of a specified table in an Azure Storage Account and creates new entities based on a configuration file.

| Parameter              | Mandatory | Description                                                                                                                |
| ---------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`    | yes       | The resource group where the Azure Storage Account is located                                                              |
| `StorageAccountName`   | yes       | The name of the Azure Storage Account that contains the table                                                              |
| `TableName`            | yes       | The name of the table in which the entities should be set                                                                  |
| `ConfigurationFile`    | yes       | Path to the JSON Configuration file containing all the entities to be set                                                  |

**Configuration File**

The configuration file is a simple JSON file that contains all of the entities that should be set on the specified table, the JSON file consists of an array of JSON objects (= your entities). Each object contains simple name-value pairs (string-string).

Defining the PartitionKey and/or RowKey are optional, if not provided a random GUID will be set for these.

 The file needs to adhere to the following JSON schema:

``` json
{
  "definitions": {},
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://scripting.arcus-azure.net/Features/powershell/azure-storage/azure-storage-table/config.json",
  "type": "array",
  "title": "The configuration JSON schema",
  "items": [{
      "type": "object",
      "patternProperties": {
        "^.*$": {
          "anyOf": [{
              "type": "string"
            }, {
              "type": "null"
            }
          ]
        }
      },
      "additionalProperties": false
    }
  ]
}
```

**Example Configuration File**

```json
[
  {
    "PartitionKey": "SystemA",
    "RowKey": "100",
    "ReadPath": "/home/in",
    "ReadIntervalInSeconds": "30"  
  },
  {
    "PartitionKey": "SystemA",
    "RowKey": "200",
    "ReadPath": "/data/in",
    "ReadIntervalInSeconds": "10",
    "HasSubdirectories": "true" 
  }
]
```

**Example**

```powershell
PS> Set-AzTableStorageEntities `
-ResourceGroupName "someresourcegroup" `
-StorageAccountName "somestorageaccount" `
-TableName "sometable" `
-ConfigurationFile ".\config.json"
# Deleting all existing entities in Azure storage table 'sometable' for Azure storage account 'somestorageaccount' in resource group 'someresourcegroup'...
# Successfully deleted all existing entities in Azure storage table 'sometable' for Azure storage account 'somestorageaccount' in resource group 'someresourcegroup'
# Successfully added all entities in Azure storage table 'sometable' for Azure storage account 'somestorageaccount' in resource group 'someresourcegroup'
```
