---
title: "Azure Key Vault"
layout: default
---

# Azure Key Vault

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.KeyVault
```

## Getting all access policies for an Azure Key Vault

Lists the current available access policies of the Azure Key Vault resource.

| Parameter           | Mandatory | Description                                                                  |
| ------------------- | --------- | ---------------------------------------------------------------------------- |
| `KeyVaultName`      | yes       | The name of the key vault from which the access policies are to be retrieved |
| `ResourceGroupName` | no        | The resource group containing the key vault                                  |

**Example**

```powershell
PS> $accessPolicies = Get-AzKeyVaultAccessPolicies -KeyVaultName "my-key-vault"
# accessPolicies: {list: [{tenantId: ...,permissions: ...}]}
# Successfully retrieved Azure Key Vault access policies
```

```powershell
PS> $accessPolicies = Get-AzKeyVaultAccessPolicies `
-KeyVaultName "my-key-vault" `
-ResourceGroupName "my-resource-group"
# accessPolicies: {list: [{tenantId: ...,permissions: ...}]}
# Successfully retrieved Azure Key Vault access policies
```

## Setting a secret value from file into Azure Key Vault

Sets a secret certificate from a file as plain text in Azure Key Vault.

| Parameter      | Mandatory | Description                                                                          |
| -------------- | --------- | ------------------------------------------------------------------------------------ |
| `KeyVaultName` | yes       | The name of the Azure Key Vault where the secret should be added                     |
| `SecretName`   | yes       | The name of the secret to add in the Azure Key Vault                                 |
| `FilePath`	 | yes       | The path to the file containing the secret certificate to add in the Azure Key Vault |
| `Expires`      | no        | The optional expiration date of the secret to add in the Azure Key Vault             |

**Example**
```powershell
PS> Set-AzKeyVaultSecretFromFile `
-KeyVaultName "my-key-vault" `
-SecretName "my-secret" `
-FilePath "/file-path/secret-certificate.pfx"
# Azure Key Vault secret 'my-secret' (Version: 'new-secret-version') has been created in Azure Key vault 'my-key-vault'
```

And with expiration date:
```powershell
PS> Set-AzKeyVaultSecretFromFile `
-FilePath "/file-path/secret-certificate.pfx" `
-SecretName "my-secret" `
-Expires [Datetime]::ParseExact('07/15/2019', 'MM/dd/yyyy', $null) `
-KeyVaultName "my-key-vault"
# Azure Key Vault secret 'my-secret' (Version: 'new-secret-version') has been created in Azure Key vault 'my-key-vault'
```

## Setting a secret value with BASE64 encoded file-content into Azure Key Vault

Uploads the content of a file as a Base64 encoded string, as plain text, into an Azure Key Vault secret.
Can be useful when having to refer to a certificate from within an ARM-template.

| Parameter      | Mandatory | Description                                                                          |
| -------------- | --------- | ------------------------------------------------------------------------------------ |
| `KeyVaultName` | yes       | The name of the Azure Key Vault where the secret should be added                     |
| `SecretName`   | yes       | The name of the secret to add in the Azure Key Vault                                 |
| `FilePath`	 | yes       | The path to the file containing the secret certificate to add in the Azure Key Vault |
| `Expires`      | no        | The optional expiration date of the secret to add in the Azure Key Vault             |

**Example**
```powershell
PS> Set-AzKeyVaultSecretAsBase64FromFile `
-KeyVaultName "my-key-vault" `
-SecretName "my-secret" `
-FilePath "/file-path/secret-certificate.pfx"
# Use BASE64 format as format to create Azure Key vault secret 'my-secret' in Azure Key vault 'my-key-vault'
# Azure Key Vault secret 'my-secret' (Version: 'new-secret-version') has been created in Azure Key vault 'my-key-vault'
```

And with expiration date:
```powershell
PS> Set-AzKeyVaultSecretAsBase64FromFile `
-FilePath "/file-path/secret-certificate.pfx" `
-SecretName "my-secret" `
-Expires [Datetime]::ParseExact('07/15/2019', 'MM/dd/yyyy', $null) `
-KeyVaultName "my-key-vault"
# Azure Key Vault secret 'my-secret' (Version: 'new-secret-version') has been created in Azure Key vault 'my-key-vault'
```
