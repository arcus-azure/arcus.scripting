<#
 .Synopsis
  Disable all specified Logic Apps described in the order control JSON file.
  
 .Description
  Disables all specified Logic Apps in a specific order. The Logic Apps to be disabled and the order in which this will be done, will be defined in the configuration file (e.g. deploy-orderControl.json).

 .Parameter ResourceGroupName
  The resource group containing the Azure Logic Apps.
  
 .Parameter DeployFileName
  If your solution consists of multiple interfaces, you can specify the flow-specific name of the configuration file, if not, the script will look for a file named 'deploy-orderControl.json' by default.
#>
function Disable-AzLogicAppsFromConfig {
    param(
        [string][Parameter(Mandatory = $true)] $ResourceGroupName,
        [string] $DeployFileName = "deploy-orderControl.json"
    )
    
    . $PSScriptRoot\Scripts\Disable-AzLogicAppsFromConfig.ps1 -ResourceGroupName $ResourceGroupName -DeployFileName $DeployFileName
}

Export-ModuleMember -Function Disable-AzLogicAppsFromConfig

<#
 .Synopsis
  Enable all specified Logic Apps described in the order control JSON file.
  
 .Description
  Enables all specified Logic Apps in a specific order. The Logic Apps to be enabled and the order in which this will be done, will be defined in the configuration file (e.g. deploy-orderControl.json).

 .Parameter ResourceGroupName
  The resource group containing the Azure Logic Apps.
  
 .Parameter DeployFileName
  If your solution consists of multiple interfaces, you can specify the flow-specific name of the configuration file, if not, the script will look for a file named 'deploy-orderControl.json' by default.
#>
function Enable-AzLogicAppsFromConfig {
    param(
        [string][Parameter(Mandatory = $true)] $ResourceGroupName,
        [string] $DeployFileName = "deploy-orderControl.json"
    )
    
    . $PSScriptRoot\Scripts\Enable-AzLogicAppsFromConfig.ps1 -ResourceGroupName $ResourceGroupName -DeployFileName $DeployFileName
}

Export-ModuleMember -Function Enable-AzLogicAppsFromConfig
