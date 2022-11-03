<#
 .Synopsis
  Return the app roles and their assignments that are present on an Azure Active Directory Application Registration.

 .Description
  Return the app roles that are present in an Azure Active Directory Application Registration and list the applications they are assigned to.

 .Parameter ClientId
  The client id of the Azure Active Directory Application Registration from which the role assignments are to be retrieved.

 .Parameter RolesAssignedToClientId
  The client id of the Azure Active Directory Application Registration to which roles are assigned.
#>
function Get-AzADAppRoleAssignments {
    param(
       [Parameter(Mandatory = $true)][string] $ClientId = $(throw "ClientId is required"),
       [Parameter(Mandatory = $false)][string] $RolesAssignedToClientId
    )
    . $PSScriptRoot\Scripts\Get-AzADAppRoleAssignments.ps1 -ClientId $ClientId -RolesAssignedToClientId $RolesAssignedToClientId
}

Export-ModuleMember -Function Get-AzADAppRoleAssignments