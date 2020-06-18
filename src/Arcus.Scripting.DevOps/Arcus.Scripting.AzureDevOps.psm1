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
function Set-DevOpsVariable {
	param(
		[Parameter(Mandatory=$true)][string]$VariableName = $(throw "VariableName is required"),
		[Parameter(Mandatory=$true)][string]$VariableValue = $(throw "VariableValue is required")
	)

	Write-Host "#vso[task.setvariable variable=$VariableName] $VariableValue"
}