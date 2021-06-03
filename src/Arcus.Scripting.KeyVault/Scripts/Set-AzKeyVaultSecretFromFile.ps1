param (
    [Parameter(Mandatory=$true)][string] $KeyVaultName = $(throw "Name of the Azure Key Vault is required"),
    [Parameter(Mandatory=$true)][string] $SecretName = $(throw "Name of the secret name is required"),
    [Parameter(Mandatory=$true)][string] $FilePath = $(throw "Path to the secret file is required"),
    [Parameter(Mandatory=$false)][System.Nullable[System.DateTime]] $Expires,
    [Parameter(Mandatory=$false)][switch] $Base64 = $false
)

$isFileFound = Test-Path -Path $FilePath -PathType Leaf
if ($false -eq $isFileFound) {
    Write-Error "Cannot set an Azure Key Vault secret because no file could be found containing the secret at '$FilePath'"
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
