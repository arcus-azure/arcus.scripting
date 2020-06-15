<#
 .Synopsis
  Change the state of a DataFactory V2 Trigger.
 
 .Description
  Start or stop a DataFactory V2 Trigger.
 
 .Parameter Action
  The new state of the trigger: Start | Stop.
 
 .Parameter ResourceGroupName
  The resource group containing the DataFactory V2.
 
 .Parameter DataFactoryName
  The name of the DataFactory V2.
 
 .Parameter DataFactoryTriggerName
  The name of the trigger to be started/stopped.
 
 .Parameter FailWhenTriggerIsNotFound
  Indicate whether to throw an exception if the trigger cannot be found.
#>
function Set-AzDataFactoryTriggerState {
	param(
		[Parameter(Mandatory=$true)][string]$Action = $(throw "Action is required [Start|Stop]"),
		[Parameter(Mandatory=$true)][string]$ResourceGroupName = $(throw "ResourceGroup is required"),
		[Parameter(Mandatory=$true)][string]$DataFactoryName = $(throw "The name of the data factory is required"),
		[Parameter(Mandatory=$true)][string]$DataFactoryTriggerName = $(throw "The name of the trigger is required"),
		[Parameter(Mandatory=$false)][switch]$FailWhenTriggerIsNotFound = $false
	)
	if($FailWhenTriggerIsNotFound)
	{
		. $PSScriptRoot\Scripts\Set-AzDataFactoryTriggerState.ps1 -Action $Action -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -DataFactoryTriggerName $DataFactoryTriggerName -FailWhenTriggerIsNotFound
	}
	else
	{
		. $PSScriptRoot\Scripts\Set-AzDataFactoryTriggerState.ps1 -Action $Action -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -DataFactoryTriggerName $DataFactoryTriggerName
	}
}

Export-ModuleMember Set-AzDataFactoryTriggerState