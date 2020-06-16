---
title: "Scripts related to interacting with Azure Data Factory"
layout: default
---

# Azure Data Factory

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Import-Module -Name Arcus.Scripting.DataFactory
```

## Enable the trigger of a Azure Data Factory

Enable a Data Factory V2 Trigger.

| Parameter                   | Mandatory | Description                                                                              |
| --------------------------- | --------- | ---------------------------------------------------------------------------------------- |
| `ResourceGroupName`         | yes       | The resource group containing the Azure Data Factory V2                                  |
| `DataFactoryName`           | yes       | The name of the Azure Data Factory V2                                                    |
| `DataFactoryTriggerName`    | yes       | The name of the trigger to be enabled                                                    |
| `FailWhenTriggerIsNotFound` | no        | Indicate whether to throw an exception if the trigger cannot be found (default: `false`) |

**Example**

```powershell
PS> Start-AzDataFactoryTrigger -ResourceGroupName "my-resource-group" -DataFactoryName "my-data-factory-name" -DataFactoryTriggerName "my-data-factory-trigger-name"
# The trigger 'my-data-factory-trigger-name' has been enabled.
```

```powershell
PS> Start-AzDataFactoryTrigger -ResourceGroupName "my-resouce-group" -DataFactoryName "my-data-factory-name" -DataFactoryTriggerName "unknown-data-factory-trigger-name" -FailWhenTriggerIsNotFound
# Error: Error retrieving trigger 'unknown-data-factory-trigger-name' in data factory 'my-data-factory'.
```


## Disable the trigger of a Azure Data Factory

Disable a Data Factory V2 Trigger.

| Parameter                   | Mandatory | Description                                                                              |
| --------------------------- | --------- | ---------------------------------------------------------------------------------------- |
| `ResourceGroupName`         | yes       | The resource group containing the Azure Data Factory V2                                  |
| `DataFactoryName`           | yes       | The name of the Azure Data Factory V2                                                    |
| `DataFactoryTriggerName`    | yes       | The name of the trigger to be disabled                                                   |
| `FailWhenTriggerIsNotFound` | no        | Indicate whether to throw an exception if the trigger cannot be found (default: `false`) |

**Example**

```powershell
PS> Stop-AzDataFactoryTrigger -ResourceGroupName "my-resource-group" -DataFactoryName "my-data-factory-name" -DataFactoryTriggerName "my-data-factory-trigger-name"
# The trigger 'my-data-factory-trigger-name' has been disabled.
```

```powershell
PS> Stop-AzDataFactoryTrigger -ResourceGroupName "my-resouce-group" -DataFactoryName "my-data-factory-name" -DataFactoryTriggerName "unknown-data-factory-trigger-name" -FailWhenTriggerIsNotFound
# Error: Error retrieving trigger 'unknown-data-factory-trigger-name' in data factory 'my-data-factory'.
```
