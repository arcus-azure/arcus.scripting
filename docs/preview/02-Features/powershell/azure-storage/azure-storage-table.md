---
title: " Azure Table Storage"
layout: default
---

# Azure Storage - Tables

This module provides the following capabilities:
- [Creating a new table in an Azure Storage Account](#creating-a-new-table-in-an-azure-storage-account)

- [Set the entities in a table of an Azure Storage Account](#set-the-entities-in-a-table-of-an-azure-storage-account)

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
| `RetryIntervalSeconds` | no        | The optional amount of seconds to wait each retry-run when a failure occures during the re-creating process (default: 5s)  |
| `MaxRetryCount`        | no        | The optional maximum amount of retry-runs should happen when a failure occurs during the re-creating process (default: 10) |

**Example**

With non-existing table:

```powershell
PS> Create-AzStorageTable -ResourceGroupName "stock" -StorageAccountName "admin" -TableName "products"
# Azure storage account context has been retrieved
# Azure storage table 'products' does not exist yet in the Azure storage account, so will create one
# Azure storage table 'products' created
```

With existing table and re-create:

```powershell
PS> Create-AzStorageTable -ResourceGroupName "stock" -StorageAccountName "admin" -TableName "products" -Recreate -RetryIntervalSeconds 3
# Azure storage account context has been retrieved
# Azure storage table 'products' has been removed
# Failed to re-create the Azure storage table 'products', retrying in 5 seconds...
# Failed to re-create the Azure storage table 'products', retrying in 5 seconds...
# Azure storage table 'products' created
```

## Set the entities in a table of an Azure Storage Account

Sets (Delete + Create) all the entities of a specified table in an Azure Storage Account.

| Parameter              | Mandatory | Description                                                                                                                |
| ---------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`    | yes       | The resource group where the Azure Storage Account is located                                                              |
| `StorageAccountName`   | yes       | The name of the Azure Storage Account that contains the table                                                                  |
| `TableName`            | yes       | The name of the table in which the entities should be set                                                                  |
| `ConfigurationFile`             | yes        | Path to the JSON Configuration file containing all the entities to be set            |
| `RetryIntervalSeconds` | no        | The optional amount of seconds to wait each retry-run when a failure occures during the re-creating process (default: 5s)  |
| `MaxRetryCount`        | no        | The optional maximum amount of retry-runs should happen when a failure occurs during the re-creating process (default: 10) |


**ConfigurationFile**
The configuration file is a simple JSON file that contains all of the entities that should be set on the specified table, the JSON file consists of an array of JSON objects (= your entities). Each object contains simple name-value pairs (string-string). Defining the PartitionKey and/or RowKey are optional, if not provided a random GUID will be set for these.

**Example ConfigurationFile**

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
    },
]
```

**Example usage**

```powershell
PS> Set-AzTableStorageEntities -ResourceGroupName "rg1" -StorageAccountName "storacc" -TableName "configtable" -ConfigurationFile "D:/somepath/entities.json"
# Retrieving Azure storage account...
# Azure storage account has been retrieved
# Azure table has been retrieved
# Deleting all existing entities...
# ...
# Succesfully added all entities
```