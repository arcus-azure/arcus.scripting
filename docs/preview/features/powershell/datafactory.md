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

## Set the trigger state of an Azure Data Factory

Change the state of a Data Factory V2 Trigger.

| Parameter                   | Mandatory | Description																			     |
| --------------------------- | --------- | ---------------------------------------------------------------------------------------- |
| `Action`		              | yes       | The new state of the trigger: Start/Stop											     |
| `ResourceGroupName`         | yes       | The resource group containing the DataFactory V2									     |
| `DataFactoryName`	          | yes       | The name of the DataFactory V2															 |
| `DataFactoryTriggerName`    | yes       | The name of the trigger to be started/stopped										     |
| `FailWhenTriggerIsNotFound` | no        | Indicate whether to throw an exception if the trigger cannot be found (default: `false`) |

**Example**

```powershell
PS> Set-AzDataFactoryTriggerState -ResourceGroupName "my-resource-group" -DataFactoryName "my-data-factory-name" -DataFactoryTriggerName "my-data-factory-trigger-name" -Action Start
# The trigger 'my-data-factory-trigger-name' has been started.
```

```powershell
PS> Set-AzDataFactoryTriggerState -ResourceGroupName "my-resouce-group" -DataFactoryName "my-data-factory-name" -DataFactoryTriggerName "unknown-data-factory-trigger-name" -Action Start -FailWhenTriggerIsNotFound
# Error: Error retrieving trigger 'unknown-data-factory-trigger-name' in data factory 'my-data-factory'.
```
