<#
 .Synopsis
  Disable all specified Logic Apps described in the order control JSON file.
  
 .Description
  Disables all specified Logic Apps in a specific order. The Logic Apps to be disabled and the order in which this will be done, will be defined in the configuration file (e.g. deploy-orderControl.json).

 .Parameter DeployFileName
  If your solution consists of multiple interfaces, you can specify the flow-specific name of the orderControl-file, if not, the script will look for a file named 'deploy-orderControl.json' by default.

 .Parameter ResourceGroupName
  The resource group containing the Azure Logic Apps.
#>
function Disable-AzLogicAppsFromConfig {
    param(
        [string] $DeployFileName = "deploy-orderControl.json",
        [string][Parameter(Mandatory = $true)] $ResourceGroupName
    )
    
    . $PSScriptRoot\Scripts\Disable-AzLogicAppsFromConfig.ps1 -DeployFileName $DeployFileName -ResourceGroupName $ResourceGroupName
}

Export-ModuleMember -Function Disable-AzLogicAppsFromConfig
