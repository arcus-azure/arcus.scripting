---
title: "Azure Integration Account"
layout: default
---

# Azure Integration Account

This module provides the following capabilities:
- [Uploading schemas into an Azure Integration Account](#uploading-schemas-into-an-azure-integration-account)
- [Uploading maps into an Azure Integration Account](#uploading-maps-into-an-azure-integration-account)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.IntegrationAccount -MinimumVersion 0.5.0
```

## Uploading schemas into an Azure Integration Account

Upload/update a single, or multiple schemas into an Azure Integration Account.

| Parameter              | Mandatory   | Description                                                                                                                            |
| ---------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`    | yes         | The name of the Azure resource group where the Azure Integration Account is located.                                                   |
| `Name`                 | yes         | The name of the Azure Integration Account into which the schemas are to be uploaded/updated.                                           |
| `SchemaFilePath`       | conditional | The full path of a schema that should be uploaded/updated. (_Mandatory if SchemasFolder has not been specified_).                      |
| `SchemasFolder`        | conditional | The path to a directory containing all schemas that should be uploaded/updated. (_Mandatory if SchemaFilePath has not been specified_).|
| `ArtifactsPrefix`      | no          | The prefix, if any, that should be added to the schemas before uploading/updating.                                                     |
| `RemoveFileExtensions` | no          | Indicator (switch) whether the extension should be removed from the name before uploading/updating.                                    |

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


## Uploading maps into an Azure Integration Account

Upload/update a single, or multiple maps into an Azure Integration Account.

| Parameter              | Mandatory   | Description                                                                                                                            |
| ---------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`    | yes         | The name of the Azure resource group where the Azure Integration Account is located.                                                   |
| `Name`                 | yes         | The name of the Azure Integration Account into which the maps are to be uploaded/updated.                                              |
| `MapFilePath`          | conditional | The full path of a map that should be uploaded/updated. (_Mandatory if MapsFolder has not been specified_).                            |
| `MapsFolder`           | conditional | The path to a directory containing all maps that should be uploaded/updated. (_Mandatory if MapFilePath has not been specified_).      |
| `MapType`              | no          | The type of map to be created, default to 'Xslt'. See possible values [here](https://docs.microsoft.com/en-us/powershell/module/az.logicapp/get-azintegrationaccountmap?view=azps-6.2.1#parameters).  |
| `ArtifactsPrefix`      | no          | The prefix, if any, that should be added to the maps before uploading/updating.                                                        |
| `RemoveFileExtensions` | no          | Indicator (switch) whether the extension should be removed from the name before uploading/updating.                                    |

**Example**  

Uploading a *single map* into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountMaps -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -MapFilePath "C:\Maps\MyMap.xslt"
# Uploading map 'MyMap.xslt' into the Azure Integration Account 'my-integration-account'.
# Map 'MyMap.xslt' has been uploaded into the Azure Integration Account 'my-integration-account'.
```

Uploading a *single map* into an Integration Account and remove the file-extension.  
```powershell
PS> Set-AzIntegrationAccountMaps -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -MapFilePath "C:\Maps\MyMap.xslt" -RemoveFileExtensions
# Uploading map 'MyMap' into the Azure Integration Account 'my-integration-account'.
# Map 'MyMap' has been uploaded into the Azure Integration Account 'my-integration-account'.
```
Uploading a *single map* into an Integration Account and set add a prefix to the name of the schema within the Integration Account.  
```powershell
PS> Set-AzIntegrationAccountMaps -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -MapFilePath "C:\Maps\MyMap.xslt" -ArtifactsPrefix 'dev-'
# Uploading smapchema 'dev-MyMap.xsd' into the Azure Integration Account 'my-integration-account'.
# Map 'dev-MyMap.xsd' has been uploaded into the Azure Integration Account 'my-integration-account'.
```

Uploading *all maps* located in a specific folder into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountMaps -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -MapsFolder "C:\Maps"
# Uploading map 'MyFirstMap.xslt' into the Azure Integration Account 'my-integration-account'.
# Map 'MyFirstMap.xslt' has been uploaded into the Azure Integration Account 'my-integration-account'.
# ----------
# Uploading map 'MySecondMap.xslt' into the Azure Integration Account 'my-integration-account'.
# Map 'MySecondMap.xslt' has been uploaded into the Azure Integration Account 'my-integration-account'.
# ----------
```

Uploading *all maps* located in a specific folder into an Integration Account and remove the file-extension.  
```powershell
PS> Set-AzIntegrationAccountMaps -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -MapsFolder "C:\Maps" -RemoveFileExtensions
# Uploading map 'MyFirstMap' into the Azure Integration Account 'my-integration-account'.
# Map 'MyFirstMap' has been uploaded into the Azure Integration Account 'my-integration-account'.
# ----------
# Uploading map 'MySecondMap' into the Azure Integration Account 'my-integration-account'.
# Map 'MySecondMap' has been uploaded into the Azure Integration Account 'my-integration-account'.
# ----------
```

Uploading *all maps* located in a specific folder into an Integration Account and remove the file-extension.  
```powershell
PS> Set-AzIntegrationAccountMaps -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -MapsFolder "C:\Maps" -ArtifactsPrefix 'dev-'
# Uploading map 'dev-MyFirstMap.xslt' into the Azure Integration Account 'my-integration-account'.
# Map 'dev-MyFirstMap.xslt' has been uploaded into the Azure Integration Account 'my-integration-account'.
# ----------
# Uploading map 'dev-MySecondMap.xslt' into the Azure Integration Account 'my-integration-account'
# Map 'dev-MySecondMap.xslt' has been uploaded into the Azure Integration Account 'my-integration-account'.
# ----------
```



