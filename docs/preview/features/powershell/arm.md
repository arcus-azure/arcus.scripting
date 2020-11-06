---
title: "Scripts related to ARM templates"
layout: default
---

# ARM

This module provides the following capabilities:
- [Injecting content into an ARM template](#injecting-content-into-an-arm-template)
- [Removing resource locks on azure](#removing-resource-locks-on-azure)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Import-Module -Name Arcus.Scripting.ARM
```

## Injecting content into an ARM template

In certain scenarios, you have to embed content into an ARM template to deploy it.

However, the downside of it is that it's buried inside the template and tooling around it might be less ideal - An example of this is OpenAPI specifications you'd want to deploy.

By using this script, you can inject external files inside your ARM template.

| Parameter | Mandatory | Description                                                                                     |
| --------- | --------- | ----------------------------------------------------------------------------------------------- |
| `Path`    | no        | The file path to the ARM template to inject the external files into  (default: `$PSScriptRoot`) |

**Usage**
Annotating content to inject:

```json
{
    "type": "Microsoft.ApiManagement/service/apis",
    "name": "[concat(parameters('ApiManagement.Name'),'/', parameters('ApiManagement.Api.Name'))]",
    "apiVersion": "2019-01-01",
    "properties": {
        "subscriptionRequired": true,
        "path": "demo",
        "value": "${ FileToInject='.\\..\\openapi\\api-sample.json', InjectAsJsonObject}$",
        "format": "swagger-json"
    },
    "tags": "[variables('Tags')]",
    "dependsOn": [
    ]
}
```

Injecting the content:

```powershell
PS> Inject-ArmContent -Path deploy\arm-template.json
```

**Recommendations**
Always inject the content in your ARM template as soon as possible, preferably during release build that creates the artifact

## Removing resource locks within an Azure Resource Group

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
