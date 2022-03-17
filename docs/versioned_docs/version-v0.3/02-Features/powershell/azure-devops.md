---
title: " Azure DevOps"
layout: default
---

# Azure DevOps

This module provides the following capabilities:
- [Azure DevOps](#azure-devops)
  - [Installation](#installation)
  - [Setting a variable in an Azure DevOps pipeline](#setting-a-variable-in-an-azure-devops-pipeline)
  - [Setting ARM outputs to Azure DevOps variable group](#setting-arm-outputs-to-azure-devops-variable-group)
  - [Setting ARM outputs to Azure DevOps pipeline variables](#setting-arm-outputs-to-azure-devops-pipeline-variables)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.DevOps -RequiredVersion 0.3.0
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

## Setting ARM outputs to Azure DevOps variable group

Stores the Azure Resource Management (ARM) outputs in a variable group on Azure DevOps.

| Parameter                           | Mandatory | Description                                                                                             |
| ----------------------------------- | --------- | ------------------------------------------------------------------------------------------------------- |
| `VariableGroupName`                 | yes       | The name of the variable group on Azure DevOps where the ARM outputs should be stored                   |
| `ArmOutputsEnvironmentVariableName` | no        | The name of the environment variable where the ARM outputs are located (default: `ArmOutputs`)          |
| `UpdateVariablesForCurrentJob`      | no        | The switch to also set the variables in the ARM output as pipeline variables in the current running job |

**Example**
Without updating the variables in the current job running the pipeline:

```powershell
PS> Set-AzDevOpsArmOutputsToVariableGroup -VariableGroupName "my-variable-group"
# Get ARM outputs from 'ArmOutputs' environment variable
# Adding variable $output.Name with value $variableValue to variable group my-variable-group
# Retrieving project details
# Set properties for update of existing variable group
```

Include updating the variables in the current job running the pipeline, to immediately make them available to the next pipeline tasks:

```powershell
PS> Set-AzDevOpsArmOutputsToVariableGroup -VariableGroupName "my-variable-group" -UpdateVariablesForCurrentJob
# Get ARM outputs from 'ArmOutputs' environment variable
# Adding variable $output.Name with value $variableValue to variable group my-variable-group
# Retrieving project details
# Set properties for update of existing variable group
# The pipeline variable $variableName will be updated to value $variableValue as well, so it can be used in subsequent tasks of the current job. 
# ##vso[task.setvariable variable=$variableName]$variableValue
```

Include user-defined environment variable for the ARM outputs:

```powershell
PS> Set-AzDevOpsArmOutputsToVariableGroup -VariableGroupName "my-variable-group" -ArmOutputsEnvironmentVariableName "MyArmOutputs"
# Get ARM outputs from 'MyArmOutputs' environment variable
# Adding variable $output.Name with value $variableValue to variable group my-variable-group
# Retrieving project details
# Set properties for update of existing variable group
# The pipeline variable $variableName will be updated to value $variableValue as well, so it can be used in subsequent tasks of the current job. 
```

## Setting ARM outputs to Azure DevOps pipeline variables

Sets the ARM outputs as variables to an Azure DevOps pipeline during the execution of the pipeline.

| Parameter                           | Mandatory | Description                                                                                    |
| ----------------------------------- | --------- | ---------------------------------------------------------------------------------------------- |
| `ArmOutputsEnvironmentVariableName` | no        | The name of the environment variable where the ARM outputs are located (default: `ArmOutputs`) |

**Example**
With default `ArmOutputs` environment variable containing: `"my-variable": "my-value"`:

```powershell
PS> Set-AzDevOpsArmOutputsToPipelineVariables
# Get ARM outputs from 'ArmOutputs' environment variable
# The pipeline variable my-variable will be updated to value my-value, so it can be used in subsequent tasks of the current job. 
# ##vso[task.setvariable variable=my-variable]my-value
```

With custom `MyArmOutputs` environment variable containing: `"my-variable": "my-value"`:

```powershell
PS> Set-AzDevOpsArmOutputsToPipelineVariables -ArmOutputsEnvironmentVariableName "MyArmOutputs"
# Get ARM outputs from 'MyArmOutputs' environment variable
# The pipeline variable my-variable will be updated to value my-value, so it can be used in subsequent tasks of the current job. 
# ##vso[task.setvariable variable=my-variable]my-value
```
