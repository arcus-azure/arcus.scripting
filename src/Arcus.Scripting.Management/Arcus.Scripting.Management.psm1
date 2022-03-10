<#
 .Synopsis
  Remove a soft deleted API Management instance.
 
 .Description
  Permanently remove a soft deleted API Management instance.

 .Parameter Name
  The name of the Azure API Management instance which has been soft deleted and will be permanently removed.
#>
function Remove-AzApiManagementSoftDeletedService {
    param(
        [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the API Management instance is required")
    )

    . $PSScriptRoot\Scripts\Remove-AzApiManagementSoftDeletedService.ps1 -Name $Name
}

Export-ModuleMember -Function Set-AzIntegrationAccountSchemas

<#
 .Synopsis
  Restore a soft deleted API Management instance.
 
 .Description
  Restore a soft deleted API Management instance.

 .Parameter Name
  The name of the Azure API Management instance which has been soft deleted and will be restored.
#>
function Restore-AzApiManagementSoftDeletedService {
    param(
        [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the API Management instance is required")
    )

    . $PSScriptRoot\Scripts\Restore-AzApiManagementSoftDeletedService.ps1 -Name $Name
}