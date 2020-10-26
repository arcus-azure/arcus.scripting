<#
 .Synopsis
  Inject external files inside your ARM template

 .Description
  In certain scenarios, you have to embed content into an ARM template to deploy it.
  However, the downside of it is that it's buried inside the template and tooling around it might be less ideal - An example of this is OpenAPI specifications you'd want to deploy.
  By using this command, you can inject external files inside your ARM template.
  Recommandation: Always inject the content in your ARM template as soon as possible, preferably during release build that creates the artifact

 .Parameter Path
  The file path to the ARM template to inject the external files into.
#>
function Inject-ArmContent {
    param (
        [string] $Path = $PSScriptRoot
    )
    . $PSScriptRoot\Scripts\Inject-ArmContent.ps1 -Path $Path
}

Export-ModuleMember -Function Inject-ArmContent

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