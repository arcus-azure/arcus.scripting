---
title: " Azure Data Factory"
layout: default
---

# Azure Data Factory

This module provides the following capabilities:
- [Enabling a trigger of an Azure Data Factory pipeline](#enabling-a-trigger-of-an-azure-data-factory-pipeline)
- [Disabling a trigger of an Azure Data Factory pipeline](#disabling-a-trigger-of-an-azure-data-factory-pipeline)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.DataFactory -RequiredVersion 0.4.3
```

## Enabling a trigger of an Azure Data Factory pipeline

Enable a Data Factory V2 Trigger.

| Parameter                   | Mandatory | Description                                                                              |
| --------------------------- | --------- | ---------------------------------------------------------------------------------------- |
| `ResourceGroupName`         | yes       | The resource group containing the Azure Data Factory V2                                  |
| `DataFactoryName`           | yes       | The name of the Azure Data Factory V2                                                    |
| `DataFactoryTriggerName`    | yes       | The name of the trigger to be enabled                                                    |
| `FailWhenTriggerIsNotFound` | no        | Indicate whether to throw an exception if the trigger cannot be found (default: `false`) |

**Example**

```powershell
PS> Enable-AzDataFactoryTrigger -ResourceGroupName "my-resource-group" -DataFactoryName "my-data-factory-name" -DataFactoryTriggerName "my-data-factory-trigger-name"
# The trigger 'my-data-factory-trigger-name' has been enabled.
```

```powershell
PS> Enable-AzDataFactoryTrigger -ResourceGroupName "my-resouce-group" -DataFactoryName "my-data-factory-name" -DataFactoryTriggerName "unknown-data-factory-trigger-name" -FailWhenTriggerIsNotFound
# Error: Error retrieving trigger 'unknown-data-factory-trigger-name' in data factory 'my-data-factory'.
```


## Disabling a trigger of an Azure Data Factory pipeline

Disable a Data Factory V2 Trigger.

| Parameter                   | Mandatory | Description                                                                              |
| --------------------------- | --------- | ---------------------------------------------------------------------------------------- |
| `ResourceGroupName`         | yes       | The resource group containing the Azure Data Factory V2                                  |
| `DataFactoryName`           | yes       | The name of the Azure Data Factory V2                                                    |
| `DataFactoryTriggerName`    | yes       | The name of the trigger to be disabled                                                   |
| `FailWhenTriggerIsNotFound` | no        | Indicate whether to throw an exception if the trigger cannot be found (default: `false`) |

**Example**

```powershell
PS> Disable-AzDataFactoryTrigger -ResourceGroupName "my-resource-group" -DataFactoryName "my-data-factory-name" -DataFactoryTriggerName "my-data-factory-trigger-name"
# The trigger 'my-data-factory-trigger-name' has been disabled.
```

```powershell
PS> Disable-AzDataFactoryTrigger -ResourceGroupName "my-resouce-group" -DataFactoryName "my-data-factory-name" -DataFactoryTriggerName "unknown-data-factory-trigger-name" -FailWhenTriggerIsNotFound
# Error: Error retrieving trigger 'unknown-data-factory-trigger-name' in data factory 'my-data-factory'.
```
