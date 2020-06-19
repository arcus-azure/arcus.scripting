# Use this script to upload a certificate as plain text (multiline-support) into Azure Key Vault.

param (
    [string][Parameter(Mandatory=$true)] $FilePath = $(throw "The path to the file is required."),
    [string][Parameter(Mandatory=$true)] $KeyVaultName = $(throw "The path to the file is required."),
    [string][Parameter(Mandatory=$true)] $SecretName = $(throw "The path to the file is required.")
)

Write-Host "Creating KeyVault secret..."

$rawContent = Get-Content $FilePath -Raw
$secretValue = ConvertTo-SecureString $rawContent -Force -AsPlainText
Set-AzKeyVaultSecret -VaultName $KeyVaultName -SecretName $SecretName -SecretValue $secretValue -ErrorAction Stop

Write-Host "Secret '$SecretName' has been created."
