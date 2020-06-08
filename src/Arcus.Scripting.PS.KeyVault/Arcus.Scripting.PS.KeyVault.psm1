<#
 .Synopsis
  Return the current access policies present in KeyVault.

 .Description
  List the current access policies present in KeyVault.

 .Parameter KeyVaultName
  The name of the KeyVault from which the access policies are to be retrieved.

 .Parameter ResourceGroupName
  The resource group containing the KeyVault.

 .Parameter OutputVariableName
  Default value: Infra.KeyVault.AccessPolicies
  The name of the variable to be added to DevOps-pipeline variables at runtime.
#>
function Get-KeyVaultAccessPolicies {
	param(
	   [parameter(Mandatory = $true)][string] $KeyVaultName,
	   [parameter(Mandatory = $false)][string] $ResourceGroupName = "",
	   [parameter(Mandatory = $false)][string] $OutputVariableName = "Infra.KeyVault.AccessPolicies"
	)
	. $PSScriptRoot\Scripts\Get-Infra-KeyVaultAccessPolicies.ps1 -keyVaultName $KeyVaultName -resourceGroupName $ResourceGroupName -outputVariableName $OutputVariableName
}

Export-ModuleMember -Function Get-KeyVaultAccessPolicies