param (
    [Parameter(Mandatory=$true)][string] $KeyVaultName = $(throw "Name of the Azure Key Vault is required"),
    [Parameter(Mandatory=$true)][string] $SecretName = $(throw "Name of the secret name is required"),
    [Parameter(Mandatory=$true)][string] $FilePath = $(throw "Path to the secret file is required"),
    [Parameter(Mandatory=$false)][System.Nullable[System.DateTime]] $Expires
)

$isFileFound = Test-Path -Path $FilePath -PathType Leaf
if ($false -eq $isFileFound) {
    Write-Error "No file could containing the secret certificate at '$FilePath'"
    return;
}

Write-Host "Creating KeyVault secret..."

$secretValue = $null
if ($Base64) {
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
Write-Host "Secret '$SecretName' (Version: '$version') has been created."
