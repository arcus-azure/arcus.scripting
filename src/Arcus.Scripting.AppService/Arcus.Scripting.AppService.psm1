<#
 .Synopsis
  Sets the value of an application setting within an Azure App Service.

 .Description
  The Set-AzAppServiceSetting cmdlet sets the value of an application setting within an Azure App Service.

 .Parameter ResourceGroupName
  The name of the of resource group under which the App Service exists.

 .Parameter AppServiceName
  The name of the App Service.

 .Parameter AppServiceSettingName
  The name of the application setting.

 .Parameter AppServiceSettingValue
  The value to be used for the application setting.

 .Parameter PrintSettingValuesIfVerbose
  Indicate whether or not to print the values of the current application settings in the verbose logging.
#>
function Set-AzAppServiceSetting {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
        [Parameter(Mandatory = $true)][string] $AppServiceName = $(throw = "App Service name is required"),
        [Parameter(Mandatory = $true)][string] $AppServiceSettingName = $(throw "App Service setting name is required"),
        [Parameter(Mandatory = $true)][string] $AppServiceSettingValue = $(throw "App Service value is required"),
        [Parameter(Mandatory = $false)][switch] $PrintSettingValuesIfVerbose = $false
    )

    if($PrintSettingValuesIfVerbose) {
        . $PSScriptRoot\Scripts\Set-AzAppServiceSetting.ps1 -ResourceGroupName $ResourceGroupName -AppServiceName $AppServiceName -AppServiceSettingName $AppServiceSettingName -AppServiceSettingValue $AppServiceSettingValue -PrintSettingValuesIfVerbose
    } else {
        . $PSScriptRoot\Scripts\Set-AzAppServiceSetting.ps1 -ResourceGroupName $ResourceGroupName -AppServiceName $AppServiceName -AppServiceSettingName $AppServiceSettingName -AppServiceSettingValue $AppServiceSettingValue
    }
    
}

Export-ModuleMember -Function Set-AzAppServiceSetting