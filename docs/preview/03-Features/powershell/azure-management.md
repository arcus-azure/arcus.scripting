---
title: "Azure Management"
layout: default
---

# Azure Management

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.Management
```

## Removing a soft deleted API Management instance

Removes a soft deleted API Management instance. 
For more information on API Management and soft deletion see [here](https://docs.microsoft.com/en-us/azure/api-management/soft-delete#soft-delete-behavior).

| Parameter        | Mandatory | Description                                                                                                |
| ---------------- | --------- | ---------------------------------------------------------------------------------------------------------- |
| `Name`           | yes       | The name of the API Management instance that has been soft deleted.                                        |
| `SubscriptionId` | no        | The Id of the subscription containing the Azure API Management instance.                                   |
|                  |           | When not provided, it will be retrieved from the current context (Get-AzContext).                          |
| `EnvironmentName`| no        | The name of the Azure environment where the Azure API Management instance resides. (default: `AzureCloud`) |
| `AccessToken`    | no        | The access token to be used to remove the Azure API Management instance.                                   |
|                  |           | When not provided, it will be retrieved from the current context (Get-AzContext).                          |
| `ApiVersion `    | no        | The version of the management API to be used.  (default: `2022-08-01`)                                     |

> :bulb: The `ApiVersion` has successfully been tested with version `2021-08-01`.

**Example**
```powershell
PS> Remove-AzApiManagementSoftDeletedService -Name "my-apim"
# Successfully removed the soft deleted Azure API Management service 'my-apim'
```

## Restoring a soft deleted API Management instance

Restores a soft deleted API Management instance. 
For more information on API Management and soft deletion see [here](https://docs.microsoft.com/en-us/azure/api-management/soft-delete#soft-delete-behavior).

| Parameter        | Mandatory | Description                                                                                                |
| ---------------- | --------- | ---------------------------------------------------------------------------------------------------------- |
| `Name`           | yes       | The name of the API Management instance that has been soft deleted.                                        |
| `SubscriptionId` | no        | The Id of the subscription containing the Azure API Management instance.                                   |
|                  |           | When not provided, it will be retrieved from the current context (Get-AzContext).                          |
| `EnvironmentName`| no        | The name of the Azure environment where the Azure API Management instance resides. (default: `AzureCloud`) |
| `AccessToken`    | no        | The access token to be used to restore the Azure API Management instance.                                  |
|                  |           | When not provided, it will be retrieved from the current context (Get-AzContext).                          |
| `ApiVersion `    | no        | The version of the management API to be used.  (default: `2022-08-01`)                                     |

> :bulb: The `ApiVersion` has successfully been tested with version `2021-08-01`.

**Example**
```powershell
PS> Restore-AzApiManagementSoftDeletedService -Name "my-apim"
# Successfully restored the soft deleted API Management service 'my-apim'
```
