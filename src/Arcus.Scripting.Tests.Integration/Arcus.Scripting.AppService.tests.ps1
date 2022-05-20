Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.AppService -ErrorAction Stop

InModuleScope Arcus.Scripting.AppService {
    Describe "Arcus Azure App Service integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1
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
            It "Creating a new application setting and setting its value succeeds" {
                # Arrange
                $ResourceGroupName = $config.Arcus.ResourceGroupName
                $AppServiceName = $config.Arcus.AppService.Name
                $AppServiceSettingName = "setting-$([System.Guid]::NewGuid())"
                $AppServiceSettingValue = [guid]::NewGuid()

                try {
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
                } finally {
                    $appService = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $AppServiceName
                    $appServiceSettings = $appService.SiteConfig.AppSettings

                    $settingsWithoutTestSetting = @{ }
                    foreach ($setting in $appServiceSettings) {
                        if ($setting.Name -ne $AppServiceSettingName) {
                            $settingsWithoutTestSetting[$setting.Name] = $setting.value
                        }
                    }

                    Set-AzWebApp -ResourceGroupName $ResourceGroupName -Name $appServiceName -AppSettings $settingsWithoutTestSetting
                }
            }
            It "Update an existing application setting and setting its value succeeds" {
                # Arrange
                $ResourceGroupName = $config.Arcus.ResourceGroupName
                $AppServiceName = $config.Arcus.AppService.Name
                $AppServiceSettingName = "existing-setting"
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