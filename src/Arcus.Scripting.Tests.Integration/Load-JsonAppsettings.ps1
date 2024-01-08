$filePath = "$PSScriptRoot\appsettings.json"
$localAppSettings = "$PSScriptRoot\appsettings.local.json"

if (Test-Path $localAppSettings) {
    $filePath = $localAppSettings
}

[string]$appsettings = Get-Content $filePath
return $config = ConvertFrom-Json $appsettings