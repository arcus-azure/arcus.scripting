<#
 .Synopsis
  Change the state of a DataFactory V2 Trigger.
 
 .Description
  Start a DataFactory V2 Trigger.

 .Parameter ResourceGroupName
  The resource group containing the DataFactory V2.
 
 .Parameter DataFactoryName
  The name of the DataFactory V2.
 
 .Parameter DataFactoryTriggerName
  The name of the trigger to be started/stopped.
 
 .Parameter FailWhenTriggerIsNotFound
  Indicate whether to throw an exception if the trigger cannot be found.
#>
function Start-AzDataFactoryTrigger {
	param(
		[Parameter(Mandatory=$true)][string]$ResourceGroupName = $(throw "ResourceGroup is required"),
		[Parameter(Mandatory=$true)][string]$DataFactoryName = $(throw "The name of the data factory is required"),
		[Parameter(Mandatory=$true)][string]$DataFactoryTriggerName = $(throw "The name of the trigger is required"),
		[Parameter(Mandatory=$false)][switch]$FailWhenTriggerIsNotFound = $false
	)
	if($FailWhenTriggerIsNotFound)
	{
		. $PSScriptRoot\Scripts\Set-AzDataFactoryTriggerState.ps1 -Action Start -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -DataFactoryTriggerName $DataFactoryTriggerName -FailWhenTriggerIsNotFound
	}
	else
	{
		. $PSScriptRoot\Scripts\Set-AzDataFactoryTriggerState.ps1 -Action Start -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -DataFactoryTriggerName $DataFactoryTriggerName
	}
}

Export-ModuleMember Start-AzDataFactoryTrigger

<#
 .Synopsis
  Change the state of a DataFactory V2 Trigger.
 
 .Description
  Stop a DataFactory V2 Trigger.

 .Parameter ResourceGroupName
  The resource group containing the DataFactory V2.
 
 .Parameter DataFactoryName
  The name of the DataFactory V2.
 
 .Parameter DataFactoryTriggerName
  The name of the trigger to be started/stopped.
 
 .Parameter FailWhenTriggerIsNotFound
  Indicate whether to throw an exception if the trigger cannot be found.
#>
function Stop-AzDataFactoryTrigger {
	param(
		[Parameter(Mandatory=$true)][string]$ResourceGroupName = $(throw "ResourceGroup is required"),
		[Parameter(Mandatory=$true)][string]$DataFactoryName = $(throw "The name of the data factory is required"),
		[Parameter(Mandatory=$true)][string]$DataFactoryTriggerName = $(throw "The name of the trigger is required"),
		[Parameter(Mandatory=$false)][switch]$FailWhenTriggerIsNotFound = $false
	)
	if($FailWhenTriggerIsNotFound)
	{
		. $PSScriptRoot\Scripts\Set-AzDataFactoryTriggerState.ps1 -Action Stop -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -DataFactoryTriggerName $DataFactoryTriggerName -FailWhenTriggerIsNotFound
	}
	else
	{
		. $PSScriptRoot\Scripts\Set-AzDataFactoryTriggerState.ps1 -Action Stop -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -DataFactoryTriggerName $DataFactoryTriggerName
	}
}

Export-ModuleMember Stop-AzDataFactoryTrigger
