---
title: "Setting ARM outputs to Azure DevOps variable group"
layout: default
---

# Setting ARM outputs to Azure DevOps variable group

In ARM and Bicep templates it is possible to specify [output parameters](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/outputs), this enables you to return values from the deployed resources. 

To enable maximum re-use of these output parameters within your environment we developed [this script](https://scripting.arcus-azure.net/Features/powershell/azure-devops#setting-arm-outputs-to-azure-devops-variable-group) which is available in the `Arcus.Scripting.DevOps` PowerShell module. It allows you to store those output parameters in an Azure DevOps variable group. This helps you in making sure certain parameters are available throughout your Azure DevOps environment.

For example, think of a use-case where your vital infrastructure components are deployed in a seperate Azure DevOps pipeline and need to be referenced from other components. Storing the necessary information such as identifiers, locations or names of these components in an Azure DevOps variable group allows you to easily use these values from other components.

## Example
### Specify Output Parameters
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

### Updating The Variable Group
Now all we need to do is execute our [script](../03-Features/powershell/azure-devops.md#setting-arm-outputs-to-azure-devops-variable-group) which will update the Azure DevOps variable group.

From an Azure DevOps pipeline this can be done like so:
``` powershell
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Arcus.Scripting.DevOps -AllowClobber

Set-AzDevOpsArmOutputsToVariableGroup -VariableGroupName 'myVariableGroup'
```

### Combining It All In A Pipeline
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

## Closing Up
Using this setup we are able to deploy a Bicep template and update an Azure DevOps variable group with the specified output parameters!

> ⚠ Before running your pipeline, make sure the variable group already exists in Azure DevOps and the permissions below are set:
> - Project Collection Build Service (`<your devops org name>`) - Administrator
> - `<your devops project name>` Build Service (`<your devops org name>`) - Administrator

## Further Reading
- [Arcus Scripting Azure DevOps documentation](../03-Features/powershell/azure-devops.md)
  - [Setting ARM outputs to Azure DevOps variable group](../03-Features/powershell/azure-devops.md#setting-arm-outputs-to-azure-devops-variable-group)
  - [Setting ARM outputs to Azure DevOps pipeline variables](../03-Features/powershell/azure-devops.md#setting-arm-outputs-to-azure-devops-pipeline-variables)
- [Bicep Outputs](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/outputs/)
- [Azure DevOps Variable Groups](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml)
