---
title: "Azure App Service"
layout: default
---

# Azure App Service

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.AppService
```

## Set an app setting within an Azure App Service

Create/update a single application setting within an Azure App Service.

| Parameter                     | Mandatory   | Description                                                                                           |
| ----------------------------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`           | yes         | The name of the Azure resource group where the Azure App Service is located.                          |
| `AppServiceName`              | yes         | The name of the Azure App Service where the application setting will be created/updated.              |
| `AppServiceSettingName`       | yes         | The name of the application setting that will be created/updated.                                     |
| `AppServiceSettingValue`      | yes         | The value of the application setting that will be created/updated.                                    |
| `PrintSettingValuesIfVerbose` | no          | Indicator (switch) whether the values of the application settings will be written to the verbose log. |

**Example**  

Setting an application setting within an Azure App Service.  
```powershell
PS> Set-AzAppServiceSetting `
-ResourceGroupName 'my-resource-group' `
-AppServiceName 'my-app-service' `
-AppServiceSettingName 'my-app-setting' `
-AppServiceSettingValue 'my-value'
# Checking if the App Service with name 'my-app-service' can be found in the resource group 'my-resource-group'
# App service has been found
# Extracting the existing application settings
# Setting the application setting 'my-app-setting'
# Successfully set the application setting 'my-app-setting' of the App Service 'my-app-service' within resource group 'my-resource-group'
```
