<#
 .Synopsis
  Remove locks on a resource group

 .Description
  In some deployments, resource-locks are assigned. This function removes all these locks.

 .Parameter ResourceGroupName
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
