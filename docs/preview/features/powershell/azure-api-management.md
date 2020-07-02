---
title: "Scripts related to interacting with Azure API Management"
layout: default
---

# Azure API Management

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Import-Module -Name Arcus.Scripting.ApiManagement
```

## Create a new API operation on the Azure API Management service

Create an operation on an existing API in Azure API Management.

| Parameter           | Mandatory | Description                                                                                              |
| ------------------- | --------- | -------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management service                                                 |
| `ServiceName`       | yes       | The name of the API Management service located in Azure                                                  |
| `ApiId`             | yes       | The ID to identify the API running in Azure API Management                                                     |
| `OperationId`       | yes       | The ID to identify the to-be-created operation on the API                                                |
| `Method`            | yes       | The method of the to-be-created operation on the API                                                     |
| `UrlTemplate`       | yes       | The URL-template, or endpoint-URL, of the to-be-created operation on the API                             |
| `OperationName`     | no        | The optional descriptive name to give to the to-be-created operation on the API (default: `OperationId`) |
| `Description`       | no        | The optional explanation to describe the to-be-created operation on the API                              |
| `PolicyFilePath`    | no        | The path to the file containing the optional policy of the to-be-created operation on the API            |

**Example**

Creates a new API operation on the Azure API Management service with using the default base operation policy.

```powershell
PS> Create-AzApiManagementApiOperation -ResourceGroup $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -OperationId $OperationId -Method $Method -UrlTemplate $UrlTemplate
# New API operation '$OperationName' on Azure API Management service was added.
```

Creates a new API operation on the API Management service with using a specific operation policy.

```powershell
PS> Create-AzApiManagementApiOperation -ResourceGroup $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -OperationId $OperationId -Method $Method -UrlTemplate $UrlTemplate -OperationName $OperationName -Description $Description -PolicyFilePath $PolicyFilePath
# New API operation '$OperationName' on API Management service was added.
```	

## Import policy to a product in the Azure API Management service

Imports a policy from a file to a product in Azure API Management.

| Parameter           | Mandatory | Description                                               |
| ------------------- | --------- | --------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management service  |
| `ServiceName`       | yes       | The name of the Azure API Management service located in Azure   |
| `ProductId`         | yes       | The ID to identify the product in Azure API Management          |
| `PolicyFilePath`    | yes       | The path to the file containing the to-be-imported policy |

```powershell
PS> Import-AzApiManagementProductPolicy -ResourceGroup $ResourceGroup -ServiceName $ServiceName -ProductId $ProductId -PolicyFilePath $PolicyFilePath
# Updating policy of the product '$ProductId'
```

## Import policy to an API in the Azure API Management service

Imports a base-policy from a file to an API in Azure API Management.

| Parameter           | Mandatory | Description                                               |
| ------------------- | --------- | --------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management service  |
| `ServiceName`       | yes       | The name of the API Management service located in Azure   |
| `ApiId`             | yes       | The ID to identify the API running in Azure API Management      |
| `PolicyFilePath`    | yes       | The path to the file containing the to-be-imported policy |

```powershell
PS> Import-AzApiManagementApiPolicy -ResourceGroup $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -PolicyFilePath $PolicyFilePath
# Updating policy of the API '$ApiId'
```

## Import policy to an operation in the Azure API Management service
Imports a policy from a file to an API operation in Azure API Management.

| Parameter           | Mandatory | Description                                                     |
| ------------------- | --------- | --------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management service        |
| `ServiceName`       | yes       | The name of the Azure API Management service located in Azure         |
| `ApiId`             | yes       | The ID to identify the API running in Azure API Management            |
| `OperationId`       | yes       | The ID to identify the operation for which to import the policy |
| `PolicyFilePath`    | yes       | The path to the file containing the to-be-imported policy       |

```powershell
PS> Import-AzApiManagementOperationPolicy -ResourceGroup $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -OperationId $OperationId -PolicyFilePath $PolicyFilePath
# Updating policy of the operation '$OperationId' in API '$ApiId'
```
