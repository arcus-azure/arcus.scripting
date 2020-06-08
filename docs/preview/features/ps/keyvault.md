---
title: "Scripts related to interacting with Azure Key Vault"
layout: default
---

# Azure Key Vault scripting

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Import-Module -Name Arcus.Scripting.PS.KeyVault
```

## Get all access policies of a key vault

Lists the current available access policies of the Azure key vault resource into a new variable availble at runtime during a Azure DevOps build.

| Parameter            | Mandatory                                     | Description                                                                  |
| -------------------- | --------------------------------------------- | ---------------------------------------------------------------------------- |
| `KeyVaultName`       | yes                                           | The name of the key vault from which the access policies are to be retrieved |
| `ResourceGroupName`  | no                                            | The resource group containing the key vault                                  |
| `OutputVariableName` | no (default: `Infra.KeyVault.AccessPolicies`) | The name of the variable to be added to DevOps-pipeline variables at runtime |

**Example**

```powershell
PS> Get-KeyVaultAccessPolicies -KeyVaultName "my-key-vault"
# Output: #vso[task.setvariable variable=Infra.KeyVault.AccessPolicies]{list: [{tenantId: ...,permissions: ...}]}
```

```powershell
PS> Get-KeyVaultAccessPolicies -KeyVaultName "my-key-vault" -ResourceGroupName "my-resouce-group" -OutputVariableName "My.KeyVault.AccessPolicies"
# Output: #vso[task.setvariable variable=My.KeyVault.AccessPolicies]{list: [{tenantId: ...,permissions: ...}]}
```


