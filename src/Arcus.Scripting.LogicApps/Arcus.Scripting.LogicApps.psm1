<#
 .Synopsis
  Cancel all running instances of a specific Logic App.
  
 .Description
  Cancel all running instances of a specific Logic App.
  
 .Parameter ResourceGroupName
  The resource group containing the Azure Logic App.
  
 .Parameter LogicAppName
  The name of the Azure Logic App.

#>
function Cancel-AzLogicAppRuns {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of the resource group is required"),
        [Parameter(Mandatory = $true)][string] $LogicAppName = $(throw "Name of the logic app is required")
    )
    
    . $PSScriptRoot\Scripts\Cancel-AzLogicAppRuns.ps1 -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName
}

Export-ModuleMember -Function Cancel-AzLogicAppRuns

<#
 .Synopsis
  Resubmit all failed instances of a specific Logic App.
  
 .Description
  Resubmit all failed instances of a specific Logic App within a specified start and end time.
  
 .Parameter ResourceGroupName
  The resource group containing the Azure Logic App.
  
 .Parameter LogicAppName
  The name of the Azure Logic App.

 .Parameter StartTime
  The start time of the failed instances of the Azure Logic App.

 .Parameter EndTime
  The end time of the failed instances of the Azure Logic App.

#>
function Resubmit-FailedAzLogicAppRuns {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of the resource group is required"),
        [Parameter(Mandatory = $true)][string] $LogicAppName = $(throw "Name of the logic app is required"),
        [Parameter(Mandatory = $true)][datetime] $StartTime = $(throw "Start time is required"),
        [Parameter(Mandatory = $false)][datetime] $EndTime
    )
    
    . $PSScriptRoot\Scripts\Resubmit-FailedAzLogicAppRuns.ps1 -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName
}

Export-ModuleMember -Function Resubmit-FailedAzLogicAppRuns

<#
 .Synopsis
  Disable a specific Logic App.
  
 .Description
  Disables a specific Logic App.
  
 .Parameter EnvironmentName
  [Optional] The Azure Cloud environment in which the Azure Logic App resides.
  
 .Parameter SubscriptionId
  [Optional] The Id of the subscription containing the Azure Logic App. When not provided, it will be retrieved from the current context (Get-AzContext).
  
 .Parameter ResourceGroupName
  The resource group containing the Azure Logic Apps.
  
 .Parameter LogicAppName
  The name of the Azure Logic App to be enabled.
  
 .Parameter ApiVersion
  [Optional] The version of the api to be used to disable the Azure Logic App.
  
 .Parameter AccessToken
  [Optional] The access token to be used to enable the Azure Logic App.

#>
function Disable-AzLogicApp {
    param(
        [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud",
        [Parameter(Mandatory = $false)][string] $SubscriptionId = "",
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of the resource group is required"),
        [Parameter(Mandatory = $true)][string] $LogicAppName = $(throw "Name of the logic app is required"),
        [Parameter(Mandatory = $false)][string] $ApiVersion = "2016-06-01",
        [Parameter(Mandatory = $false)][string] $AccessToken = ""
    )
    
    . $PSScriptRoot\Scripts\Disable-AzLogicApp.ps1  -EnvironmentName $EnvironmentName -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -ApiVersion $ApiVersion -AccessToken $AccessToken
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
  
 .Parameter ResourcePrefix
  The prefix assigned to all Azure Logic Apps, which can differ per environment.
  
 .Parameter EnvironmentName
  [Optional] The Azure Cloud environment in which the Azure Logic App resides.
  
 .Parameter ApiVersion
  [Optional] The version of the api to be used to disable the Azure Logic App.
#>
function Disable-AzLogicAppsFromConfig {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
        [Parameter(Mandatory = $true)][string] $DeployFileName = "deploy-orderControl.json",
        [Parameter(Mandatory = $false)][string] $ResourcePrefix = "",
        [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud",
        [Parameter(Mandatory = $false)][string] $ApiVersion = "2016-06-01"
    )
    
    . $PSScriptRoot\Scripts\Disable-AzLogicAppsFromConfig.ps1 -ResourceGroupName $ResourceGroupName -DeployFileName $DeployFileName -ResourcePrefix $ResourcePrefix -EnvironmentName $EnvironmentName -ApiVersion $ApiVersion
}

Export-ModuleMember -Function Disable-AzLogicAppsFromConfig

<#
 .Synopsis
  Enable a specific Logic App.
  
 .Description
  Enables a specific Logic App.
  
 .Parameter EnvironmentName
  [Optional] The Azure Cloud environment in which the Azure Logic App resides.
  
 .Parameter SubscriptionId
  [Optional] The Id of the subscription containing the Azure Logic App. When not provided, it will be retrieved from the current context (Get-AzContext).
  
 .Parameter ResourceGroupName
  The resource group containing the Azure Logic Apps.
  
 .Parameter LogicAppName
  The name of the Azure Logic App to be enabled.
  
 .Parameter ApiVersion
  [Optional] The version of the api to be used to enable the Azure Logic App.
  
 .Parameter AccessToken
  [Optional] The access token to be used to enable the Azure Logic App.


#>
function Enable-AzLogicApp {
    param(
        [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud",
        [Parameter(Mandatory = $false)][string] $SubscriptionId = "",
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is reqiured"),
        [Parameter(Mandatory = $true)][string] $LogicAppName = $(throw "Name of logic app is required"),
        [Parameter(Mandatory = $false)][string] $ApiVersion = "2016-06-01",
        [Parameter(Mandatory = $false)][string] $AccessToken = ""
    )
    
    . $PSScriptRoot\Scripts\Enable-AzLogicApp.ps1 -EnvironmentName $EnvironmentName -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -ApiVersion $ApiVersion -AccessToken $AccessToken
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
  
 .Parameter ResourcePrefix
  The prefix assigned to all Azure Logic Apps, which can differ per environment.
  
 .Parameter EnvironmentName
  [Optional] The Azure Cloud environment in which the Azure Logic App resides.
  
 .Parameter ApiVersion
  [Optional] The version of the api to be used to enable the Azure Logic App.
#>
function Enable-AzLogicAppsFromConfig {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
        [Parameter(Mandatory = $true)][string] $DeployFileName = "deploy-orderControl.json",
        [Parameter(Mandatory = $false)][string] $ResourcePrefix = "",
        [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud",
        [Parameter(Mandatory = $false)][string] $ApiVersion = "2016-06-01"
    )
    
    . $PSScriptRoot\Scripts\Enable-AzLogicAppsFromConfig.ps1 -ResourceGroupName $ResourceGroupName -DeployFileName $DeployFileName -ResourcePrefix $ResourcePrefix -EnvironmentName $EnvironmentName -ApiVersion $ApiVersion
}

Export-ModuleMember -Function Enable-AzLogicAppsFromConfig
