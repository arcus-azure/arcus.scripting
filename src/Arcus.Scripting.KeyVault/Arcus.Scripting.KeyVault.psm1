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

 .Parameter KeyVaultName
  The name of the Azure Key Vault where the secret should be added.

 .Parameter ResourceGroupName
  The resource group containing the Azure Key Vault.

 .Parameter
  The name of the secret to add in the Azure Key Vault.

 .Parameter
  The ID of the Azure subscription that has access to the Azure Key Vault.

 .Parameter
  The flag indicating whether the user is logged in.
#>

function Set-AzKeyVaultSecretFromFile {
    param (
        [string][Parameter(Mandatory=$true)] $FilePath = $(throw "The path to the file is required."),
        [string][Parameter(Mandatory=$true)] $KeyVaultName = $(throw "The path to the file is required."),
        [string][Parameter(Mandatory=$true)] $SecretName = $(throw "The path to the file is required."),
        [string][parameter(Mandatory = $false)] $SubscriptionId = "",
        [bool][parameter(Mandatory = $false)] $LoggedIn = $true,
    )

    . $PSScriptRoot\Scripts\Set-AzKeyVaultSecretFromFile -FilePath $FilePath -KeyVaultName $KeyVaultName -SecretName $SecretName -SubscriptionId $SubscriptionId -LoggedIn $LoggedIn
}

Export-ModuleMember -Function Set-AzKeyVaultSecretFromFile
