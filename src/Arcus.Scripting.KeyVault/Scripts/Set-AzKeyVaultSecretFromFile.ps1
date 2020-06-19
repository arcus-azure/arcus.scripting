# Use this script to upload a certificate as plain text (multiline-support) into Azure KeyVault

param (
    [string][Parameter(Mandatory=$true)] $filePath = $(throw "The path to the file is required."),
    [string][Parameter(Mandatory=$true)] $keyVaultName = $(throw "The path to the file is required."),
    [string][Parameter(Mandatory=$true)] $secretName = $(throw "The path to the file is required."),
    [bool][parameter(Mandatory = $false)] $loggedIn = $true,
    [string][parameter(Mandatory = $false)] $subscriptionId = ""
)

# Perform the deployment based on the provided ARM-template and parameter file, if provided.
Write-Host("Creating KeyVault secret...")

Set-AzKeyVaultSecret -VaultName $keyVaultName -SecretName $secretName -SecretValue (ConvertTo-SecureString (Get-Content $filePath -Raw) -force -AsPlainText ) -ErrorAction Stop

Write-Host("Secret '$secretName' has been created.")
