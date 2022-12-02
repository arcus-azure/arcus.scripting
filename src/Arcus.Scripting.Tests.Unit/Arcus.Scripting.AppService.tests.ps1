Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.AppService -ErrorAction Stop

InModuleScope Arcus.Scripting.AppService {
    Describe "Arcus Azure App Service unit tests" {
        Context "Setting an Azure App Service application setting" {
            It "Providing an App Service Name that does not exist should fail" {
                # Arrange
                $ResourceGroupName = "rg-infrastructure"
                $AppServiceName = "unexisting-appservice"
                $AppServiceSettingName = "somesetting"
                $AppServiceSettingValue = "somevalue"

                Mock Get-AzWebApp {
                    return $null
                } 

                # Act
                { 
                   Set-AzAppServiceSetting -ResourceGroupName $ResourceGroupName -AppServiceName $AppServiceName -AppServiceSettingName $AppServiceSettingName -AppServiceSettingValue $AppServiceSettingValue
                } | Should -Throw -ExpectedMessage "No app service with name '$AppServiceName' could be found in the resource group '$ResourceGroupName'"

                # Assert
                Assert-VerifiableMock
            }
            It "Creating a new application setting and setting its value succeeds" {
                # Arrange
                $SubscriptionId = [guid]::NewGuid()
                $ResourceGroupName = "rg-infrastructure"
                $AppServiceName = "unexisting-appservice"
                $AppServiceResourceId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$AppServiceName"
                $AppServiceSettingName = "newsetting"
                $AppServiceSettingValue = "newvalue"

                Mock Get-AzWebApp {
                    return [pscustomobject]@{ Id = $AppServiceResourceId; Name = $AppServiceName; Type = 'Microsoft.Web/sites'; Location = 'West Europe'; }
                } -Verifiable

                Mock Set-AzWebApp {
                    return [pscustomobject] @{
                        Id = $AppServiceResourceId;
                        Name = $AppServiceName;
                        Type = 'Microsoft.Web/sites';
                        Location = 'West Europe';
                        SiteConfig = [pscustomobject] @{
                            AppSettings = [pscustomobject] @{
                                Name = "somesetting";
                                Value = "somevalue";
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                # Act
                { Set-AzAppServiceSetting -ResourceGroupName $ResourceGroupName -AppServiceName $AppServiceName -AppServiceSettingName $AppServiceSettingName -AppServiceSettingValue $AppServiceSettingValue } | 
                    Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzWebApp -Times 1
                Assert-MockCalled Set-AzWebApp -Times 1
            }
            It "Updating an existing application setting and setting its value succeeds" {
                # Arrange
                $SubscriptionId = [guid]::NewGuid()
                $ResourceGroupName = "rg-infrastructure"
                $AppServiceName = "unexisting-appservice"
                $AppServiceResourceId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$AppServiceName"
                $AppServiceSettingName = "existingsetting"
                $AppServiceSettingValue = "newvalue"

                 Mock Get-AzWebApp {
                    return [pscustomobject] @{
                        Id = $AppServiceResourceId;
                        Name = $AppServiceName;
                        Type = 'Microsoft.Web/sites';
                        Location = 'West Europe';
                        SiteConfig = [pscustomobject] @{
                            AppSettings = [pscustomobject] @{
                                Name = "existingsetting";
                                Value = "oldvalue";
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Set-AzWebApp {
                    return [pscustomobject] @{
                        Id = $AppServiceResourceId;
                        Name = $AppServiceName;
                        Type = 'Microsoft.Web/sites';
                        Location = 'West Europe';
                        SiteConfig = [pscustomobject] @{
                            AppSettings = [pscustomobject] @{
                                Name = "existingsetting";
                                Value = "newvalue";
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                # Act
                { Set-AzAppServiceSetting -ResourceGroupName $ResourceGroupName -AppServiceName $AppServiceName -AppServiceSettingName $AppServiceSettingName -AppServiceSettingValue $AppServiceSettingValue } | 
                    Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzWebApp -Times 1
                Assert-MockCalled Set-AzWebApp -Times 1
            }
        }
    }
}