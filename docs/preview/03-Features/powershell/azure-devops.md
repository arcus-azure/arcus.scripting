---
title: " Azure DevOps"
layout: default
---

# Azure DevOps

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
PS> Install-Module -Name Arcus.Scripting.DevOps -Repository PSGallery -AllowClobber
```

## Setting a variable in an Azure DevOps pipeline

Assign a value to a DevOps pipeline variable during the execution of this pipeline.

| Parameter             | Mandatory | Description                                       |
| --------------------- | --------- | ------------------------------------------------- |
| `Name`                | yes       | The name of the variable to set in the pipeline   |
| `Value`               | yes       | The value of the variable to set in the pipeline  |
| `AsSecret`            | no        | The switch to set the variable as a secret        |

**Example**

Setting a variable:

```powershell
PS> Set-AzDevOpsVariable "my-variable" "my-variable-value"
##vso[task.setvariable variable=my-variable] my-variable-value
```

Setting a variable as a secret:

```powershell
PS> Set-AzDevOpsVariable "my-variable" "my-variable-value" -AsSecret
##vso[task.setvariable variable=my-variable;issecret=true] ***
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
PS> Set-AzDevOpsArmOutputsToVariableGroup `
-VariableGroupName "my-variable-group" `
-UpdateVariablesForCurrentJob
# Get ARM outputs from 'ArmOutputs' environment variable
# Adding variable $output.Name with value $variableValue to variable group my-variable-group
# Retrieving project details
# Set properties for update of existing variable group
# The pipeline variable $variableName will be updated to value $variableValue as well, so it can be used in subsequent tasks of the current job. 
# ##vso[task.setvariable variable=$variableName]$variableValue
```

Include user-defined environment variable for the ARM outputs:

```powershell
PS> Set-AzDevOpsArmOutputsToVariableGroup `
-VariableGroupName "my-variable-group" `
-ArmOutputsEnvironmentVariableName "MyArmOutputs"
# Get ARM outputs from 'MyArmOutputs' environment variable
# Adding variable $output.Name with value $variableValue to variable group my-variable-group
# Retrieving project details
# Set properties for update of existing variable group
# The pipeline variable $variableName will be updated to value $variableValue as well, so it can be used in subsequent tasks of the current job. 
```

**Azure DevOps Example**
This function is intended to be used from an Azure DevOps pipeline. Internally, it uses some predefined Azure DevOps variables.
One of the environment variables that is used, is the `SYSTEM_ACCESSTOKEN` variable. However, due to safety reasons this variable is not available out-of-the box.
To be able to use this variable, it must be explicitly added to the environment-variables.

> ⚠ When you are using a Linux agent, you need to pass other environment variables that you want to use as well, because these are not available. To be able to use the `ArmOutputs` environment variable, it must be explicitly added to the environment-variables.

> 💡 We have seen a much better performance when using Linux agents, and would recommend using Linux agents when possible.

Example of how to use this function in an Azure DevOps pipeline:

```yaml
- task: PowerShell@2
  displayName: 'Promote Azure resource outputs to variable group'
  env:
    SYSTEM_ACCESSTOKEN: $(System.AccessToken)
    ArmOutputs: $(ArmOutputs) # only needs to be set for Linux agents
  inputs:
    targetType: 'inline'
    script: |
      Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
      Install-Module -Name Arcus.Scripting.DevOps -Repository PSGallery -AllowClobber

      Set-AzDevOpsArmOutputsToVariableGroup -VariableGroupName "my-variable-group"
```

In Azure DevOps, below permissions need to be set on your variable group in order to make the 'Promote Azure resource outputs to variable group' task succeed. For more information on service accounts, see [the official Azure DevOps documentation](https://docs.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops&tabs=preview-page#service-accounts).

- Project Collection Build Service (`<your devops org name>`) - Administrator
- `<your devops project name>` Build Service (`<your devops org name>`) - Administrator

### Guideline

In ARM and Bicep templates it is possible to specify [output parameters](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/outputs), this enables you to return values from the deployed resources. 

To enable maximum re-use of these output parameters within your environment we developed [this script](#setting-arm-outputs-to-azure-devops-variable-group) which is available in the `Arcus.Scripting.DevOps` PowerShell module. It allows you to store those output parameters in an Azure DevOps variable group. This helps you in making sure certain parameters are available throughout your Azure DevOps environment.

For example, think of a use-case where your vital infrastructure components are deployed in a separate Azure DevOps pipeline and need to be referenced from other components. Storing the necessary information such as identifiers, locations or names of these components in an Azure DevOps variable group allows you to easily use these values from other components.

#### Example
##### Specify Output Parameters
So how does this work in practice? Let's take an example where we will deploy a very basic Application Insights instance and specify the `Id` and `ConnectionString` of the Application Insights instance as output parameters. 

Our Bicep template looks like this:
``` bicep
param location string = resourceGroup().location

resource applicationInsight 'microsoft.insights/components@2020-02-02' = {
  name: 'myAppInsights'
  location: location
  kind: 'other'
  properties: {
    Application_Type: 'other'
  }
}

output ApplicationInsights_Id string = applicationInsight.id
output ApplicationInsights_ConnectionString string = reference(applicationInsight.id, '2020-02-02').ConnectionString
```

This Bicep template will deploy the Application Insights instance and place the `Id` and `ConnectionString` in the output parameters. 

##### Updating The Variable Group
Now all we need to do is execute our [script](#setting-arm-outputs-to-azure-devops-variable-group) which will update the Azure DevOps variable group.

From an Azure DevOps pipeline this can be done like so:
``` powershell
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Arcus.Scripting.DevOps -AllowClobber

Set-AzDevOpsArmOutputsToVariableGroup -VariableGroupName 'myVariableGroup'
```

##### Combining It All In A Pipeline
Now that we have walked through both steps, let's take a look on how to combine all this into an Azure DevOps pipeline.
For this we use YAML and define two tasks, the first will deploy our Application Insights instance and the second will update our Azure DevOps variable group.

``` yaml
- task: AzureResourceGroupDeployment@3
  displayName: 'Deploy Bicep template'
  inputs:
    azureResourceManagerConnection: 'myServiceConnection'
    subscriptionId: 'mySubscriptionId'
    resourceGroupName: 'myResourceGroup'
    location: 'West Europe'
    csmFile: 'applicationInsights.bicep'
    csmParametersFile: 'applicationInsights.parameters.json'
    deploymentOutputs: ArmOutputs

- task: PowerShell@2
  displayName: 'Update Variable Group'
  env:
    system_accesstoken: $(System.AccessToken)
    ArmOutputs: $(ArmOutputs) # only needs to be set for Linux agents
  inputs:
    targetType: 'inline'
    script: |
      Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
      Install-Module -Name Arcus.Scripting.DevOps -AllowClobber

      Set-AzDevOpsArmOutputsToVariableGroup -VariableGroupName 'myVariableGroup' -ArmOutputsEnvironmentVariableName 'ArmOutputs' -UpdateVariablesForCurrentJob
```

There are a few things worth noting. First of all we define `deploymentOutputs: ArmOutputs` during the `AzureResourceGroupDeployment@3` task. This means that the output parameters we specified in our Bicep template will be placed in a variable called `ArmOutputs`, this is then referenced during the execution of our script with `-ArmOutputsEnvironmentVariableName 'ArmOutputs'`.

Secondly we use `-UpdateVariablesForCurrentJob` as a parameter when calling the script. This means that the output parameters from the Bicep file are also available as pipeline variables in the current running job. While not necessary in our example here, if you need to deploy another Bicep template that needs output parameters from an earlier deployed Bicep template this is the way to do it.

Finally we use `system_accesstoken: $(System.AccessToken)` in the `Powershell@2` task, this is necessary because we need to use the security token used by the running build. 
> Please note that the `ArmOutputs` variable is not available 'as is' when executing the Powershell task on a Linux agent.  When using a Linux agent, you have to explicitly add that variable in the `env:` section of the Powershell task.
#### Closing Up
Using this setup we are able to deploy a Bicep template and update an Azure DevOps variable group with the specified output parameters!

> ⚠ Before running your pipeline, make sure the variable group already exists in Azure DevOps and the permissions below are set:
> - Project Collection Build Service (`<your devops org name>`) - Administrator
> - `<your devops project name>` Build Service (`<your devops org name>`) - Administrator


## Setting ARM outputs to Azure DevOps pipeline variables

Sets the ARM outputs as variables to an Azure DevOps pipeline during the execution of the pipeline.

| Parameter                           | Mandatory | Description                                                                                    |
| ----------------------------------- | --------- | ---------------------------------------------------------------------------------------------- |
| `ArmOutputsEnvironmentVariableName` | no        | The name of the environment variable where the ARM outputs are located (default: `ArmOutputs`) |

**Example**

With default `ArmOutputs` environment variable containing: `"my-variable": "my-value"`:

```powershell
PS> Set-AzDevOpsArmOutputsToPipelineVariables
# Getting ARM outputs from 'ArmOutputs' environment variable...
# The pipeline variable my-variable will be updated to value my-value, so it can be used in subsequent tasks of the current job. 
# ##vso[task.setvariable variable=my-variable]my-value
```

With custom `MyArmOutputs` environment variable containing: `"my-variable": "my-value"`:

```powershell
PS> Set-AzDevOpsArmOutputsToPipelineVariables -ArmOutputsEnvironmentVariableName "MyArmOutputs"
# Getting ARM outputs from 'MyArmOutputs' environment variable...
# The pipeline variable my-variable will be updated to value my-value, so it can be used in subsequent tasks of the current job. 
# ##vso[task.setvariable variable=my-variable]my-value
```

**Azure DevOps Example**
This function is intended to be used from an Azure DevOps pipeline.

> ⚠ When you are using a Linux agent, you need to pass other environment variables that you want to use as well, because these are not available. To be able to use the `ArmOutputs` environment variable, it must be explicitly added to the environment-variables.

> 💡 We have seen a much better performance when using Linux agents, and would recommend using Linux agents when possible.

Example of how to use this function in an Azure DevOps pipeline:

```yaml
- task: PowerShell@2
  displayName: 'Promote Azure resource outputs to pipeline variables'
  env:
    ArmOutputs: $(ArmOutputs) # only needs to be set for Linux agents
  inputs:
    targetType: 'inline'
    script: |
      Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
      Install-Module -Name Arcus.Scripting.DevOps -Repository PSGallery -AllowClobber

      Set-AzDevOpsArmOutputsToPipelineVariables
```

## Save Azure DevOps build

Saves/retains a specific Azure DevOps pipeline run.

| Parameter       | Mandatory | Description                                                                                                                        |
| --------------- | --------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `ProjectId`     | yes       | The Id of the project where the build that must be retained can be found                                                           |
| `BuildId`       | yes       | The Id of the build that must be retained                                                                                          |
| `DaysToKeep`    | no        | The number of days to keep the Azure DevOps pipeline run, if not supplied the Azure DevOps pipeline run will be saved indefinitely |

**Example**

Saving an Azure DevOps pipeline run indefinitely

```powershell
PS> Save-AzDevOpsBuild `
-ProjectId $(System.TeamProjectId) `
-BuildId $(Build.BuildId)
# Saved Azure DevOps build indefinitely with build ID $BuildId in project $ProjectId
```

Saving an Azure DevOps pipeline run for 10 days

```powershell
PS> Save-AzDevOpsBuild `
-ProjectId $(System.TeamProjectId) `
-BuildId $(Build.BuildId) `
-DaysToKeep 10
# Saved Azure DevOps build for 10 days with build ID $BuildId in project $ProjectId
```

> 💡 The variables $(System.TeamProjectId) and $(Build.BuildId) are predefined Azure DevOps variables. Information on them can be found here: https://docs.microsoft.com/en-us/azure/devops/pipelines/build/variables?view=azure-devops&tabs=yaml

**Azure DevOps Example**
This function is intended to be used from an Azure DevOps pipeline. Internally, it uses some predefined Azure DevOps variables.
One of the environment variables that is used, is the `SYSTEM_ACCESSTOKEN` variable. However, due to safety reasons this variable is not available out-of-the box.
To be able to use this variable, it must be explicitly added to the environment-variables.

Example of how to use this function in an Azure DevOps pipeline:

```yaml
- task: PowerShell@2
  displayName: 'Retain current build indefinitely'
  env:
    SYSTEM_ACCESSTOKEN: $(System.AccessToken)
  inputs:
    targetType: 'inline'
    pwsh: true
    script: |
      Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
      Install-Module -Name Arcus.Scripting.DevOps -Repository PSGallery -AllowClobber

      $project = "$(System.TeamProjectId)"
      $buildId = $(Build.BuildId)

      Save-AzDevOpsBuild -ProjectId $project -BuildId $buildId
```

