---
title: "Scripts related to interacting with Azure Storage for file shares"
layout: default
---

# Azure Storage for file shares

This module provides the following capabilities:
- [Creating a new folder on an Azure file share](#creating-a-folder-on-an-azure-file-share)
- [Copying files to a folder on an Azure file share](#copying-files-to-a-folder-on-an-azure-file-share)

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
| `StorageAccountName` | yes       | The Azure Storage Account name that hosting the Azure File Share. |
| `FileShareName`      | yes       | The name of the Azure File Share.                                       |
| `FolderName`         | yes       | The name of the folder to create in the Azure File Share.               |

**Example**

```powershell
PS> Create-AzFileShareStorageFolder -ResourceGroupName "shipping-resources" -StorageAccountName "tracking-account-storage" -FileShareName "returned" -FolderName "containers"
# Creating 'containers' directory in file share..
# Directory 'containers' has been created..
```

## Copying files to a folder on an Azure file share

Upload a series of files at a given folder, matching an optional file mask, to a Azure File Share.

| Parameter               | Mandatory | Description                                                                                                            |
| ----------------------- | --------- | ---------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`     | yes       | The resource group containing the Azure File Share.                                                                    |
| `StorageAccountName`    | yes       | The Azure Storage account name that is hosting the Azure File Share.                                                   |
| `FileShareName`         | yes       |  The name of the Azure File Share.                                                                                     |
| `SourceFolderPath`      | yes       | The file directory where the targeted files are located.                                                               |
| `DestinationFolderName` | yes       | The name of the destination folder on the Azure File Share where the targeted files will be uploaded.                  |
| `FileMask`              | no        | The file mask that filters out the targetted files at the source folder that will be uploaded to the Azure File Share. |

**Example**

```powershell
PS> Copy-AzFileShareStorageFiles -ResourceGroupName "shipping-resources" -StorageAccountName "tracking-account-storage" -FileShareName "returned" -SourceFolderPath "containers" -DestinationFolderName "containers"
# Upload files to file share...
# Uploaded the file to File Share: [fileName]
# Uploaded the file to File Share: [fileName]
# Files have been uploaded
```