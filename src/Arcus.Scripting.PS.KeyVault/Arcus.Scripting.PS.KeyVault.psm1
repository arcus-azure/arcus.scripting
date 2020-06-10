<#
 .Synopsis
  Return the current access policies present in KeyVault.

 .Description
  List the current access policies present in KeyVault.

 .Parameter KeyVaultName
  The name of the KeyVault from which the access policies are to be retrieved.

 .Parameter ResourceGroupName
  The resource group containing the KeyVault.
#>
function Get-KeyVaultAccessPolicies {
	param(
	   [parameter(Mandatory = $true)][string] $KeyVaultName,
	   [parameter(Mandatory = $false)][string] $ResourceGroupName = ""
	)
	. $PSScriptRoot\Scripts\Get-Infra-KeyVaultAccessPolicies.ps1 -keyVaultName $KeyVaultName -resourceGroupName $ResourceGroupName
}

Export-ModuleMember -Function Get-KeyVaultAccessPolicies