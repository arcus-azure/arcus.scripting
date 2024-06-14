<#
 .Synopsis
  Return the the current quota of Azure IoT Hub messages.

 .Description
  Retrieves one specific percentage quota metric of an Azure IoT Hub's total messages.

 .Parameter IotHubName
  The name of the Azure IoT Hub from where the message quota metric should be retrieved.

 .Parameter ResourceGroupName
  The resource group containing the Azure IoT Hub.

 .Parameter QuotaPercentage
  The requested percentage of the quota metric of the Azure IoT Hub's total messages.
#>
function Get-AzIotHubDailyMessageQuotaThreshold {
    param(
        [Parameter(Mandatory=$True)][string] $IotHubName = $(throw "Name of the Azure IoT Hub instance is required"),
        [Parameter(Mandatory=$True)][single] $QuotaPercentage = $(throw "Quota percentage is required"),
        [Parameter(Mandatory=$False)][string] $ResourceGroupName = ""
    )
    . $PSScriptRoot\Scripts\Get-AzIotHubDailyMessageQuotaThreshold.ps1 -IotHubName $IoTHubName -QuotaPercentage $QuotaPercentage -ResourceGroupName $ResourceGroupName
}

Export-ModuleMember -Function Get-AzIotHubDailyMessageQuotaThreshold