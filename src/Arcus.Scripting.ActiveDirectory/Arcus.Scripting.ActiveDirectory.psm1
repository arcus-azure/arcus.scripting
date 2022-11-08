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

<#
 .Synopsis
  Add and assign a role to an Azure Active Directory Application Registration.

 .Description
  Add a role to an Azure Active Directory Application Registration and assign the role to a different Active Directory Application Registration.

 .Parameter ClientId
  The client id of the Azure Active Directory Application Registration to which the role will be added.

 .Parameter Role
  The name of the role to add and assign.

 .Parameter AssignRoleToClientId
  The client id of the Azure Active Directory Application Registration to which the role will be assigned.
#>
function Add-AzADAppRoleAssignment {
    param(
        [Parameter(Mandatory = $true)][string] $ClientId = $(throw "ClientId is required"),
        [Parameter(Mandatory = $true)][string] $Role = $(throw "Role is required"),
        [Parameter(Mandatory = $true)][string] $AssignRoleToClientId = $(throw "ClientId to assign the role to is required")
    )
    . $PSScriptRoot\Scripts\Add-AzADAppRoleAssignment.ps1 -ClientId $ClientId -Role $Role -AssignRoleToClientId $AssignRoleToClientId
}

Export-ModuleMember -Function Add-AzADAppRoleAssignment