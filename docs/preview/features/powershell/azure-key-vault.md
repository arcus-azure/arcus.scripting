---
title: "Scripts related to interacting with Azure Key Vault"
layout: default
---

# Azure Key Vault

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Import-Module -Name Arcus.Scripting.KeyVault
```

## Get all access policies of a key vault

Lists the current available access policies of the Azure key vault resource.

| Parameter           | Mandatory | Description                                                                  |
| ------------------- | --------- | ---------------------------------------------------------------------------- |
| `KeyVaultName`      | yes       | The name of the key vault from which the access policies are to be retrieved |
| `ResourceGroupName` | no        | The resource group containing the key vault                                  |

**Example**

```powershell
PS> $accessPolicies = Get-AzKeyVaultAccessPolicies -KeyVaultName "my-key-vault"
# accessPolicies: {list: [{tenantId: ...,permissions: ...}]}
```

```powershell
PS> $accessPolicies = Get-AzKeyVaultAccessPolicies -KeyVaultName "my-key-vault" -ResourceGroupName "my-resouce-group"
# accessPolicies: {list: [{tenantId: ...,permissions: ...}]}
```

## Set secret value from file into key vault

Sets a secret certificate from a file as plain text in Azure Key Vault.

| Parameter      | Mandatory | Description                                                                          |
| -------------- | --------- | ------------------------------------------------------------------------------------ |
| `FilePath`	 | yes       | The path to the file containing the secret certificate to add in the Azure Key Vault |
| `SecretName`   | yes       | The name of the secret to add in the Azure Key Vault                                 |
| `KeyVaultName` | yes       | The name of the Azure Key Vault where the secret should be added                     |
| `Expires`.     | no        | The optional expiration date of the secret to add in the Azure Key Vault             |

**Example**
```powershell
PS> Set-AzKeyVaultSecretFromFile -FilePath "/file-path/secret-certificate.pfx" -SecretName "my-secret" -KeyVaultName "my-key-vault"
# Secret 'my-secret' has been created.
```

And with expiration date:
```powershell
PS> Set-AzKeyVaultSecretFromFile -FilePath "/file-path/secret-certificate.pfx" -SecretName "my-secret" -Expires [Datetime]::ParseExact('07/15/2019', 'MM/dd/yyyy', $null) -KeyVaultName "my-key-vault" -KeyVaultName "my-key-vault"
```
