---
title: " Azure API Management"
layout: default
---

# Azure API Management

This module provides the following capabilities:
- [Creating a new API operation in the Azure API Management instance](#creating-a-new-api-operation-in-the-azure-api-management-instance)
- [Importing a policy to a product in the Azure API Management instance](#importing-a-policy-to-a-product-in-the-azure-api-management-instance)
- [Importing a policy to an API in the Azure API Management instance](#importing-a-policy-to-an-api-in-the-azure-api-management-instance)
- [Importing a policy to an operation in the Azure API Management instance](#importing-a-policy-to-an-operation-in-the-azure-api-management-instance)
- [Removing all Azure API Management defaults from the instance](#removing-all-azure-api-management-defaults-from-the-instance)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.ApiManagement
```

## Creating a new API operation in the Azure API Management instance

Create an operation on an existing API in Azure API Management.

| Parameter           | Mandatory | Description                                                                                              |
| ------------------- | --------- | -------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management instance                                          |
| `ServiceName`       | yes       | The name of the Azure API Management instance located in Azure                                           |
| `ApiId`             | yes       | The ID to identify the API running in Azure API Management                                               |
| `OperationId`       | yes       | The ID to identify the to-be-created operation on the API                                                |
| `Method`            | yes       | The method of the to-be-created operation on the API                                                     |
| `UrlTemplate`       | yes       | The URL-template, or endpoint-URL, of the to-be-created operation on the API                             |
| `OperationName`     | no        | The optional descriptive name to give to the to-be-created operation on the API (default: `OperationId`) |
| `Description`       | no        | The optional explanation to describe the to-be-created operation on the API                              |
| `PolicyFilePath`    | no        | The path to the file containing the optional policy of the to-be-created operation on the API            |

**Example**

Creates a new API operation on the Azure API Management instance with using the default base operation policy.

```powershell
PS> Create-AzApiManagementApiOperation -ResourceGroup $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -OperationId $OperationId -Method $Method -UrlTemplate $UrlTemplate
# New API operation '$OperationName' on Azure API Management instance was added.
```

Creates a new API operation on the Azure API Management instance with using a specific operation policy.

```powershell
PS> Create-AzApiManagementApiOperation -ResourceGroup $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -OperationId $OperationId -Method $Method -UrlTemplate $UrlTemplate -OperationName $OperationName -Description $Description -PolicyFilePath $PolicyFilePath
# New API operation '$OperationName' on API Management instance was added.
```	

## Importing a policy to a product in the Azure API Management instance

Imports a policy from a file to a product in Azure API Management.

| Parameter           | Mandatory | Description                                                     |
| ------------------- | --------- | --------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management instance |
| `ServiceName`       | yes       | The name of the Azure API Management instance located in Azure  |
| `ProductId`         | yes       | The ID to identify the product in Azure API Management          |
| `PolicyFilePath`    | yes       | The path to the file containing the to-be-imported policy       |

```powershell
PS> Import-AzApiManagementProductPolicy -ResourceGroup $ResourceGroup -ServiceName $ServiceName -ProductId $ProductId -PolicyFilePath $PolicyFilePath
# Updating policy of the product '$ProductId'
```

## Importing a policy to an API in the Azure API Management instance

Imports a base-policy from a file to an API in Azure API Management.

| Parameter           | Mandatory | Description                                                      |
| ------------------- | --------- | ---------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management instance  |
| `ServiceName`       | yes       | The name of the Azure API Management instance located in Azure   |
| `ApiId`             | yes       | The ID to identify the API running in Azure API Management       |
| `PolicyFilePath`    | yes       | The path to the file containing the to-be-imported policy        |

```powershell
PS> Import-AzApiManagementApiPolicy -ResourceGroup $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -PolicyFilePath $PolicyFilePath
# Updating policy of the API '$ApiId'
```

## Importing a policy to an operation in the Azure API Management instance
Imports a policy from a file to an API operation in Azure API Management.

| Parameter           | Mandatory | Description                                                     |
| ------------------- | --------- | --------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure API Management instance |
| `ServiceName`       | yes       | The name of the Azure API Management service located in Azure   |
| `ApiId`             | yes       | The ID to identify the API running in Azure API Management      |
| `OperationId`       | yes       | The ID to identify the operation for which to import the policy |
| `PolicyFilePath`    | yes       | The path to the file containing the to-be-imported policy       |   

```powershell
PS> Import-AzApiManagementOperationPolicy -ResourceGroup $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -OperationId $OperationId -PolicyFilePath $PolicyFilePath
# Updating policy of the operation '$OperationId' in API '$ApiId'
```

## Removing all Azure API Management defaults from the instance

Remove all default API's and products from the Azure API Management instance ('echo-api' API, 'starter' & 'unlimited' products), including the subscriptions.

| Parameter       | Mandatory | Description                                                     |
| --------------- | --------- | --------------------------------------------------------------- |
| `ResourceGroup` | yes       | The resource group containing the Azure API Management instance |
| `ServiceName`   | yes       | The name of the Azure API Management instance located in Azure  |

```powershell
PS> Remove-AzApiManagementDefaults -ResourceGroup $ResourceGroup -ServiceName $ServiceName
# Removing Echo Api...
# Removing Starter product...
# Removing Unlimited product...
```
