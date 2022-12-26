---
title: " Azure Storage for file shares"
layout: default
---

# Azure Storage for file shares

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.Storage.FileShare
```

## Creating a folder on an Azure file share

Creates a new folder within the Azure File Share resource.
When a folder already exists with the provided name, it will be skipped. No exception will be thrown.

| Parameter            | Mandatory | Description                                                             |
| -------------------- | --------- | ----------------------------------------------------------------------- |
| `ResourceGroupName`  | yes       | The resource group containing the Azure File Share.                     |
| `StorageAccountName` | yes       | The Azure Storage Account name that hosting the Azure File Share. |
| `FileShareName`      | yes       | The name of the Azure File Share.                                       |
| `FolderName`         | yes       | The name of the folder to create in the Azure File Share.               |

**Example**

```powershell
PS> Create-AzFileShareStorageFolder `
-ResourceGroupName "shipping-resources" `
-StorageAccountName "tracking-account-storage" `
-FileShareName "returned" -FolderName "containers"
# Created Azure FileShare storage folder 'containers' in file share 'returned'
```

## Uploading files to a folder on an Azure file share

Upload a set of files from a given folder, optionally matching a specific file mask, to an Azure File Share.

| Parameter               | Mandatory | Description                                                                                                            |
| ----------------------- | --------- | ---------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`     | yes       | The resource group containing the Azure File Share.                                                                    |
| `StorageAccountName`    | yes       | The name of the Azure Storage account that is hosting the Azure File Share.                                                   |
| `FileShareName`         | yes       |  The name of the Azure File Share.                                                                                     |
| `SourceFolderPath`      | yes       | The file directory where the targeted files are located.                                                               |
| `DestinationFolderName` | yes       | The name of the destination folder on the Azure File Share where the targeted files will be uploaded.                  |
| `FileMask`              | no        | The file mask that filters out the targeted files at the source folder that will be uploaded to the Azure File Share. |

**Example**

```powershell
PS> Upload-AzFileShareStorageFiles `
-ResourceGroupName "shipping-resources" `
-StorageAccountName "tracking-account-storage" `
-FileShareName "returned" -SourceFolderPath "containers" `
-DestinationFolderName "containers"
# Uploaded the '[fileName]' file to Azure FileShare 'returned'
# Uploaded the '[fileName]' file to Azure FileShare 'returned'
# Files have been uploaded to Azure FileShare storage 'returned' 
```
