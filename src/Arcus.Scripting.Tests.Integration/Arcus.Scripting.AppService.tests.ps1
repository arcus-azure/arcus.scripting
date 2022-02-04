Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.AppService -ErrorAction Stop

InModuleScope Arcus.Scripting.AppService {
    Describe "Arcus Azure App Service integration tests" {
        BeforeEach {
            $filePath = "$PSScriptRoot\appsettings.json"
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1 -fileName "appsettings.json"
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
        }
        Context "Setting an Azure App Service application setting" {
            It "Try to set an application setting to unexisting App Service fails" {
                # Arrange
                $ResourceGroupName = $config.Arcus.ResourceGroupName
                $AppServiceName = "unexisting-appservice"
                $AppServiceSettingName = "somesetting"
                $AppServiceSettingValue = "somevalue"

                # Act
                { Set-AzAppServiceSetting -ResourceGroupName $ResourceGroupName -AppServiceName $AppServiceName -AppServiceSettingName $AppServiceSettingName -AppServiceSettingValue $AppServiceSettingValue -ErrorAction Stop } | 
                    Should -Throw
            }
            It "Setting an application setting succeeds" {
                # Arrange
                $ResourceGroupName = $config.Arcus.ResourceGroupName
                $AppServiceName = $config.Arcus.AppService.Name
                $AppServiceSettingName = "testsetting"
                $AppServiceSettingValue = [guid]::NewGuid()

                # Act
                Set-AzAppServiceSetting -ResourceGroupName $ResourceGroupName -AppServiceName $AppServiceName -AppServiceSettingName $AppServiceSettingName -AppServiceSettingValue $AppServiceSettingValue

                # Assert
                $actual = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $AppServiceName
                $actual | Should -Not -BeNullOrEmpty 

                $settings = @{ }
                foreach ($setting in $actual.SiteConfig.AppSettings) {
                    $settings[$setting.Name] = $setting.value
                }               
                $settings[$AppServiceSettingName] | Should -BeExactly $AppServiceSettingValue
            }
        }
    }
}