---
title: "Scripts related to interacting with Azure Table Storage"
layout: default
---

# Azure Table Storage

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Import-Module -Name Arcus.Scripting.TableStorage
```

## Create new table in Azure Table Storage on Storage Account

(Re)Create a Table Storage within an Azure Storage Account.

| Parameter            | Mandatory | Description                                                                                                     |
| -------------------- | --------- | --------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`  | yes       | The resource group where the Storage Account is located                                                           |
| `StorageAccountName` | yes       | The name of the Storage Account to add the table to                                                             |
| `TableName`          | yes       | The name of the table to add on the Storage Account                                                             |
| `DeleteAndCreate`    | no        | The optional flag to indicate whether or not a possible already existing table should be deleted and re-created |

**Example**

With non-existing table:

```powershell
PS> Create-AzTableStorageAccountTable -ResourceGroupName "stock" -StorageAccountName "admin" -TableName "products"
# Creating table 'products' in the storage account 'admin'..."
```

With existing table and re-create:

```powershell
PS> Create-AzTableStorageAccountTable -ResourceGroupname "stock" -StorageAccountName "admin" -TableName "products"
# Deleting existing table 'products' in the storage account 'admin'...
# Creating table 'products' in the storage account 'admin'..
```
