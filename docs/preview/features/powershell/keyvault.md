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
PS> $accessPolicies = Get-KeyVaultAccessPolicies -KeyVaultName "my-key-vault"
# accessPolicies: {list: [{tenantId: ...,permissions: ...}]}
```

```powershell
PS> $accessPolicies = Get-KeyVaultAccessPolicies -KeyVaultName "my-key-vault" -ResourceGroupName "my-resouce-group"
# accessPolicies: {list: [{tenantId: ...,permissions: ...}]}
```
