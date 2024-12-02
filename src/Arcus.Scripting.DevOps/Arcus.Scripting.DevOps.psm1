<#
 .Synopsis
  Set a variable in the Azure DevOps pipeline at runtime.
 
 .Description
  Assign a value to a DevOps pipeline variable during the execution of this pipeline.

 .Parameter Name
  The name of the variable to set in the pipeline.
 
 .Parameter Value
  The value of the variable to set in the pipeline.
#>
function Set-AzDevOpsVariable {
    param(
        [parameter(Mandatory = $true)][string] $Name = $(throw "Name is required"),
        [parameter(Mandatory = $true)][string] $Value = $(throw "Value is required"),
        [parameter(Mandatory = $false)][switch] $AsSecret = $false
    )
    
    if ($AsSecret) {
        Write-Host "##vso[task.setvariable variable=$Name;issecret=true]$Value"
    } else {
        Write-Host "##vso[task.setvariable variable=$Name]$Value"
    }
}

Export-ModuleMember -Function Set-AzDevOpsVariable

<#
 .Synopsis
  Set a variable in the Azure DevOps variable group.
 
 .Description
  Assign a value to a DevOps variable group during the execution of an Azure DevOps pipeline.

 .Parameter VariableGroupName
  The name of the Azure DevOps variable group to updat with a new variable.

 .Parameter VariableName
  The name of the variable to set in the variable group.
 
 .Parameter VariableValue
  The value of the variable to set in the variable group.
#>
function Set-AzDevOpsGroupVariable {
    param(
        [string][parameter(Mandatory = $true)]$VariableGroupName,
        [string][parameter(Mandatory = $true)]$VariableName,
        [string][parameter(Mandatory = $true)]$VariableValue
    )

    . $PSScriptRoot\Scripts\Set-AzDevOpsGroupVariable.ps1 -VariableGroupName $VariableGroupName -VariableName $VariableName -VariableValue $VariableValue
}

Export-ModuleMember -Function Set-AzDevOpsGroupVariable

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
        [parameter(Mandatory = $true)][string] $VariableGroupName = $(throw "Name for variable group is required"),
        [parameter(Mandatory = $false)][string] $ArmOutputsEnvironmentVariableName = "ArmOutputs",
        [parameter(Mandatory = $false)][switch] $UpdateVariablesForCurrentJob = $false
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

<#
 .Synopsis
  Indicates that the specified DevOps pipeline-run must be retained indefinetely.

 .Description
  Indicates that the specified DevOps pipeline-run must be retained indefinetely.
 
 .Parameter ProjectId
  The Id of the Project in Azure DevOps to which the build that must be retained, belongs to. 
  (You can use the predefined variable $(System.TeamProjectId) in an Azure DevOps pipeline).

 .Parameter BuildId
  The Id of the Build that must be retained.
  (You can use the predefined variable $(Build.BuildId) in an Azure DevOps pipeline).
 
#>
function Save-AzDevOpsBuild {
    param(        
        [Parameter(Mandatory = $true)][string] $ProjectId = $(throw "ProjectId is required"),
        [Parameter(Mandatory = $true)][string] $BuildId = $(throw "BuildId is required"),
        [Parameter(Mandatory = $false)][int] $DaysToKeep
    )

    . $PSScriptRoot\Scripts\Save-AzDevOpsBuild.ps1 -ProjectId $ProjectId -BuildId $BuildId -DaysToKeep $DaysToKeep
}

Export-ModuleMember -Function Save-AzDevOpsBuild
