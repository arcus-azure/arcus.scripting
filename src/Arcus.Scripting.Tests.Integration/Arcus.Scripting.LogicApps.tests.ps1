
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.LogicApps -ErrorAction Stop

Describe "Arcus" {
    Context "LogicApps" {
        InModuleScope Arcus.Scripting.LogicApps {
            It "Enables a specific Logic App"{
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-http-trigger"
                Mock Write-Host {}
                Mock Invoke-WebRequest -MockWith {
                    return @{
                        Content = ""
                        StatusCode = "200"
                    }
                }
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Enable-AzLogicApp -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName

                # Assert
                Assert-VerifiableMocks
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Write-Host -Scope It -Exactly 1 -ParameterFilter { $Object -eq "Successfully enabled arc-dev-we-rcv-http-trigger" }
            }
            It "Fails to enable an unknown Azure Logic App" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $errorContent = "{""error"":{""code"":""ResourceNotFound"",""message"":""Unable to find the resource Microsoft.Logic/workflows/$logicAppName within resourcegroup codit-arcus-scripting.""}}"
                Mock Write-Warning -MockWith { } -ParameterFilter {$Message -like "Failed to enable $logicAppName"  }
                Mock Write-Warning -MockWith { } -ParameterFilter {$Message -like "Error: $errorContent"  }
                Mock Invoke-WebRequest -MockWith {
                    $status = [System.Net.WebExceptionStatus]::ConnectionClosed
                    $response = New-Object -type 'System.Net.HttpWebResponse'
                    $response | Add-Member -MemberType noteProperty -Name 'StatusCode' -Value 404 -force
                    $exception = New-Object System.Net.WebException $errorContent , $null, $status, $response
        
                    Throw $exception
                }
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Enable-AzLogicApp -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName


                # Assert
                Assert-VerifiableMocks
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Write-Warning -Scope It -Times 1 -ParameterFilter { $Message -eq "Failed to enable $logicAppName" }
                Assert-MockCalled Write-Warning -Scope It -Times 1 -ParameterFilter { $Message -eq "Error: $errorContent" }
            }
            It "Disables a specific Logic App"{
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-http-trigger"
                Mock Write-Host {}
                Mock Invoke-WebRequest -MockWith {
                    return @{
                        Content = ""
                        StatusCode = "200"
                    }
                }
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Disable-AzLogicApp -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName

                # Assert
                Assert-VerifiableMocks
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Write-Host -Scope It -Exactly 1 -ParameterFilter { $Object -eq "Successfully disabled arc-dev-we-rcv-http-trigger" }
            }
            It "Fails to disable an unknown Azure Logic App" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $errorContent = "{""error"":{""code"":""ResourceNotFound"",""message"":""Unable to find the resource Microsoft.Logic/workflows/$logicAppName within resourcegroup codit-arcus-scripting.""}}"
                Mock Write-Warning -MockWith { } -ParameterFilter {$Message -like "Failed to disable $logicAppName"  }
                Mock Write-Warning -MockWith { } -ParameterFilter {$Message -like "Error: $errorContent"  }
                Mock Invoke-WebRequest -MockWith {
                    $status = [System.Net.WebExceptionStatus]::ConnectionClosed
                    $response = New-Object -type 'System.Net.HttpWebResponse'
                    $response | Add-Member -MemberType noteProperty -Name 'StatusCode' -Value 404 -force
                    $exception = New-Object System.Net.WebException $errorContent , $null, $status, $response
        
                    Throw $exception
                }
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Disable-AzLogicApp -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName


                # Assert
                Assert-VerifiableMocks
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Write-Warning -Scope It -Times 1 -ParameterFilter { $Message -eq "Failed to disable $logicAppName" }
                Assert-MockCalled Write-Warning -Scope It -Times 1 -ParameterFilter { $Message -eq "Error: $errorContent" }
            }

            It "Doesn't disable anything when the checkType is not recognized" {
                # Arrange
                Mock Get-AzLogicAppRunHistory {}
                Mock Disable-AzLogicApp {}
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\deploy-orderControl-unknownCheckType.json" -ResourceGroup "ignored-resource-group"

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 0
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 0
            }
            It "Doesn't enable anything when the stopType is not recognized" {
                # Arrange
                Mock Get-AzLogicAppRunHistory {}
                Mock Enable-AzLogicApp {}
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Enable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\deploy-orderControl-unknownStopType.json" -ResourceGroupName "ignored-resource-group"

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 0
                Assert-MockCalled Enable-AzLogicApp -Scope It -Exactly 0
            }
            It "Doesn't disable anything when the stopType is not recognized" {
                # Arrange
                Mock Get-AzLogicAppRunHistory {}
                Mock Disable-AzLogicApp {}
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\deploy-orderControl-unknownStopType.json" -ResourceGroupName "ignored-resource-group"

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 0
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 0
            }
            It "Doesn't enable anything when both checkType & stopType is 'None'" {
                # Arrange
                Mock Get-AzLogicAppRunHistory {}
                Mock Enable-AzLogicApp {}
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Enable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\deploy-orderControl-none.json" -ResourceGroupName "ignored-resource-group"

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 0
                Assert-MockCalled Enable-AzLogicApp -Scope It -Exactly 0
            }
            It "Doesn't disable anything when both checkType & stopType is 'None'" {
                # Arrange
                Mock Get-AzLogicAppRunHistory {}
                Mock Disable-AzLogicApp {}
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\deploy-orderControl-none.json" -ResourceGroupName "ignored-resource-group"

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 0
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 0
            }
            It "Enable logic app when stopType = Immediate" {
                # Arrange
               $resourceGroupName = "my-resource-group"
                Mock Get-AzLogicAppRunHistory {}
                Mock Enable-AzLogicApp {}
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Enable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\deploy-orderControl-immediateWithoutCheck.json" -ResourceGroupName $resourceGroupName

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 0
                Assert-MockCalled Enable-AzLogicApp -Scope It -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroupName -and $LogicAppName -eq "snd-async" }
            }
            It "Disable logic app when stopType = Immediate" {
                # Arrange
               $resourceGroupName = "my-resource-group"
                Mock Get-AzLogicAppRunHistory {}
                Mock Disable-AzLogicApp {}
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\deploy-orderControl-immediateWithoutCheck.json" -ResourceGroupName $resourceGroupName

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 0
                Assert-MockCalled Disable-AzLogicApp -Scope It -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroupName -and $LogicAppName -eq "snd-async" }
            }
            It "Doesn't disable anything when checkType = NoWaitingOrRunningRuns but returns a zero count on the running runs for unknown stopType" {
                # Arrange
                $resourceGroupName = "my-resource-group"
                Mock Get-AzLogicAppRunHistory { 
                    return @([pscustomobject]@{ Status = "Waiting" })
                }
                Mock Disable-AzLogicApp {}
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\deploy-orderControl-noWaitingOrRunningRunsWithunknownStopType.json" -ResourceGroupName $resourceGroupName

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 6 -ParameterFilter { $ResourceGroupName -eq $resourceGroupName }
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 0
            }
            It "Doesn't disable anything when checkType = NoWaitingOrRunningRuns but returns a zero count on an the waiting runs for stopType = None" {
                # Arrange
                $resourceGroupName = "my-resource-group"
                Mock Get-AzLogicAppRunHistory {
                    return @([pscustomobject]{ Status = "Running" })
                }
                Mock Disable-AzLogicApp {}
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\deploy-orderControl-noWaitingOrRunningRunsWithNoneStopType.json" -ResourceGroupName $resourceGroupName

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Times 4 -ParameterFilter { $ResourceGroupName -eq $resourceGroupName }
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 0
            }
            It "Disbales all logic apps when checkType = NoWaitingOrRunningRuns with found waiting and no running runs for stopType = Immediate" {
                # Arrange
                $resourceGroupName = "my-resource-group"
                Mock Get-AzLogicAppRunHistory { return @([pscustomobject]@{ Status = "Waiting" }) }
                Mock Disable-AzLogicApp {}
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\deploy-orderControl-noWaitingOrRunningRunsWithImmediate.json" -ResourceGroupName $resourceGroupName

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 10 -ParameterFilter { $ResourceGroupName -eq $resourceGroupName }
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 5 -ParameterFilter {$resourceGroupName -eq $resourceGroupName}
            }
            It "Disables all logic apps when checkType = NoWaitingOrRunningRuns with found waiting and running runs for stopType = Immediate" {
                # Arrange
                $resourceGroupName = "my-resource-group"
                $i = 0
                Mock Get-AzLogicAppRunHistory {
                    $script:i++
                    if ($script:i -gt 2) {
                        Write-Host "Returning empty (no running, no waiting) runs"
                        return @()
                    } else {
                        Write-Host "Returning 1 running & 1 waiting runs"
                        return @(
                            [pscustomobject]@{ Status = "Running" },
                            [pscustomobject]@{ Status = "Waiting" }
                        )
                    }
                }
                Mock Disable-AzLogicApp {}
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\deploy-orderControl-noWaitingOrRunningRunsWithSingleImmediate.json" -ResourceGroupName $resourceGroupName

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 4 -ParameterFilter { $ResourceGroupName -eq $resourceGroupName }
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 1 -ParameterFilter {$resourceGroupName -eq $resourceGroupName}
            }
        }
    }
}