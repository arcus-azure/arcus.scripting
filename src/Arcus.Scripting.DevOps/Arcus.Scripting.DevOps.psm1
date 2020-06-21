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
		[Parameter(Mandatory=$true)][string]$Name = $(throw "Name is required"),
		[Parameter(Mandatory=$true)][string]$Value = $(throw "Value is required")
	)

	Write-Host "#vso[task.setvariable variable=$Name] $Value"
}
