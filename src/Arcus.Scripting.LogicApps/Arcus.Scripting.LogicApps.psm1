<#
 .Synopsis
  Disable a specific Logic App.
  
 .Description
  Disables a specific Logic App.

 .Parameter SubscriptionId
  [Optional] The Id of the subscription containing the Azure Logic App. When not provided, it will be retrieved from the current context (Get-AzContext).
  
 .Parameter ResourceGroupName
  The resource group containing the Azure Logic Apps.
  
 .Parameter LogicAppName
  The name of the Azure Logic App to be enabled.
  
 .Parameter AccessToken
  [Optional] The access token to be used to enable the Azure Logic App.

#>
function Disable-AzLogicApp {
    param(
        [string][Parameter(Mandatory = $false)] $SubscriptionId = "",
        [string][Parameter(Mandatory = $true)] $ResourceGroupName,
        [string][Parameter(Mandatory = $true)] $LogicAppName,
        [string][Parameter(Mandatory = $false)] $AccessToken = ""
    )
    
    . $PSScriptRoot\Scripts\Disable-AzLogicApp.ps1 -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -AccessToken $AccessToken
}

Export-ModuleMember -Function Disable-AzLogicApp

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
  Enable a specific Logic App.
  
 .Description
  Enables a specific Logic App.

 .Parameter SubscriptionId
  [Optional] The Id of the subscription containing the Azure Logic App. When not provided, it will be retrieved from the current context (Get-AzContext).
  
 .Parameter ResourceGroupName
  The resource group containing the Azure Logic Apps.
  
 .Parameter LogicAppName
  The name of the Azure Logic App to be enabled.
  
 .Parameter AccessToken
  [Optional] The access token to be used to enable the Azure Logic App.

#>
function Enable-AzLogicApp {
    param(
        [string][Parameter(Mandatory = $false)] $SubscriptionId = "",
        [string][Parameter(Mandatory = $true)] $ResourceGroupName,
        [string][Parameter(Mandatory = $true)] $LogicAppName,
        [string][Parameter(Mandatory = $false)] $AccessToken = ""
    )
    
    . $PSScriptRoot\Scripts\Enable-AzLogicApp.ps1 -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -AccessToken $AccessToken
}

Export-ModuleMember -Function Enable-AzLogicApp

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