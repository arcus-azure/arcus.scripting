---
title: "Azure API Management"
layout: default
---

# Azure API Management

This module provides the following capabilities:
- [Azure API Management](#azure-api-management)
  - [Installation](#installation)
  - [Backing up an API Management service](#backing-up-an-api-management-service)
  - [Creating a new API operation in the Azure API Management instance](#creating-a-new-api-operation-in-the-azure-api-management-instance)
  - [Creating a new user in an Azure API Management service](#creating-a-new-user-in-an-azure-api-management-service)
  - [Importing a policy to an API in the Azure API Management instance](#importing-a-policy-to-an-api-in-the-azure-api-management-instance)
  - [Importing a policy to an operation in the Azure API Management instance](#importing-a-policy-to-an-operation-in-the-azure-api-management-instance)
  - [Removing all Azure API Management defaults from the instance](#removing-all-azure-api-management-defaults-from-the-instance)
  - [Restoring an API Management service](#restoring-an-api-management-service)
  - [Setting authentication keys to an API in the Azure API Management instance](#setting-authentication-keys-to-an-api-in-the-azure-api-management-instance)
  - [Uploading private certificates to the Azure API Management certificate store](#uploading-private-certificates-to-the-azure-api-management-certificate-store)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.ApiManagement
```

## Backing up an API Management service

Backs up an API Management service (with built-in storage context retrieval).

| Parameter                         | Mandatory | Description                                                                                                                                                      |
| --------------------------------- | --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`               | yes       | The name of the of resource group under which the API Management deployment exists.                                                                              |
| `StorageAccountResourceGroupName` | yes       | The name of the resource group under which the storage account exists.                                                                                           |
| `StorageAccountName`              | yes       | The name of the Storage account for which this cmdlet gets keys.                                                                                                 |
| `ServiceName`                     | yes       | The name of the API Management deployment that this cmdlet backs up.                                                                                             |
| `ContainerName`                   | yes       | The name of the container of the blob for the backup. If the container does not exist, this cmdlet creates it.                                                   |
| `BlobName`                        | no        | The name of the blob for the backup. If the blob does not exist, this cmdlet creates it (default value based on pattern: `{Name}-{yyyy-MM-dd-HH-mm}.apimbackup`. |
| `PassThru`                        | no        | Indicates that this cmdlet returns the backed up PsApiManagement object, if the operation succeeds.                                                              |
| `DefaultProfile`                  | no        | The credentials, account, tenant, and subscription used for communication with azure.                                                                            |

**Example**

Simplest way to back up an API Management service.

```powershell
PS> Backup-AzApiManagementService -ResourceGroupName "my-resource-group" -StorageAccountResourceGroupName "my-storage-account-resource-group" -StorageAccountName "my-storage-account" -ServiceName "my-service" -ContainerName "my-target-blob-container"
# Getting Azure storage account key..
# Got Azure storage key!
# Create new Azure storage context with storage key...
# New Azure storage context with storage key created!
# Start backing up API management service...
# API management service is backed-up!
```

## Creating a new API operation in the Azure API Management instance

Create an operation on an existing API in Azure API Management.

| Parameter           | Mandatory | Description                                                                                              |
| ------------------- | --------- | -------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management instance                                          |
| `ServiceName`       | yes       | The name of the Azure API Management instance located in Azure                                           |
| `ApiId`             | yes       | The ID to identify the API running in Azure API Management                                               |
| `OperationId`       | yes       | The ID to identify the to-be-created operation on the API                                                |
| `Method`            | yes       | The method of the to-be-created operation on the API                                                     |
| `UrlTemplate`       | yes       | The URL-template, or endpoint-URL, of the to-be-created operation on the API                             |
| `OperationName`     | no        | The optional descriptive name to give to the to-be-created operation on the API (default: `OperationId`) |
| `Description`       | no        | The optional explanation to describe the to-be-created operation on the API                              |
| `PolicyFilePath`    | no        | The path to the file containing the optional policy of the to-be-created operation on the API            |

**Example**

Creates a new API operation on the Azure API Management instance with using the default base operation policy.

```powershell
PS> Create-AzApiManagementApiOperation -ResourceGroupName $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -OperationId $OperationId -Method $Method -UrlTemplate $UrlTemplate
# New API operation '$OperationName' on Azure API Management instance was added.
```

Creates a new API operation on the Azure API Management instance with using a specific operation policy.

```powershell
PS> Create-AzApiManagementApiOperation -ResourceGroupName $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -OperationId $OperationId -Method $Method -UrlTemplate $UrlTemplate -OperationName $OperationName -Description $Description -PolicyFilePath $PolicyFilePath
# New API operation '$OperationName' on API Management instance was added.
```	

## Creating a new user in an Azure API Management service

Signup or invite a new user in an existing Azure API Management instance.

| Parameter           | Mandatory | Description                                                                                                                                                         |
| ------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management instance                                                                                                     |
| `ServiceName`       | yes       | The name of the Azure API Management instance located in Azure                                                                                                      |
| `FirstName`         | yes       | The first name of the user that is to be created                                                                                                                    |
| `LastName`          | yes       | The last name of the user that is to be created                                                                                                                     |
| `MailAddress`       | yes       | The email address of the user that is to be created                                                                                                                 |
| `UserId`            | no        | The UserId that will be used to create the user                                                                                                                     |
| `Password`          | no        | The password that the user will be able to login with                                                                                                               |
| `Note`              | no        | A note that will be added to the user                                                                                                                               |
| `SendNotification`  | no        | Wether or not a notification will be sent to the email address of the user                                                                                          |
| `ConfirmationType`  | no        | The confirmation type that will be used when creating the user, this can be `invite` (default) or `signup`                                                          |
| `ApiVersion`        | no        | The version of the management API to be used.  (default: `2021-08-01`)                                                                                              |
| `SubscriptionId`    | no        | The Id of the subscription containing the Azure API Management instance. When not provided, it will be retrieved from the current context (Get-AzContext).          |
| `AccessToken`       | no        | The access token to be used to add the user to the Azure API Management instance. When not provided, it will be retrieved from the current context (Get-AzContext). |

**Example**

Invite a new user in an existing Azure API Management instance.

```powershell
PS> Create-AzApiManagementUser -ResourceGroupName $ResourceGroup -ServiceName $ServiceName -FirstName $FirstName -LastName $LastName -MailAddress $MailAddress
# Attempting to invite $FirstName $LastName ($MailAddress)
# Invitation has been sent to FirstName $LastName ($MailAddress)
```

Invite a new user in an existing Azure API Management instance and specify a UserId.

```powershell
PS> Create-AzApiManagementUser -ResourceGroupName $ResourceGroup -ServiceName $ServiceName -FirstName $FirstName -LastName $LastName -MailAddress $MailAddress -UserId $UserId
# Attempting to invite $FirstName $LastName ($MailAddress)
# Invitation has been sent to FirstName $LastName ($MailAddress)
```

Invite a new user in an existing Azure API Management instance and include a note.

```powershell
PS> Create-AzApiManagementUser -ResourceGroupName $ResourceGroup -ServiceName $ServiceName -FirstName $FirstName -LastName $LastName -MailAddress $MailAddress -Note $Note
# Attempting to invite $FirstName $LastName ($MailAddress)
# Invitation has been sent to FirstName $LastName ($MailAddress)
```

Invite a new user in an existing Azure API Management instance and send a notification.

```powershell
PS> Create-AzApiManagementUser -ResourceGroupName $ResourceGroup -ServiceName $ServiceName -FirstName $FirstName -LastName $LastName -MailAddress $MailAddress -SendNotification
# Attempting to invite $FirstName $LastName ($MailAddress)
# Invitation has been sent to FirstName $LastName ($MailAddress)
```

Signup a new user in an existing Azure API Management instance.

```powershell
PS> Create-AzApiManagementUser -ResourceGroupName $ResourceGroup -ServiceName $ServiceName -FirstName $FirstName -LastName $LastName -MailAddress $MailAddress -ConfirmationType signup
# Attempting to create account for FirstName $LastName ($MailAddress)
# Account has been created for FirstName $LastName ($MailAddress)
# Since no password was provided, one has been generated. Please advise the user to change this password the first time logging in
```

Signup a new user in an existing Azure API Management instance and specify a password.

```powershell
PS> Create-AzApiManagementUser -ResourceGroupName $ResourceGroup -ServiceName $ServiceName -FirstName $FirstName -LastName $LastName -MailAddress $MailAddress -Password $Password -ConfirmationType signup
# Attempting to create account for FirstName $LastName ($MailAddress)
# Account has been created for FirstName $LastName ($MailAddress)
```

## Importing a policy to a product in the Azure API Management instance

Imports a policy from a file to a product in Azure API Management.

| Parameter           | Mandatory | Description                                                     |
| ------------------- | --------- | --------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management instance |
| `ServiceName`       | yes       | The name of the Azure API Management instance located in Azure  |
| `ProductId`         | yes       | The ID to identify the product in Azure API Management          |
| `PolicyFilePath`    | yes       | The path to the file containing the to-be-imported policy       |

```powershell
PS> Import-AzApiManagementProductPolicy -ResourceGroupName $ResourceGroup -ServiceName $ServiceName -ProductId $ProductId -PolicyFilePath $PolicyFilePath
# Updating policy of the product '$ProductId'
```

## Importing a policy to an API in the Azure API Management instance

Imports a base-policy from a file to an API in Azure API Management.

| Parameter           | Mandatory | Description                                                      |
| ------------------- | --------- | ---------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management instance  |
| `ServiceName`       | yes       | The name of the Azure API Management instance located in Azure   |
| `ApiId`             | yes       | The ID to identify the API running in Azure API Management       |
| `PolicyFilePath`    | yes       | The path to the file containing the to-be-imported policy        |

```powershell
PS> Import-AzApiManagementApiPolicy -ResourceGroupName $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -PolicyFilePath $PolicyFilePath
# Updating policy of the API '$ApiId'
```

## Importing a policy to an operation in the Azure API Management instance

Imports a policy from a file to an API operation in Azure API Management.

| Parameter           | Mandatory | Description                                                     |
| ------------------- | --------- | --------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management instance |
| `ServiceName`       | yes       | The name of the Azure API Management service located in Azure   |
| `ApiId`             | yes       | The ID to identify the API running in Azure API Management      |
| `OperationId`       | yes       | The ID to identify the operation for which to import the policy |
| `PolicyFilePath`    | yes       | The path to the file containing the to-be-imported policy       |   

```powershell
PS> Import-AzApiManagementOperationPolicy -ResourceGroupName $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -OperationId $OperationId -PolicyFilePath $PolicyFilePath
# Updating policy of the operation '$OperationId' in API '$ApiId'
```

## Removing all Azure API Management defaults from the instance

Remove all default API's and products from the Azure API Management instance ('echo-api' API, 'starter' & 'unlimited' products), including the subscriptions.

| Parameter           | Mandatory | Description                                                     |
| ------------------- | --------- | --------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management instance |
| `ServiceName`       | yes       | The name of the Azure API Management instance located in Azure  |

```powershell
PS> Remove-AzApiManagementDefaults -ResourceGroupName $ResourceGroup -ServiceName $ServiceName
# Removing Echo Api...
# Removing Starter product...
# Removing Unlimited product...
```

## Restoring an API Management service

The Restore-AzApiManagement cmdlet restores an API Management Service from the specified backup residing in an Azure Storage blob.

| Parameter                         | Mandatory | Description                                                                                                               |
| --------------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`               | yes       | The name of resource group under which API Management exists.                                                             |
| `StorageAccountResourceGroupName` | yes       | The name of the resource group that contains the Storage account.                                                         |
| `StorageAccountName`              | yes       | The name of the Storage account for which this cmdlet gets keys.                                                          |
| `ServiceName`                     | yes       | The name of the API Management instance that will be restored with the backup.                                            |
| `ContainerName`                   | yes       | The name of the Azure storage backup source container.                                                                    |
| `BlobName`                        | yes       | The name of the Azure storage backup source blob.                                                                         |
| `PassThru`                        | no        | Returns an object representing the item with which you are working. By default, this cmdlet does not generate any output. |
| `DefaultProfile`                  | no        | The credentials, account, tenant, and subscription used for communication with azure.                                     |

```powershell
PS> Restore-AzApiManagementService -ResourceGroupName $ResourceGroupName -$StorageAccountResourceGroupName -StorageAccountName $StorageAccountName -ServiceName $ServiceName -ContainerName $ContainerName -BlobName $BlobName
# Getting Azure storage account key...
# Got Azure storage key!
# Create new Azure storage context with storage key...
# New Azure storage context with storage key created!
# Start restoring up API management service...
# API management service is restored!
```

## Setting authentication keys to an API in the Azure API Management instance

Sets the subscription header/query parameter name to an API in Azure API Management.

| Parameter           | Mandatory | Description                                                                                   |
| ------------------- | --------- | --------------------------------------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management instance                               |
| `ServiceName`       | yes       | The name of the Azure API Management instance located in Azure                                |
| `ApiId`             | yes       | The ID to identify the API running in Azure API Management                                    |
| `HeaderName`        | no        | The name of the header where the subscription key should be set. (default: `x-api-key`)       |
| `QueryParamName`    | no        | The name of the query parameter where the subscription key should be set. (default: `apiKey`) |

**Using default**

```powershell
PS> Set-AzApiManagementApiSubscriptionKey -ResourceGroupName $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId
Write-Host "Using API Management instance '$ServiceName' in resource group '$ResourceGroup'"
Write-Host "Subscription key header 'x-api-key' was assigned"
Write-Host "Subscription key query parameter 'apiKey' was assigned"
```

**User-defined values**

```powershell
PS> Set-AzApiManagementApiSubscriptionKey -ResourceGroupName $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -HeaderName "my-api-key" -QueryParamName "myApiKey"
Write-Host "Using API Management instance '$ServiceName' in resource group '$ResourceGroup'"
Write-Host "Subscription key header 'my-api-key' was assigned"
Write-Host "Subscription key query parameter 'myApiKey' was assigned"
```

## Uploading private certificates to the Azure API Management certificate store

Uploads a private certificate to the Azure API Management certificate store, allowing authentication against backend services.

| Parameter             | Mandatory | Description                                                                                   |
| --------------------- | --------- | --------------------------------------------------------------------------------------------- |
| `ResourceGroupName`   | yes       | The resource group containing the Azure API Management instance                               |
| `ServiceName`         | yes       | The name of the Azure API Management instance                                                 |
| `CertificateFilePath` | yes       | The full file path to the location of the private certificate                                 |
| `CertificatePassword` | yes       | The password for the private certificate                                                      |

**Example**

```powershell
PS> Upload-AzApiManagementCertificate -ResourceGroupName "my-resource-group" -ServiceName "my-api-management-instance' -CertificateFilePath "c:\temp\certificate.pfx" -CertificatePassword "P@ssw0rd"
# Using API Management instance 'my-api-management-instance' in resource group 'my-resource-group'
# Uploaded private certificate at 'c:\temp\certificate.pfx'
```
