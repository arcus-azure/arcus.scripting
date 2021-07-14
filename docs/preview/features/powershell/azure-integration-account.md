---
title: "Scripts related to interacting with an Azure Integration Account"
layout: default
---

# Azure Integration Account

This module provides the following capabilities:
- [Uploading schemas into an Azure Integration Account](#uploading-schemas-into-an-azure-integration-account)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.IntegrationAccount
```

## Uploading schemas into an Azure Integration Account

Upload/update a single, or multiple schemas into an Azure Integration Account.

| Parameter              | Mandatory | Description                                                                                                                            |
| ---------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`    | yes       | The name of the Azure resource group where the Azure Integration Account is located.                                                   |
| `Name`                 | yes       | The name of the Azure Integration Account into which the schemas are to be uploaded/updated.                                           |
| `SchemaFilePath`       | no        | The full path of a schema that should be uploaded/updated. (Mandatory if SchemasFolder has not been specified).                        |
| `SchemasFolder`        | no        | The path to a directory containing all schemas that should be uploaded/updated. (Mandatory if SchemaFilePath has not been specified).  |
| `ArtifactsPrefix`      | no        | The prefix, if any, that should be added to the schemas before uploading/updating.                                                     |
| `RemoveFileExtensions` | no        | Indicator (switch) whether the extension should be removed from the name before uploading/updating.                                    |

**Example**  

Uploading a *single schema* into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountSchemas -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -SchemaFilePath "C:\Schemas\MySchema.xsd"
# Uploading schema 'MySchema.xsd' into the Azure Integration Account 'my-integration-account'.
# Schema 'MySchema.xsd' has been uploaded into the Azure Integration Account 'my-integration-account'.
```

Uploading a *single schema* into an Integration Account and remove the file-extension.  
```powershell
PS> Set-AzIntegrationAccountSchemas -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -SchemaFilePath "C:\Schemas\MySchema.xsd" -RemoveFileExtensions
# Uploading schema 'MySchema' into the Azure Integration Account 'my-integration-account'.
# Schema 'MySchema' has been uploaded into the Azure Integration Account 'my-integration-account'.
```
Uploading a *single schema* into an Integration Account and set add a prefix to the name of the schema within the Integration Account.  
```powershell
PS> Set-AzIntegrationAccountSchemas -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -SchemaFilePath "C:\Schemas\MySchema.xsd" -ArtifactsPrefix 'dev-'
# Uploading schema 'dev-MySchema.xsd' into the Azure Integration Account 'my-integration-account'.
# Schema 'dev-MySchema.xsd' has been uploaded into the Azure Integration Account 'my-integration-account'.
```

Uploading *all schemas* located in a specific folder into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountSchemas -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -SchemasFolder "C:\Schemas"
# Uploading schema 'MyFirstSchema.xsd' into the Azure Integration Account 'my-integration-account'.
# Schema 'MyFirstSchema.xsd' has been uploaded into the Azure Integration Account 'my-integration-account'.
# ----------
# Uploading schema 'MySecondSchema.xsd' into the Azure Integration Account 'my-integration-account'.
# Schema 'MySecondSchema.xsd' has been uploaded into the Azure Integration Account 'my-integration-account'.
# ----------
```

Uploading *all schemas* located in a specific folder into an Integration Account and remove the file-extension.  
```powershell
PS> Set-AzIntegrationAccountSchemas -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -SchemasFolder "C:\Schemas" -RemoveFileExtensions
# Uploading schema 'MyFirstSchema' into the Azure Integration Account 'my-integration-account'.
# Schema 'MyFirstSchema' has been uploaded into the Azure Integration Account 'my-integration-account'.
# ----------
# Uploading schema 'MySecondSchema' into the Azure Integration Account 'my-integration-account'.
# Schema 'MySecondSchema' has been uploaded into the Azure Integration Account 'my-integration-account'.
# ----------
```

Uploading *all schemas* located in a specific folder into an Integration Account and remove the file-extension.  
```powershell
PS> Set-AzIntegrationAccountSchemas -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -SchemasFolder "C:\Schemas" -ArtifactsPrefix 'dev-'
# Uploading schema 'dev-MyFirstSchema.xsd' into the Azure Integration Account 'my-integration-account'.
# Schema 'dev-MyFirstSchema.xsd' has been uploaded into the Azure Integration Account 'my-integration-account'.
# ----------
# Uploading schema 'dev-MySecondSchema.xsd' into the Azure Integration Account 'my-integration-account'
# Schema 'dev-MySecondSchema.xsd' has been uploaded into the Azure Integration Account 'my-integration-account'.
# ----------
```




