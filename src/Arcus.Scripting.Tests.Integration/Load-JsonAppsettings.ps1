param(
    [string]$fileName
)

$filePath = "$PSScriptRoot\$fileName"
[string]$appsettings = Get-Content $filePath
 return $config = ConvertFrom-Json $appsettings