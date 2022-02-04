param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
    [Parameter(Mandatory = $true)][string] $AppServiceName = $(throw "App Service name is required"),
    [Parameter(Mandatory = $true)][string] $AppServiceSettingName = $(throw "App Service setting name is required"),
    [Parameter(Mandatory = $true)][string] $AppServiceSettingValue = $(throw "App Service value is required"),
    [Parameter(Mandatory = $false)][switch] $PrintSettingValuesIfVerbose = $false
)

Write-Host "Checking if the App Service with name '$AppServiceName' can be found in the resource group '$ResourceGroupName'"
$appService = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $AppServiceName -ErrorAction Ignore

if ($appService -eq $null) {
    throw "No App Service with name '$AppServiceName' could be found in the resource group '$ResourceGroupName'"
}

Write-Host "Azure App service has been found for name '$AppServiceName'"
Write-Host "Extracting the existing application settings from Azure App Service"
$appServiceSettings = $appService.SiteConfig.AppSettings

$existingSettings = @{ }
Write-Verbose "Existing app settings:"
foreach ($setting in $appServiceSettings) {
    $existingSettings[$setting.Name] = $setting.value
    if ($PrintSettingValuesIfVerbose) {
        Write-Verbose "$($setting.Name): $($setting.Value)"
    } else {
        Write-Verbose "$($setting.Name)"
    }
}

$existingSettings[$AppServiceSettingName] = $AppServiceSettingValue

Write-Host "Setting the application setting '$AppServiceSettingName'"
try 
{
    $updatedAppService = Set-AzWebApp -ResourceGroupName $ResourceGroupName -Name $appServiceName -AppSettings $existingSettings

    Write-Verbose "Updated Azure App Service settings:"
    foreach($setting in $updatedAppService.SiteConfig.AppSettings) 
    {
        if($PrintSettingValuesIfVerbose)
        {
            Write-Verbose "$($setting.Name): $($setting.Value)"
        }
        else
        {
            Write-Verbose "$($setting.Name)"
        }
    }
}
catch 
{
    throw "The Azure App Service settings could not be updated. Details: $($_.Exception.Message)"
}

Write-Host "Successfully set the application setting '$AppServiceSettingName' of the Azure App Service '$AppServiceName' within Azure resource group '$ResourceGroupName'"