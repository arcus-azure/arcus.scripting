---
title: "Scripts related to interacting with Azure Storage for file shares"
layout: default
---

# Azure Storage for file shares

This module provides the following capabilities:
- [Creating a new folder on an Azure file share](#creating-a-folder-on-an-azure-file-share)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.Storage.FileShare
```

## Creating a folder on an Azure file share

Creates a new folder within the Azure File Share resource.

| Parameter            | Mandatory | Description                                                             |
| -------------------- | --------- | ----------------------------------------------------------------------- |
| `ResourceGroupName`  | yes       | The resource group containing the Azure File Share.                     |
| `StorageAccountName` | yes       | The Azure Storage account name that has access to the Azure File Share. |
| `FileShareName`      | yes       | The name of the Azure File Share.                                       |
| `FolderName`         | yes       | The name of the folder to create in the Azure File Share.               |

**Example**

```powershell
Create-AzFileShareStorageFolder -ResourceGroupName "shipping-resources" -StorageAccountName "tracking-account-storage" -FileShareName "returned" -FolderName "containers"
# Creating 'containers' directory in file share..
# Directory 'containers' has been created..
```
