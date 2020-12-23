---
title: "Scripts related to Azure security"
layout: default
---

# Azure Security

This module provides the following capabilities:
- [Removing resource locks from an Azure resource group](#removing-resource-locks-from-an-azure-resource-group)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Import-Module -Name Arcus.Scripting.Security
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
