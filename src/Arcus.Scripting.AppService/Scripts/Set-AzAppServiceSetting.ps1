param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
    [Parameter(Mandatory = $true)][string] $AppServiceName = $(throw "App Service name is required"),
    [Parameter(Mandatory = $true)][string] $AppServiceSettingName = $(throw "App Service setting name is required"),
    [Parameter(Mandatory = $true)][string] $AppServiceSettingValue = $(throw "App Service value is required"),
    [Parameter(Mandatory = $false)][switch] $PrintSettingValuesIfVerbose = $false
)

Write-Verbose "Checking if the Azure App Service with name '$AppServiceName' can be found in the resource group '$ResourceGroupName'..."
$appService = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $AppServiceName -ErrorAction Ignore

if ($null -eq $appService) {
    throw "No Azure App Service with name '$AppServiceName' could be found in the resource group '$ResourceGroupName'"
}

Write-Host "Azure App service has been found for name '$AppServiceName' in the resource group '$ResourceGroupName'"
Write-Verbose "Extracting the existing application settings from the Azure App Service '$AppServiceName' in the resource group '$ResourceGroupName'..."
$appServiceSettings = $appService.SiteConfig.AppSettings

$existingSettings = @{ }
Write-Verbose "Existing Azure App Service application settings from the Azure App Service '$AppServiceName' in the resource group '$ResourceGroupName':"
foreach ($setting in $appServiceSettings) {
    $existingSettings[$setting.Name] = $setting.value
    if ($PrintSettingValuesIfVerbose) {
        Write-Verbose "$($setting.Name): $($setting.Value) (Azure App Service '$AppServiceName' in the resource group '$ResourceGroupName')"
    } else {
        Write-Verbose "$($setting.Name) (Azure App Service '$AppServiceName' in the resource group '$ResourceGroupName')"
    }
}

$existingSettings[$AppServiceSettingName] = $AppServiceSettingValue

Write-Verbose "Setting the application setting '$AppServiceSettingName' for the Azure App Service '$AppServiceName' in the resource group '$ResourceGroupName'"
try {
    $updatedAppService = Set-AzWebApp -ResourceGroupName $ResourceGroupName -Name $appServiceName -AppSettings $existingSettings

    Write-Verbose "Updated Azure App Service settings:"
    foreach ($setting in $updatedAppService.SiteConfig.AppSettings) {
        if ($PrintSettingValuesIfVerbose) {
            Write-Verbose "$($setting.Name): $($setting.Value)"
        } else {
            Write-Verbose "$($setting.Name)"
        }
    }
} catch {
    throw "The Azure App Service settings could not be updated for the Azure App Service '$AppServiceName' in the resource group '$ResourceGroupName'. Details: $($_.Exception.Message)"
}

Write-Host "Successfully set the application setting '$AppServiceSettingName' of the Azure App Service '$AppServiceName' in resource group '$ResourceGroupName'" -ForegroundColor Green