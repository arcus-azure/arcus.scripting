<#
 .Synopsis
  Remove locks on a resource group

 .Description
  In some deployments, resource-locks are assigned. This function removes all these locks.

 .Parameter ResourceGroupnName
  The name of the resource group where the locks should be removed.

 .Parameter LockName
  The optional name of the lock to remove. When this is not provided, all the locks will be removed.
#>
function Remove-AzResourceGroupLocks {
    param(
        [Parameter(Mandatory=$true)][string]$ResourceGroupName = $(throw "ResourceGroup is required"),
        [Parameter(Mandatory=$false)][string]$LockName = $null
    )

    . $PSScriptRoot\Scripts\Remove-AzResourceGroupLocks.ps1 -ResourceGroupName $ResourceGroupName -LockName $LockName
}

Export-ModuleMember -Function Remove-AzResourceGroupLocks


<#
 .Synopsis
  Retrieve the AccessToken and subscriptionId based on the current AzContext.
  
 .Description
  Retrieve the AccessToken and subscriptionId based on the current AzContext. Ensure you have logged in (Connect-AzAccount) before calling this function.
#>
function Get-AzCachedAccessToken {
    . $PSScriptRoot\Scripts\Get-AzCachedAccessToken.ps1
}

Export-ModuleMember -Function Get-AzCachedAccessToken

<#
 .Synopsis
  Grant a resource access to all resources within a resource group.

 .Description
  Grant a resource access to all resources present within a specific resource group.

 .Parameter TargetResourceGroupName
  The name of the resource group to which access should be granted.

 .Parameter ResourceGroupName
  The name of the resource group where the resource is located which should be granted access.

 .Parameter ResourceName
  The name of the resource which should be granted access.

 .Parameter RoleDefinition
  The name of the role to assign.
#>
function New-AzResourceGroupRoleAssignment {
    param (
        [Parameter(Mandatory = $true)][string] $TargetResourceGroupName = $(throw "Target resource group name to which access should be granted is required"),
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name where the resource is located which should be granted access is required"),
        [Parameter(Mandatory = $true)][string] $ResourceName = $(throw "Name of the resource which should be granted access is required"),
        [Parameter(Mandatory = $true)][string] $RoleDefinitionName = $(throw "Name of the role definition is required")
    )

    . $PSScriptRoot\Scripts\New-AzResourceGroupRoleAssignment.ps1 -TargetResourceGroupName $TargetResourceGroupName -ResourceGroupName $ResourceGroupName -ResourceName $ResourceName -RoleDefinitionName $RoleDefinitionName
}