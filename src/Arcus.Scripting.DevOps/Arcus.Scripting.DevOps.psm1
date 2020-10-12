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

 .Parameter
  The switch to also set the variables in the ARM output as pipeline variables in the current running job.
#>
function Set-AzDevOpsArmOutputsToVariableGroup {
    param(
        [parameter(Mandatory=$true)][string] $VariableGroupName = $(throw "Name for variable group is required"),
        [parameter(Mandatory=$false)][switch] $UpdateVariablesForCurrentJob = $false
    )

    if ($UpdateVariablesForCurrentJob) {
        . $PSScriptRoot\Scripts\Set-AzDevOpsArmOutputsToVariableGroup.ps1 -VariableGroupName $VariableGroupName -UpdateVariablesForCurrentJob
    } else {
        . $PSScriptRoot\Scripts\Set-AzDevOpsArmOutputsToVariableGroup.ps1 -VariableGroupName $VariableGroupName
    }
}

Export-ModuleMember -Function Set-AzDevOpsArmOutputsToVariableGroup
