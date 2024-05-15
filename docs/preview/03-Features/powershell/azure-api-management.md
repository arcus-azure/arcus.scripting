---
title: "Azure API Management"
layout: default
---

# Azure API Management

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.ApiManagement
```

## Backing up an API Management service

Backs up an API Management service (with built-in storage context retrieval).

| Parameter                         | Mandatory | Description                                                                                                                                                             |
| --------------------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`               | yes       | The name of the of resource group under which the API Management deployment exists.                                                                                     |
| `StorageAccountResourceGroupName` | yes       | The name of the resource group under which the storage account exists.                                                                                                  |
| `StorageAccountName`              | yes       | The name of the Storage account for which this cmdlet gets keys.                                                                                                        |
| `ServiceName`                     | yes       | The name of the API Management deployment that this cmdlet backs up.                                                                                                    |
| `ContainerName`                   | yes       | The name of the container of the blob for the backup. If the container does not exist, this cmdlet creates it.                                                          |
| `AccessType`                      | yes       | The type of access to be used for the connection from APIM to the storage account, valid values are `SystemAssignedManagedIdentity` and `UserAssignedManagedIdentity`.  |
| `IdentityClientId`                | no        | The client id of the managed identity to connect from API Management to Storage Account, this is only required when AccessType is set to `UserAssignedManagedIdentity`. |
| `BlobName`                        | no        | The name of the blob for the backup. If the blob does not exist, this cmdlet creates it (default value based on pattern: `{Name}-{yyyy-MM-dd-HH-mm}.apimbackup`.        |
| `PassThru`                        | no        | Indicates that this cmdlet returns the backed up PsApiManagement object, if the operation succeeds.                                                                     |
| `DefaultProfile`                  | no        | The credentials, account, tenant, and subscription used for communication with azure.                                                                                   |

**Example**

Simplest way to back up an API Management service.

```powershell
PS> Backup-AzApiManagementService `
-ResourceGroupName "my-resource-group" `
-StorageAccountResourceGroupName "my-storage-account-resource-group" `
-StorageAccountName "my-storage-account" `
-ServiceName "my-service" `
-ContainerName "my-target-blob-container" `
-AccessType "SystemAssignedManagedIdentity"
# New Azure storage context for storage account 'my-storage-account' with storage key created!
# Azure API management service 'my-service' in resource group 'my-resource-group' is backed-up!
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
PS> Create-AzApiManagementApiOperation `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-ApiId $ApiId `
-OperationId $OperationId `
-Method $Method `
-UrlTemplate $UrlTemplate
# New API operation '$OperationName' was added on Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
```

Creates a new API operation on the Azure API Management instance with using a specific operation policy.

```powershell
PS> Create-AzApiManagementApiOperation `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-ApiId $ApiId `
-OperationId $OperationId `
-Method $Method `
-UrlTemplate $UrlTemplate `
-OperationName $OperationName `
-Description $Description `
-PolicyFilePath $PolicyFilePath
# New API operation '$OperationName' was added on Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
# Updated policy of the operation '$OperationId' in API '$ApiId' of the Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
```	

## Creating a new user in an Azure API Management service

Sign-up or invite a new user in an existing Azure API Management instance.

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
| `ApiVersion`        | no        | The version of the management API to be used. (default: `2021-08-01`)                                                                                               |
| `SubscriptionId`    | no        | The Id of the subscription containing the Azure API Management instance. When not provided, it will be retrieved from the current context (Get-AzContext).          |
| `AccessToken`       | no        | The access token to be used to add the user to the Azure API Management instance. When not provided, it will be retrieved from the current context (Get-AzContext). |

**Example**

Invite a new user in an existing Azure API Management instance.

```powershell
PS> Create-AzApiManagementUserAccount `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-FirstName $FirstName `
-LastName $LastName `
-MailAddress $MailAddress
# Invitation has been sent to $FirstName $LastName ($mailAddress) for Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
```

Invite a new user in an existing Azure API Management instance and specify a UserId.

```powershell
PS> Create-AzApiManagementUserAccount `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-FirstName $FirstName `
-LastName $LastName `
-MailAddress $MailAddress `
-UserId $UserId
# Invitation has been sent to $FirstName $LastName ($mailAddress) for Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
```

Invite a new user in an existing Azure API Management instance and include a note.

```powershell
PS> Create-AzApiManagementUserAccount `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-FirstName $FirstName `
-LastName $LastName `
-MailAddress $MailAddress `
-Note $Note
# Invitation has been sent to $FirstName $LastName ($mailAddress) for Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
```

Invite a new user in an existing Azure API Management instance and send a notification.

```powershell
PS> Create-AzApiManagementUserAccount `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-FirstName $FirstName `
-LastName $LastName `
-MailAddress $MailAddress `
-SendNotification
# Invitation has been sent to $FirstName $LastName ($mailAddress) for Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
```

Signup a new user in an existing Azure API Management instance.

```powershell
PS> Create-AzApiManagementUserAccount `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-FirstName $FirstName `
-LastName $LastName `
-MailAddress $MailAddress `
-ConfirmationType signup
# Account has been created for $FirstName $LastName ($mailAddress) for Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
# Since no password was provided, one has been generated. Please advise the user to change this password the first time logging in
```

Signup a new user in an existing Azure API Management instance and specify a password.

```powershell
PS> Create-AzApiManagementUserAccount `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-FirstName $FirstName `
-LastName $LastName `
-MailAddress $MailAddress `
-Password $Password `
-ConfirmationType signup
# Account has been created for $FirstName $LastName ($mailAddress) for Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
```

## Applying user configuration to an Azure API Management service from a configuration file

Apply user configuration to an existing Azure API Management instance. You can create or update users and assign groups and/or subscriptions to these users.

| Parameter                         | Mandatory | Description                                                                                                                                                         |
| --------------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`               | yes       | The resource group containing the Azure API Management instance                                                                                                     |
| `ServiceName`                     | yes       | The name of the Azure API Management instance located in Azure                                                                                                      |
| `ConfigurationFile`               | yes       | Path to the JSON Configuration file containing the user configuration                                                                                               |
| `StrictlyFollowConfigurationFile` | no        | The switch to indicate whether the configuration file should strictly be followed, for example remove the user from groups not defined in the configuration file    |
| `ApiVersion`                      | no        | The version of the management API to be used. (default: `2021-08-01`)                                                                                               |
| `SubscriptionId`                  | no        | The Id of the subscription containing the Azure API Management instance. When not provided, it will be retrieved from the current context (Get-AzContext).          |
| `AccessToken`                     | no        | The access token to be used to add the user to the Azure API Management instance. When not provided, it will be retrieved from the current context (Get-AzContext). |

**Configuration File**

The configuration file is a simple JSON file that contains the users that need to be created or updated, the JSON file consists of an array of JSON objects.


 The file needs to adhere to the following JSON schema.

 <details>

  <summary>Configuration File</summary>

``` json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://scripting.arcus-azure.net/Features/powershell/azure-api-management/config.json",
  "type": "array",
  "title": "The configuration JSON schema",
  "$defs": {},
  "prefixItems": [{
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "firstName": {
          "type": "string"
        },
        "lastName": {
          "type": "string"
        },
        "userId": {
          "type": "string"
        },
        "mailAddress": {
          "type": "string"
        },
        "sendNotification": {
          "type": "boolean"
        },
        "confirmationType": {
          "type": "string",
          "enum": ["signup", "invite"]
        },
        "note": {
          "type": "string"
        },
        "groups": {
          "type": "array",
          "prefixItems": [{
              "type": "object",
              "additionalProperties": false,
              "properties": {
                "id": {
                  "type": "string"
                },
                "displayName": {
                  "type": "string"
                },
                "description": {
                  "type": "string"
                }
              },
              "required": [
                "id",
                "displayName"
              ]
            }
          ]
        },
        "subscriptions": {
          "type": "array",
          "prefixItems": [{
              "type": "object",
              "additionalProperties": false,
              "properties": {
                "id": {
                  "type": "string"
                },
                "displayName": {
                  "type": "string"
                },
                "scope": {
                  "type": "string"
                },
                "allowTracing": {
                  "type": "boolean"
                }
              },
              "required": [
                "id",
                "displayName",
                "scope",
                "allowTracing"
              ]
            }
          ]
        }
      },
      "required": [
        "firstName",
        "lastName",
        "mailAddress",
        "sendNotification",
        "confirmationType"
      ]
    }
  ]
}
```

</details>

 <details>

  <summary>Example Configuration File</summary>

``` json
[
  {
    "firstName": "John",
    "lastName": "Doe",
    "mailAddress": "john@doe.com",
    "sendNotification": true,
    "confirmationType": "signup",
    "note": "This is an optional note",
    "groups": [
      {
        "id": "SomeGroupId",
        "displayName": "Example Group",
        "description": "This is a example group"
      }
    ],
    "subscriptions": [
      {
        "id": "SomeSubscriptionId",
        "displayName": "Example Subscription",
        "scope": "/products/starter",
        "allowTracing": false
      }
    ]
  },
  {
    "firstName": "Jane",
    "lastName": "Doe",
    "mailAddress": "jane@doe.com",
    "sendNotification": true,
    "confirmationType": "signup",
    "note": "This is an optional note",
    "groups": [
      {
        "id": "SomeGroupId",
        "displayName": "Example Group",
        "description": "This is a example group"
      },
	  {
        "id": "SomeOtherGroupId",
        "displayName": "Another Example Group",
        "description": "This is another example group"
      }
    ],
    "subscriptions": [
      {
        "id": "SomeSubscriptionId",
        "displayName": "Example Subscription",
        "scope": "/products/starter",
        "allowTracing": false
      },
	  {
        "id": "SomeSOtherubscriptionId",
        "displayName": "Another Example Subscription",
        "scope": "/products/starter",
        "allowTracing": false
      }
    ]
  }
]
```

</details>

**Example**

Apply user configuration to an existing Azure API Management instance.

```powershell
PS> Create-AzApiManagementUserAccountsFromConfig `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-ConfigurationFile ".\config.json"
# User configuration has successfully been applied for user with ID 'some-id' to Azure API Management service '$ServiceName' in resource group '$ResourceGroup'
```

Apply user configuration to an existing Azure API Management instance and strictly adhere to the configuration file.

```powershell
PS> Create-AzApiManagementUserAccountsFromConfig `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-ConfigurationFile ".\config.json" `
-StrictlyFollowConfigurationFile
# User configuration has successfully been applied for user with ID 'some-id' to Azure API Management service '$ServiceName' in resource group '$ResourceGroup'
```


## Removing a user from an Azure API Management service

Remove a user from an existing Azure API Management instance based on e-mail address.

| Parameter           | Mandatory | Description                                                                                                                                                         |
| ------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management instance                                                                                                     |
| `ServiceName`       | yes       | The name of the Azure API Management instance located in Azure                                                                                                      |
| `MailAddress`       | yes       | The email address of the user that is to be removed                                                                                                                 |
| `SubscriptionId`    | no        | The Id of the subscription containing the Azure API Management instance. When not provided, it will be retrieved from the current context (Get-AzContext).          |
| `AccessToken`       | no        | The access token to be used to add the user to the Azure API Management instance. When not provided, it will be retrieved from the current context (Get-AzContext). |

**Example**

Remove a user from an existing Azure API Management instance.

```powershell
PS> Remove-AzApiManagementUserAccount `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-MailAddress $MailAddress
# Removed the user account with e-mail '$MailAddress' and ID '1' for the Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
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
PS> Import-AzApiManagementProductPolicy `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-ProductId $ProductId `
-PolicyFilePath $PolicyFilePath
# Successfully updated the product policy for the Azure API Management service $ServiceName in resource group $ResourceGroupName
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
PS> Import-AzApiManagementApiPolicy `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-ApiId $ApiId `
-PolicyFilePath $PolicyFilePath
# Successfully updated API policy for the Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
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
PS> Import-AzApiManagementOperationPolicy `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-ApiId $ApiId `
-OperationId $OperationId `
-PolicyFilePath $PolicyFilePath
# USuccessfully updated the operation policy for the Azure API Management service $ServiceName in resource group $ResourceGroupName
```

## Removing all Azure API Management defaults from the instance

Remove all default API's and products from the Azure API Management instance ('echo-api' API, 'starter' & 'unlimited' products), including the subscriptions.

| Parameter           | Mandatory | Description                                                     |
| ------------------- | --------- | --------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management instance |
| `ServiceName`       | yes       | The name of the Azure API Management instance located in Azure  |

```powershell
PS> Remove-AzApiManagementDefaults `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName
# Removed 'echo' API in the Azure API Management service $ServiceName in resource group $ResourceGroupName
# Removed 'starter' product in the Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
# Removed 'unlimited' product in the Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
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
PS> Restore-AzApiManagementService `
-ResourceGroupName $ResourceGroupName `
-$StorageAccountResourceGroupName `
-StorageAccountName $StorageAccountName `
-ServiceName $ServiceName `
-ContainerName $ContainerName `
-BlobName $BlobName
# Azure API Management service '$ServiceName' in resource group '$ResourceGroupName' is restored!
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
PS> Set-AzApiManagementApiSubscriptionKey `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-ApiId $ApiId
# Using API Management instance '$ServiceName' in resource group '$ResourceGroup'
# Subscription key header 'x-api-key' was assigned
# Subscription key query parameter 'apiKey' was assigned
```

**User-defined values**

```powershell
PS> Set-AzApiManagementApiSubscriptionKey `
-ResourceGroupName $ResourceGroup `
-ServiceName $ServiceName `
-ApiId $ApiId `
-HeaderName "my-api-key" `
-QueryParamName "myApiKey"
# Subscription key header 'my-api-key' was assigned for the Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
# Subscription key query parameter 'myApiKey' was assigned for the Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'
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
PS> Upload-AzApiManagementCertificate `
-ResourceGroupName "my-resource-group" `
-ServiceName "my-api-management-instance" `
-CertificateFilePath "c:\temp\certificate.pfx" `
-CertificatePassword "P@ssw0rd"
# Uploaded private certificate at 'C:\temp\certificate.pfx' for the Azure API Management service 'my-api-management-instance' in resource group 'my-resource-group'
```
