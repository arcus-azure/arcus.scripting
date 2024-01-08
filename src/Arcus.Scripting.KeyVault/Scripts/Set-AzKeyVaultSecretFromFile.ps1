param(
    [Parameter(Mandatory = $true)][string] $KeyVaultName = $(throw "Name of the Azure Key Vault is required"),
    [Parameter(Mandatory = $true)][string] $SecretName = $(throw "Name of the secret name is required"),
    [Parameter(Mandatory = $true)][string] $FilePath = $(throw "Path to the secret file is required"),
    [Parameter(Mandatory = $false)][System.Nullable[System.DateTime]] $Expires,
    [Parameter(Mandatory = $false)][switch] $Base64 = $false
)

$isFileFound = Test-Path -Path $FilePath -PathType Leaf
if ($false -eq $isFileFound) {
    Write-Error "Cannot set an Azure Key Vault secret because no file could be found containing the secret at '$FilePath'"
    throw "Cannot set an Azure Key Vault secret because no file containing the secret certificate was found"
}

Write-Verbose "Creating Azure Key Vault secret '$SecretName' from file in Azure Key vault '$KeyVaultName'..."

$secretValue = $null
if ($Base64) {
    Write-Verbose "Use BASE64 format as format to create Azure Key vault secret '$SecretName' in Azure Key vault '$KeyVaultName'"
    $content = Get-Content $filePath -Raw
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
    $contentBase64 = [System.Convert]::ToBase64String($bytes)
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
Write-Host "Azure Key Vault secret '$SecretName' (Version: '$version') has been created in Azure Key vault '$KeyVaultName'" -ForegroundColor Green
