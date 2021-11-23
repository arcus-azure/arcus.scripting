---
title: " Azure DevOps"
layout: default
---

# Azure DevOps

This module provides the following capabilities:
- [Installation](#installation)
- [Setting a variable in an Azure DevOps pipeline](#setting-a-variable-in-an-azure-devops-pipeline)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.DevOps -MaximumVersion 0.1.3
```

## Setting a variable in an Azure DevOps pipeline

Assign a value to a DevOps pipeline variable during the execution of this pipeline.

| Parameter       | Mandatory | Description                                       |
| --------------- | --------- | ------------------------------------------------- |
| `Name`          | yes       | The name of the variable to set in the pipeline   |
| `Value`         | yes       | The value of the variable to set in the pipeline  |

**Example**

```powershell
PS> Set-AzDevOpsVariable "my-variable" "my-variable-value"
# #vso[task.setvariable variable=my-variable] my-variable-value
```
