<#
 .Synopsis
  Return the app roles and their assignments that are present on an Azure Active Directory Application Registration.

 .Description
  Return the app roles that are present in an Azure Active Directory Application Registration and list the applications they are assigned to.

 .Parameter ClientId
  The client id of the Azure Active Directory Application Registration from which the role assignments are to be retrieved.
#>
function Get-AzADAppRoleAssignments {
    param(
       [Parameter(Mandatory = $true)][string] $ClientId = $(throw "ClientId is required")
    )
    . $PSScriptRoot\Scripts\Get-AzADAppRoleAssignments.ps1 -ClientId $ClientId
}

Export-ModuleMember -Function Get-AzADAppRoleAssignments