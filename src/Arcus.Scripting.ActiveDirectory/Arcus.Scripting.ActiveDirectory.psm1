<#
 .Synopsis
  Return the app roles and their assignments that are present on an Azure Active Directory Application Registration.

 .Description
  Return the app roles that are present in an Azure Active Directory Application Registration and list the applications they are assigned to.

 .Parameter ClientId
  The client ID of the Azure Active Directory Application Registration from which the role assignments are to be retrieved.

 .Parameter RolesAssignedToClientId
  The client ID of the Azure Active Directory Application Registration to which roles are assigned.
#>
function List-AzADAppRoleAssignments {
    param(
       [Parameter(Mandatory = $true)][string] $ClientId = $(throw "ClientId is required"),
       [Parameter(Mandatory = $false)][string] $RolesAssignedToClientId
    )
    . $PSScriptRoot\Scripts\List-AzADAppRoleAssignments.ps1 -ClientId $ClientId -RolesAssignedToClientId $RolesAssignedToClientId
}

Export-ModuleMember -Function List-AzADAppRoleAssignments

<#
 .Synopsis
  Add and assign a role to an Azure Active Directory Application Registration.

 .Description
  Add a role to an Azure Active Directory Application Registration and assign the role to a different Active Directory Application Registration.

 .Parameter ClientId
  The client ID of the Azure Active Directory Application Registration to which the role will be added.

 .Parameter Role
  The name of the role to add and assign.

 .Parameter AssignRoleToClientId
  The client ID of the Azure Active Directory Application Registration to which the role will be assigned.
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

<#
 .Synopsis
  Remove a role assignment from an Azure Active Directory Application Registration.

 .Description
  Remove a role assignment from an Azure Active Directory Application Registration and optionally remove the role if no role assignments are left.

 .Parameter ClientId
  The client ID of the Azure Active Directory Application Registration on which the role is present.

 .Parameter Role
  The name of the role to remove the assignment for.

 .Parameter RemoveRoleFromClientId
  The client ID of the Azure Active Directory Application Registration for which the role assignment will be removed.

 .Parameter PassThru
  Indicates that the role will be removed from the Azure Active Directory Application Registration if no role assigments are left.
#>
function Remove-AzADAppRoleAssignment {
    param(
        [Parameter(Mandatory = $true)][string] $ClientId = $(throw "ClientId is required"),
        [Parameter(Mandatory = $true)][string] $Role = $(throw "Role is required"),
        [Parameter(Mandatory = $true)][string] $RemoveRoleFromClientId = $(throw "ClientId to remove the role from is required"),
        [Parameter(Mandatory = $false)][switch] $RemoveRoleIfNoAssignmentsAreLeft = $false
    )
    
    if ($RemoveRoleIfNoAssignmentsAreLeft) {
        . $PSScriptRoot\Scripts\Remove-AzADAppRoleAssignment.ps1 -ClientId $ClientId -Role $Role -RemoveRoleFromClientId $RemoveRoleFromClientId -RemoveRoleIfNoAssignmentsAreLeft
    } else {
        . $PSScriptRoot\Scripts\Remove-AzADAppRoleAssignment.ps1 -ClientId $ClientId -Role $Role -RemoveRoleFromClientId $RemoveRoleFromClientId
    }
}

Export-ModuleMember -Function Remove-AzADAppRoleAssignment