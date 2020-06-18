---
title: "Scripts related to interacting with Azure DevOps"
layout: default
---

# Azure DevOps

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Import-Module -Name Arcus.Scripting.DevOps
```

## Set DevOps variable

Assign a value to a DevOps pipeline variable during the execution of this pipeline.

| Parameter       | Madatory | Desciption                                       |
| --------------- | -------- | ------------------------------------------------ |
| `VariableName`  | yes      | The name of the variable to set in the pipeline  |
| `VariableValue` | yes      | The value of the variable to set in the pipeline |

**Example**

```powershell
PS> Set-DevOpsVariable "my-variable" "my-variable-value"
# #vso[task.setvariable variable=my-variable] my-variable-value
```