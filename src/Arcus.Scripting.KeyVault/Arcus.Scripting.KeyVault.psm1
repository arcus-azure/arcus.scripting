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
        [Parameter(Mandatory = $true)][string] $KeyVaultName = $(throw "Name of the Azure Key Vault is required"),
        [Parameter(Mandatory = $false)][string] $ResourceGroupName = ""
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

 .Parameter SecretName
  The name of the secret to add in the Azure Key Vault.

 .Parameter FilePath
  The path the to file containing the secret certificate to add in the Azure Key Vault.

 .Parameter Expires
  The optional expiration date of the secret to add in the Azure Key Vault.
#>

function Set-AzKeyVaultSecretFromFile {
    param (
        [Parameter(Mandatory = $true)][string] $KeyVaultName = $(throw "Name of the Azure Key Vault is required"),
        [Parameter(Mandatory = $true)][string] $SecretName = $(throw "Name of the secret name is required"),
        [Parameter(Mandatory = $true)][string] $FilePath = $(throw "Path to the secret file is required"),
        [Parameter(Mandatory = $false)][System.Nullable[System.DateTime]] $Expires
    )

    . $PSScriptRoot\Scripts\Set-AzKeyVaultSecretFromFile.ps1 -KeyVaultName $KeyVaultName -SecretName $SecretName -FilePath $FilePath -Expires $Expires
}

Export-ModuleMember -Function Set-AzKeyVaultSecretFromFile

<#
 .Synopsis
  Sets a secret as a BASE64 format from a file in Azure Key Vault.

 .Description
  Uploads the content of a file as a Base64 encoded string, as plain text, into an Azure Key Vault secret.

 .Parameter KeyVaultName
  The name of the Azure Key Vault where the secret should be added.

 .Parameter SecretName
  The name of the secret to add in the Azure Key Vault.

 .Parameter FilePath
  The path the to file containing the secret certificate to add in the Azure Key Vault.

 .Parameter Expires
  The optional expiration date of the secret to add in the Azure Key Vault.
#>

function Set-AzKeyVaultSecretAsBase64FromFile {
    param (
        [Parameter(Mandatory = $true)][string] $KeyVaultName = $(throw "Name of the Azure Key Vault is required"),
        [Parameter(Mandatory = $true)][string] $SecretName = $(throw "Name of the secret name is required"),
        [Parameter(Mandatory = $true)][string] $FilePath = $(throw "Path to the secret file is required"),
        [Parameter(Mandatory = $false)][System.Nullable[System.DateTime]] $Expires
    )

    . $PSScriptRoot\Scripts\Set-AzKeyVaultSecretFromFile.ps1 -KeyVaultName $KeyVaultName -SecretName $SecretName -FilePath $FilePath -Expires $Expires -Base64
}

Export-ModuleMember -Function Set-AzKeyVaultSecretAsBase64FromFile
