# Use this script to upload a certificate as plain text (multiline-support) into Azure Key Vault.

param (
    [string][Parameter(Mandatory=$true)] $KeyVaultName = $(throw "The path to the file is required."),
    [string][Parameter(Mandatory=$true)] $SecretName = $(throw "The path to the file is required."),
    [string][Parameter(Mandatory=$true)] $FilePath = $(throw "The path to the file is required."),
    [System.Nullable[System.DateTime]][Parameter(Mandatory=$false)] $Expires,
    [switch][Parameter(Mandatory=$false)] $Base64 = $false
)

$isFileFound = Test-Path -Path $FilePath -PathType Leaf
if ($false -eq $isFileFound) {
    Write-Error "Cannot set an Azure Key Vault secret because no file could containing the secret at '$FilePath'"
    throw "Cannot set an Azure Key Vault secret because no file containing the secret certificate was found"
}

Write-Verbose "Creating Azure Key Vault secret from file..."

$secretValue = $null
if ($Base64) {
    Write-Verbose "Use BASE64 format as secret format"
    $content = Get-Content $filePath -AsByteStream -Raw
    $contentBase64 = [System.Convert]::ToBase64String($content)
    $secretValue = ConvertTo-SecureString -String $contentBase64 -Force -AsPlainText
} else {
    $rawContent = Get-Content $FilePath -Raw
    $secretValue = ConvertTo-SecureString $rawContent -Force -AsPlainTex
}

$secret = $null
if ($Expires -ne $null) {
    $secret = Set-AzKeyVaultSecret -VaultName $KeyVaultName -SecretName $SecretName -SecretValue $secretValue -Expires $Expires -ErrorAction Stop
} else {
    $secret = Set-AzKeyVaultSecret -VaultName $KeyVaultName -SecretName $SecretName -SecretValue $secretValue -ErrorAction Stop
}

$version = $secret.Version
Write-Host "Azure Key Vault Secret '$SecretName' (Version: '$version') has been created."
