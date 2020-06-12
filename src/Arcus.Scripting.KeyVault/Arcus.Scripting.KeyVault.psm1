<#
 .Synopsis
  Return the current access policies present in Azure Key Vault.

 .Description
  List the current access policies present in Azure Key Vault.

 .Parameter KeyVaultName
  The name of the Azure Key Vault from which the access policies are to be retrieved.

 .Parameter ResourceGroupName
  The resource group containing the Azure Key Vault.
#>
function Get-KeyVaultAccessPolicies {
	param(
	   [parameter(Mandatory = $true)][string] $KeyVaultName,
	   [parameter(Mandatory = $false)][string] $ResourceGroupName = ""
	)
	. $PSScriptRoot\Scripts\Get-AzKeyVaultAccessPolicies.ps1 -keyVaultName $KeyVaultName -resourceGroupName $ResourceGroupName
}

Export-ModuleMember -Function Get-KeyVaultAccessPolicies
