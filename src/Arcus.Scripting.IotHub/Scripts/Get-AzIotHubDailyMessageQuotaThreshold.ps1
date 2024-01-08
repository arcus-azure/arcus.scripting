param(
    [Parameter(Mandatory=$true)][string] $IotHubName = $(throw "Name of the Azure IoT Hub instance is required"),
    [Parameter(Mandatory=$true)][single] $QuotaPercentage = $(throw "Quota percentage is required"),
    [Parameter(Mandatory=$false)][string] $ResourceGroupName = ""
)

Write-Verbose "Getting single Azure IoT hub metric from '$IotHubName' in resource group '$ResourceGroupName'..."
$quotaMetric = Get-AzIotHubQuotaMetric -Name $IotHubName -ResourceGroupName $ResourceGroupName

Write-Verbose "Calculate quota percentage of Azure IoT hub metric from '$IotHubName' in resource group '$ResourceGroupName'..."
$result = [Math]::Round($quotaMetric.MaxValue * $QuotaPercentage)

Write-Host "Calculated '$result' as quota percentage of Azure IoT Hub metric from '$IotHubName' in resource group '$ResourceGroupName'"
return $result