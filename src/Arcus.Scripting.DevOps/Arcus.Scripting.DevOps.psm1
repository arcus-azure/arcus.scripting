<#
 .Synopsis
  Set a variable in the Azure DevOps pipeline at runtime.
 
 .Description
  Assign a value to a DevOps pipeline variable during the execution of this pipeline.

 .Parameter VariableName
  The name of the variable to set in the pipeline.
 
 .Parameter VariableValue
  The value of the variable to set in the pipeline.
#>
function Set-AzDevOpsVariable {
    param(
        [parameter(Mandatory=$true)][string] $Name = $(throw "Name is required"),
        [parameter(Mandatory=$true)][string] $Value = $(throw "Value is required")
    )
    
    Write-Host "#vso[task.setvariable variable=$Name] $Value"
}

Export-ModuleMember -Function Set-AzDevOpsVariable

<#
 .Synopsis
  Sets the ARM outputs as a variable group on Azure DevOps.

 .Description   
  Sets the Azure Resource Management (ARM) outputs as a variable group on Azure DevOps.

 .Parameter VariableGroupName 
  The name of the variable group on Azure DevOps where the ARM outputs should be set.

 .Parameter ArmOutputsEnvironmentVariableName
  The name of the environment variable where the ARM outputs are located.

 .Parameter UpdateVariablesForCurrentJob
  The switch to also set the variables in the ARM output as pipeline variables in the current running job.
#>
function Set-AzDevOpsArmOutputsToVariableGroup {
    param(
        [parameter(Mandatory=$true)][string] $VariableGroupName = $(throw "Name for variable group is required"),
        [parameter(Mandatory = $false)][string] $ArmOutputsEnvironmentVariableName = "ArmOutputs",
        [parameter(Mandatory=$false)][switch] $UpdateVariablesForCurrentJob = $false
    )

    if ($UpdateVariablesForCurrentJob) {
        . $PSScriptRoot\Scripts\Set-AzDevOpsArmOutputs.ps1 -VariableGroupName $VariableGroupName -ArmOutputsEnvironmentVariableName $ArmOutputsEnvironmentVariableName -UpdateVariableGroup -UpdateVariablesForCurrentJob
    } else {
        . $PSScriptRoot\Scripts\Set-AzDevOpsArmOutputs.ps1 -VariableGroupName $VariableGroupName -ArmOutputsEnvironmentVariableName $ArmOutputsEnvironmentVariableName -UpdateVariableGroup
    }
}

Export-ModuleMember -Function Set-AzDevOpsArmOutputsToVariableGroup

<#
 .Synopsis
  Sets the ARM outputs as variables in the Azure DevOps pipeline at runtime.

 .Description
  Sets the ARM outputs as variables to a Azure DevOps pipeline during the execution of the pipeline.

 .Parameter ArmOutputsEnvironmentVariableName
  The name of the environment variable where the ARM outputs are located.
#>
function Set-AzDevOpsArmOutputsToPipelineVariables {
    param(
        [parameter(Mandatory = $false)][string] $ArmOutputsEnvironmentVariableName = "ArmOutputs"
    )

    . $PSScriptRoot\Scripts\Set-AzDevOpsArmOutputs.ps1 -ArmOutputsEnvironmentVariableName $ArmOutputsEnvironmentVariableName -UpdateVariablesForCurrentJob
}

Export-ModuleMember -Function Set-AzDevOpsArmOutputsToPipelineVariables