# Use this script to upload a certificate as plain text (multiline-support) into Azure Key Vault.

param (
    [string][Parameter(Mandatory=$true)] $FilePath = $(throw "The path to the file is required."),
    [string][Parameter(Mandatory=$true)] $KeyVaultName = $(throw "The path to the file is required."),
    [string][Parameter(Mandatory=$true)] $SecretName = $(throw "The path to the file is required."),
    [System.Nullable[System.DateTime]][Parameter(Mandatory=$false)] $Expires
)

Write-Host "Creating KeyVault secret..."

$rawContent = Get-Content $FilePath -Raw
$secretValue = ConvertTo-SecureString $rawContent -Force -AsPlainTex

$secret = $null
if ($Expires -ne $null) {
    $secret = Set-AzKeyVaultSecret -VaultName $KeyVaultName -SecretName $SecretName -SecretValue $secretValue -Expires $Expires -ErrorAction Stop
} else {
    $secret = Set-AzKeyVaultSecret -VaultName $KeyVaultName -SecretName $SecretName -SecretValue $secretValue -ErrorAction Stop
}

Write-Host "Secret '$SecretName' (Version: '$secret.Version') has been created."
