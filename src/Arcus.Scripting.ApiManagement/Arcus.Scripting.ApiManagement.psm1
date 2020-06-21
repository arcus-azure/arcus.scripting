<#
 .Synopsis
  Create an operation on an API in Azure API Management.

 .Description
  Create an operation on an existing API in Azure API Management.

 .Parameter ServiceName
  The name of the API Management service located in Azure.

 .Parameter ResourceGroupName
  The resource group containing the API Management service.

 .Parameter ApiId
  The ID to identify the API running in API Management.

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
        [string][Parameter(Mandatory = $true)] $ServiceName = $(throw "API management service name is required"),
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
