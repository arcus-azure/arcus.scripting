---
title: " Azure security"
layout: default
---

# Azure Security

This module provides the following capabilities:
- [Removing resource locks from an Azure resource group](#removing-resource-locks-from-an-azure-resource-group)
- [Retrieve the current Az Access token](#retrieve-the-current-az-access-token)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Import-Module -Name Arcus.Scripting.Security -MinimumVersion 0.3.0
```

## Removing resource locks from an Azure resource group

In some deployments resource-locks are being assigned. To help in removing these quickly, we have provided you with a function that removes all the existing locks on the resource group.

While this seems dangerous, only users with sufficient access rights are allowed to delete locks.

| Parameter           | Mandatory | Description                                                                                       |
| ------------------- | --------- | ------------------------------------------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The name of the resource group where the locks should be removed                                  |
| `LockName`          | no        | The optional name of the lock to remove. When this is not provided, all the locks will be removed |

**Usage*

When you want to remove all the resource locks, no matter what the name or the sub-location:

```powershell
PS> Remove-AzResourceGroupLocks -ResourceGroupName "your-resource-group-name"
# Retrieving all locks in resourceGroup 'your-resource-group-name'
# Start removing all locks in resourceGroup 'your-resource-group-name'
# All locks in resourceGroup 'your-resource-group-name' have been removed
```

When you want to remove a specific resource lock, with a given name:

```powershell
PS> Remove-AzResourceGroupLocks -ResourceGroupName "your-resource-group-name" -LockName "your-resource-lock-name"
# Retrieving all locks in resourceGroup 'your-resource-group-name' with name 'your-resource-lock-name'
# Start removing all locks in resourceGroup 'your-resource-group-name'
# All locks in resourceGroup 'your-resource-group-name' have been removed
```


## Retrieve the current Az Access token  

When you want to make use of the REST-API's made available to manage Azure Resources, you can use this command to easily retrieve the access-token which is stored in your cache after performing the `Connect-AzAccount` command.  

| Parameter               | Mandatory | Description                                                                                       |
| ----------------------- | --------- | ------------------------------------------------------------------------------------------------- |
| `AssignGlobalVariables` | no        | Switch - default value: false                                                                     |
|                         |           | When you want the global variables `access_token` and `subscriptionId` assigned for easy access.  |

**Usage*

When you want to retrieve the current access-token, after connecting to a specific subscription:

```powershell
PS> $token = Get-AzCachedAccessToken
# AccessToken and subscriptionId retrieved
PS> Write-Host "Current SubscriptionId:" $token.SubscriptionId
# Current SubscriptionId: b1a8131b-35fb-4d49-b77b-11abd21c9dcb
PS> Write-Host "Current AccessToken:" $token.AccessToken
# Current AccessToken: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

When you want to retrieve the current access-token, after connecting to a specific subscription and assign them to global variables for easy access:

```powershell
PS> $token = Get-AzCachedAccessToken -AssignGlobalVariables
# AccessToken and subscriptionId retrieved
PS> Write-Host "Current SubscriptionId:" $Global:subscriptionId
# Current SubscriptionId: b1a8131b-35fb-4d49-b77b-11abd21c9dcb
PS> Write-Host "Current AccessToken:" $Global:accessToken
# Current AccessToken: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```
