---
title: " Azure Table Storage"
layout: default
---

# Azure Storage - Tables

This module provides the following capabilities:
- [Creating a new table in an Azure Storage Account](#creating-a-new-table-in-an-azure-storage-account)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.Storage.Table -MinimumVersion 0.5.0
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
