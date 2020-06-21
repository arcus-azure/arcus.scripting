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
function Get-AzKeyVaultAccessPolicies {
	param(
	   [parameter(Mandatory = $true)][string] $KeyVaultName,
	   [parameter(Mandatory = $false)][string] $ResourceGroupName = ""
	)
	. $PSScriptRoot\Scripts\Get-AzKeyVaultAccessPolicies.ps1 -keyVaultName $KeyVaultName -resourceGroupName $ResourceGroupName
}

Export-ModuleMember -Function Get-AzKeyVaultAccessPolicies

<#
 .Synopsis
  Sets a secret from a file in Azure Key Vault.

 .Description
  Sets a secret certificate from a file as plain text in Azure Key Vault.

 .Parameter FilePath
  The path the to file containing the secret certificate to add in the Azure Key Vault.

 .Parameter SecretName
  The name of the secret to add in the Azure Key Vault.

 .Parameter KeyVaultName
  The name of the Azure Key Vault where the secret should be added.

 .Parameter
  The optional expiration date of the secret to add in the Azure Key Vault.
#>

function Set-AzKeyVaultSecretFromFile {
    param (
        [string][Parameter(Mandatory=$true)] $FilePath = $(throw "The path to the file is required."),
        [string][Parameter(Mandatory=$true)] $SecretName = $(throw "The path to the file is required."),
        [string][Parameter(Mandatory=$true)] $KeyVaultName = $(throw "The path to the file is required."),
        [System.DateTime][Parameter(Mandatory=$false)] $Expires
    )

    . $PSScriptRoot\Scripts\Set-AzKeyVaultSecretFromFile.ps1 -FilePath $FilePath -KeyVaultName $KeyVaultName -SecretName $SecretName -Expires $Expires
}

Export-ModuleMember -Function Set-AzKeyVaultSecretFromFile
