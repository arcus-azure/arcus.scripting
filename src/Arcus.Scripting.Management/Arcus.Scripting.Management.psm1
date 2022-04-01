<#
 .Synopsis
  Remove a soft deleted API Management instance.
 
 .Description
  Permanently remove a soft deleted API Management instance.

 .Parameter Name
  The name of the Azure API Management instance which has been soft deleted and will be permanently removed.
  
 .Parameter SubscriptionId
  [Optional] The Id of the subscription containing the Azure API Management instance. When not provided, it will be retrieved from the current context (Get-AzContext).
  
 .Parameter AccessToken
  [Optional] The access token to be used to restore the Azure API Management instance.   

 .Parameter EnvironmentName
  [Optional] The Azure Cloud environment in which the Azure API Management instance resides.

 .Parameter ApiVersion
  [Optional] The version of the api to be used.
#>
function Remove-AzApiManagementSoftDeletedService {
    param(
        [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the API Management instance is required"),
        [Parameter(Mandatory = $false)][string] $SubscriptionId = "",
        [Parameter(Mandatory = $false)][string] $AccessToken = "",
        [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud",        
        [Parameter(Mandatory = $false)][string] $ApiVersion = "2021-08-01"
    )

    . $PSScriptRoot\Scripts\Remove-AzApiManagementSoftDeletedService.ps1 -Name $Name -SubscriptionId $SubscriptionId -AccessToken $AccessToken -EnvironmentName $EnvironmentName -ApiVersion $ApiVersion
}

Export-ModuleMember -Function Remove-AzApiManagementSoftDeletedService

<#
 .Synopsis
  Restore a soft deleted API Management instance.
 
 .Description
  Restore a soft deleted API Management instance.

 .Parameter Name
  The name of the Azure API Management instance which has been soft deleted and will be restored.
 
 .Parameter SubscriptionId
  [Optional] The Id of the subscription containing the Azure API Management instance. When not provided, it will be retrieved from the current context (Get-AzContext).
  
 .Parameter AccessToken
  [Optional] The access token to be used to restore the Azure API Management instance. 
  
 .Parameter EnvironmentName
  [Optional] The Azure Cloud environment in which the Azure API Management instance resides.

 .Parameter ApiVersion
  [Optional] The version of the api to be used.
#>
function Restore-AzApiManagementSoftDeletedService {
    param(
        [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the API Management instance is required"),
        [Parameter(Mandatory = $false)][string] $SubscriptionId = "",
        [Parameter(Mandatory = $false)][string] $AccessToken = "", 
        [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud",           
        [Parameter(Mandatory = $false)][string] $ApiVersion = "2021-08-01"
    )

    . $PSScriptRoot\Scripts\Restore-AzApiManagementSoftDeletedService.ps1 -Name $Name -SubscriptionId $SubscriptionId -AccessToken $AccessToken -EnvironmentName $EnvironmentName -ApiVersion $ApiVersion
}

Export-ModuleMember -Function Restore-AzApiManagementSoftDeletedService