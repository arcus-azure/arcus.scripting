---
title: " Azure Blob Storage"
layout: default
---

# Azure Blob Storage

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.Storage.Blob
```

## Uploading files to a Azure Storage Blob container

Uploads a set of files located in a given directory to a container on a Azure Blob Storage resource.

| Parameter              | Mandatory | Description                                                                                                                                                                                                          |
| ---------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`    | yes       | The name of the Azure resource group where the Azure storage account is located.                                                                                                                                     |
| `StorageAccountName`   | yes       | The name of the Azure storage account.                                                                                                                                                                               |
| `TargetFolderPath`     | yes       | The directory where the files are located to upload to Azure Blob Storage.                                                                                                                                           |
| `ContainerName`        | yes       | The name of the container at Azure Blob Storage to upload the targeted files to.                                                                                                                                    |
| `ContainerPermissions` | no        | The level of public access to this container. By default, the container and any blobs in it can be accessed only by the owner of the storage account. To grant anonymous users read permissions to a container and its blobs, you can set the container permissions to enable public access. Anonymous users can read blobs in a publicly available container without authenticating the request. The acceptable values for this parameter are:                                                                    |
|                        |           |  Container: Provides full read access to a container and its blobs. Clients can enumerate blobs in the container through anonymous request, but cannot enumerate containers in the storage account.                   |
|                        |           |  Blob: Provides read access to blob data throughout a container through anonymous request, but does not provide access to container data. Clients cannot enumerate blobs in the container by using anonymous request. |
|                        |           |  Off: Which restricts access to only the storage account owner.                                                                                                                                                       |
| `FilePrefix`           | no        | The optional prefix to append to the blob content when uploading the file in the targeted directory to Azure Blob Storage.                                                                                           |

**Example**

With existing blob container:

```powershell
PS> Upload-AzFilesToBlobStorage `
-ResourceGroupName "resource-group" `
-StorageAccountName "account-name" `
-TargetFolderPath "./directory" `
-ContainerName "blob-container"
# Uploaded the file [file] to Azure Blob storage container: [Blob URL]
```

With non-existing blob container:

```powershell
PS> Upload-AzFilesToBlobStorage `
-ResourceGroupName "resource-group" `
-StorageAccountName "account-name" `
-TargetFolderPath "./directory" `
-ContainerName "blob-container"
# Uploaded the file [file\ to Azure Blob storage container: [Blob URL]
```
