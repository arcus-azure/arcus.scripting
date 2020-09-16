<#
 .Synopsis
  Backs up an API Management service.

 .Description
  The Backup-AzApiManagement cmdlet backs up an instance of an Azure API Management service by getting the account storage key and creating an new storage context. 
  This cmdlet stores the backup as an Azure Storage blob.

 .Parameter ResourceGroupName
  The name of the of resource group under which the API Management deployment exists.

 .Parameter StorageAccountName
  The name of the Storage account for which this cmdlet gets keys.

 .Parameter ServiceName
  The name of the API Management deployment that this cmdlet backs up.

 .Parameter TargetContainerName
  The name of the container of the blob for the backup. If the container does not exist, this cmdlet creates it.

 .Parameter TargetBlobName
  The name of the blob for the backup. If the blob does not exist, this cmdlet creates it. 
  This cmdlet generates a default value based on the following pattern: {Name}-{yyyy-MM-dd-HH-mm}.apimbackup

 .Parameter PassThru
  Indicates that this cmdlet returns the backed up PsApiManagement object, if the operation succeeds.

 .Parameter DefaultProfile
  The credentials, account, tenant, and subscription used for communication with azure.
#>
function Backup-AzApiManagementService {
    param(
        [string][parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
        [string][parameter(Mandatory = $true)] $StorageAccountName = $(throw "Storage account name is required"),
        [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API managgement service name is required"),
        [string][parameter(Mandatory = $true)] $TargetContainerName = $(throw "Name of the target blob container is required"),
        [string][parameter(Mandatory = $false)] $TargetBlobName = $null,
        [switch][parameter(Mandatory = $false)] $PassThru = $false,
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer][parameter(Mandatory = $false)] $DefaultProfile = $null
    )

    if ($PassThru) {
        . $PScriptRoot\Script\Backup-AzApiManagementService.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -ServiceName $ServiceName -TargetContainerName $TargetContainerName -TargetBlobName $TargetBlobName -PassThru
    } else {
        . $PScriptRoot\Script\Backup-AzApiManagementService.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -ServiceName $ServiceName -TargetContainerName $TargetContainerName -TargetBlobName $TargetBlobName
    }
}

<#
 .Synopsis
  Create an operation on an API in Azure API Management.

 .Description
  Create an operation on an existing API in Azure API Management.

 .Parameter ResourceGroup
  The resource group containing the API Management service.

 .Parameter ServiceName
  The name of the API Management service located in Azure.

 .Parameter ServiceName
  The name of the Azure API Management instance.

 .Parameter ApiId
  The ID to identify the API running in Azure API Management.

 .Parameter OperationId
  The ID to identify the to-be-created operation on the API.

 .Parameter Method
  The method of the to-be-created operation on the API.

 .Parameter UrlTemplate
  The URL-template, or endpoint-URL, of the to-be-created operation on the API.

 .Parameter OperationName
  The optional descriptive name to give to the to-be-created operation on the API.

 .Parameter Description
  The optional explanation to describe the to-be-created operation on the API.

 .Parameter PolicyFilePath
  The path to the file containing the optional policy of the to-be-created operation on the API.
#>
function Create-AzApiManagementApiOperation {
    param(
        [string][Parameter(Mandatory = $true)] $ResourceGroup = $(throw "Resource group is required"),
        [string][Parameter(Mandatory = $true)] $ServiceName = $(throw "Service name is required"),
        [string][Parameter(Mandatory = $true)] $ApiId = $(throw "API ID is required"),
        [string][Parameter(Mandatory = $true)] $OperationId = $(throw "Operation ID is required"),
        [string][Parameter(Mandatory = $true)] $Method = $(throw "Method is required"),
        [string][Parameter(Mandatory = $true)] $UrlTemplate = $(throw "URL template is required"),
        [string][Parameter(Mandatory = $false)] $OperationName = $OperationId,
        [string][Parameter(Mandatory = $false)] $Description = "",
        [string][Parameter(Mandatory = $false)] $PolicyFilePath = ""
    )
    . $PSScriptRoot\Scripts\Create-AzApiManagementApiOperation.ps1 -ResourceGroup $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -OperationId $OperationId -Method $Method -UrlTemplate $UrlTemplate -OperationName $OperationName -Description $Description -PolicyFilePath $PolicyFilePath
}

Export-ModuleMember -Function Create-AzApiManagementApiOperation

<#
 .Synopsis
  Import a policy to a product in Azure API Management.

 .Description
  Import a policy to a product in Azure API Management.

 .Parameter ResourceGroupName
  The resource group containing the Azure API Management instance.

 .Parameter ServiceName
  The name of the Azure API Management instance located in Azure.

 .Parameter ProductId
  The ID to identify the product in Azure API Management.

 .Parameter PolicyFilePath
  The path to the file containing the optional policy of the to-be-imported policy on the API.
#>
function Import-AzApiManagementProductPolicy {
    param(
        [string][parameter(Mandatory = $true)] $ResourceGroup = $(throw "Resource group is required"),
        [string][parameter(Mandatory = $true)] $ServiceName = $(throw = "Service name is required"),
        [string][parameter(Mandatory = $true)] $ProductId = $(throw "Product ID is required"),
        [string][parameter(Mandatory = $true)] $PolicyFilePath = $(throw "Policy file path is required")
    )

    . $PSScriptRoot\Scripts\Import-AzApiManagementProductPolicy.ps1 -ResourceGroup $ResourceGroup -ServiceName $ServiceName -ProductId $ProductId -PolicyFilePath $PolicyFilePath
}

Export-ModuleMember -Function Import-AzApiManagementProductPolicy

<#
.Synopsis
  Remove all defaults from the API Management instance.

 .Description
 Remove all default API's and products from an Azure API Management instance ('echo-api' API, 'starter' & 'unlimited' products), including the subscriptions. 

 .Parameter ResourceGroup
  The resource group containing the Azure API Management instance.

 .Parameter ServiceName
 The name of the Azure API Management instance.
#>
function Remove-AzApiManagementDefaults {
  param(
      [string][Parameter(Mandatory = $true)] $ResourceGroup = $(throw "Resource group is required"),
      [string][Parameter(Mandatory = $true)] $ServiceName = $(throw "Service name is required")
  )

. $PSScriptRoot\Scripts\Remove-AzApiManagementDefaults.ps1 -ResourceGroup $ResourceGroup -ServiceName $ServiceName 
}

Export-ModuleMember -Function Remove-AzApiManagementDefaults

<#
 .Synopsis
  Import a policy to an API in Azure API Management.

 .Description
  Import a base-policy to an API hosted in Azure API Management.

 .Parameter ResourceGroup
 The resource group containing the Azure API Management instance.

 .Parameter ServiceName
  The name of the Azure API Management service located in Azure.

 .Parameter ApiId
  The ID to identify the API running in API Management.

 .Parameter PolicyFilePath
  The path to the file containing the optional policy of the to-be-imported policy on the API.
#>
function Import-AzApiManagementApiPolicy {
    param(
        [string][parameter(Mandatory = $true)] $ResourceGroup = $(throw = "Resource group is required"),
        [string][parameter(Mandatory = $true)] $ServiceName = $(throw = "Service name is required"),
        [string][parameter(Mandatory = $true)] $ApiId = $(throw = "API ID is required"),
        [string][parameter(Mandatory = $true)] $PolicyFilePath = $(throw "Policy file path is required")
    )

    . $PSScriptRoot\Scripts\Import-AzApiManagementApiPolicy.ps1 -ResourceGroup $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -PolicyFilePath $PolicyFilePath
}

Export-ModuleMember -Function Import-AzApiManagementApiPolicy

<#
 .Synopsis
 Imports a policy to an operation in Azure API Management.

 .Description
  Imports a policy from a file to an API operation in Azure API Management.

 .Parameter ResourceGroup
  The resource group containing the Azure API Management instance.

 .Parameter ServiceName
  The name of the Azure API Management instance located in Azure.
  
 .Parameter ApiId
  The ID to identify the API running in Azure API Management.

 .Parameter OperationId
  The ID to identify the operation for which to import the policy.

 .Parameter PolicyFilePath
  The path to the file containing the to-be-imported policy.
#>
function Import-AzApiManagementOperationPolicy {
    param(
        [string][Parameter(Mandatory = $true)] $ResourceGroup = $(throw "Resource group is required"),
        [string][Parameter(Mandatory = $true)] $ServiceName = $(throw "API management service name is required"),
        [string][Parameter(Mandatory = $true)] $ApiId = $(throw "API ID is required"),
        [string][Parameter(Mandatory = $true)] $OperationId = $(throw "Operation ID is required"),
        [string][parameter(Mandatory = $true)] $PolicyFilePath = $(throw "Policy file path is required")
    )

    . $PSScriptRoot\Scripts\Import-AzApiManagementOperationPolicy.ps1 -ResourceGroup $ResourceGroup -ServiceName $ServiceName -ApiId $ApiId -OperationId $OperationId -PolicyFilePath $PolicyFilePath
}
