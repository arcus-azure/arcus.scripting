# Use this script to upload a certificate as plain text (multiline-support) into Azure KeyVault

param (
    [string][Parameter(Mandatory=$true)] $FilePath = $(throw "The path to the file is required."),
    [string][Parameter(Mandatory=$true)] $KeyVaultName = $(throw "The path to the file is required."),
    [string][Parameter(Mandatory=$true)] $SecretName = $(throw "The path to the file is required."),
    [bool][parameter(Mandatory = $false)] $LoggedIn = $true,
    [string][parameter(Mandatory = $false)] $SubscriptionId = ""
)

# Perform the deployment based on the provided ARM-template and parameter file, if provided.
Write-Host("Creating KeyVault secret...")

Set-AzKeyVaultSecret -VaultName $KeyVaultName -SecretName $SecretName -SecretValue (ConvertTo-SecureString (Get-Content $FilePath -Raw) -force -AsPlainText ) -ErrorAction Stop

Write-Host("Secret '$SecretName' has been created.")
