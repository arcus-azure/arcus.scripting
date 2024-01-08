Import-Module Az.IotHub
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.IotHub -ErrorAction Stop

InModuleScope Arcus.Scripting.IotHub {
    Describe "Arcus Azure IoT Hub integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1 
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
        }
        Context "Get daily IoT Hub quota threshold" {
            It "Get daily IoT Hub quota threshold gets quota percentage" {
                # Act
                $result = Get-AzIotHubDailyMessageQuotaThreshold `
                    -IoTHubName $config.Arcus.IotHub.Name `
                    -ResourceGroupName $config.Arcus.ResourceGroupName `
                    -QuotaPercentage 0.1

                # Assert
                $result | Should -Be 0
            }
        }
    }
}