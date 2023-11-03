Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Security -ErrorAction Stop
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.LogicApps -ErrorAction Stop

InModuleScope Arcus.Scripting.LogicApps {
    Describe "Arcus Azure Logic Apps Consumption unit tests" {
        Context "Enable Logic Apps without configuration" {
             It "Fails to enable an unknown Azure Logic App" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $errorContent = "{""error"":{""code"":""ResourceNotFound"",""message"":""Unable to find the resource Microsoft.Logic/workflows/$logicAppName within resourcegroup codit-arcus-scripting.""}}"
                Mock Write-Warning -MockWith { }
                Mock Write-Debug -MockWith { } -ParameterFilter {$Message -like "Error: $errorContent"  }
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
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Write-Warning -Scope It -Times 1 -ParameterFilter { $Message -contains "Failed to enable Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'" }
                Assert-MockCalled Write-Debug -Scope It -Times 1 -ParameterFilter { $Message -eq "Error: $errorContent" }
            }
        }
        Context "Enable Logic Apps with configuration" {
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
                Enable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\LogicApps\deploy-orderControl-unknownStopType.json" -ResourceGroupName "ignored-resource-group"

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 0
                Assert-MockCalled Enable-AzLogicApp -Scope It -Exactly 0
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
                Enable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\LogicApps\deploy-orderControl-none.json" -ResourceGroupName "ignored-resource-group"

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 0
                Assert-MockCalled Enable-AzLogicApp -Scope It -Exactly 0
            }
        }
        Context "Disable Logic Apps without configuration" {
            It "Fails to disable an unknown Azure Logic App" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $errorContent = "{""error"":{""code"":""ResourceNotFound"",""message"":""Unable to find the resource Microsoft.Logic/workflows/$logicAppName within resourcegroup codit-arcus-scripting.""}}"
                Mock Write-Warning -MockWith { }
                Mock Write-Debug -MockWith { } -ParameterFilter {$Message -like "Error: $errorContent"  }
                Mock Invoke-WebRequest -MockWith {
                    $status = [System.Net.WebExceptionStatus]::ConnectionClosed
                    $response = New-Object -type 'System.Net.HttpWebResponse'
                    $response | Add-Member -MemberType noteProperty -Name 'StatusCode' -Value 404 -force
                    $exception = New-Object System.Net.WebException $errorContent , $null, $status, $response
        
                    throw $exception
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
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Write-Warning -Scope It -Times 1 -ParameterFilter { $Message -eq "Failed to disable Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'" }
                Assert-MockCalled Write-Debug -Scope It -Times 1 -ParameterFilter { $Message -eq "Error: $errorContent" }
            }
        }
        Context "Disable Logic Apps with configuration" {
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
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\LogicApps\deploy-orderControl-unknownCheckType.json" -ResourceGroup "ignored-resource-group"

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 0
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 0
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
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\LogicApps\deploy-orderControl-unknownStopType.json" -ResourceGroupName "ignored-resource-group"

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 0
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 0
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
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\LogicApps\deploy-orderControl-none.json" -ResourceGroupName "ignored-resource-group"

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 0
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 0
            }
            It "Doesn't disable anything when checkType = NoWaitingOrRunningRuns but returns a zero count on the running runs for unknown stopType" {
                # Arrange
                $script:i = 0
                $resourceGroup = "my-resource-group"
                $logicAppNames = @("snd-async", "ord-sthp-harvest-order-doublechecker", "ord-sthp-harvest-order-doublechecker")
                Mock Get-AzLogicAppRunHistory {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be "snd-async"
                    $script:i++
                    if ($script:i -gt 2) {
                        Write-Host "Returning empty (no running, no waiting) runs"
                        return @()
                    } else {
                        Write-Host "Returning 1 running run"
                        return @(
                            [pscustomobject]@{ Status = "Running" }
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
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\LogicApps\deploy-orderControl-noWaitingOrRunningRunsWithunknownStopType.json" -ResourceGroupName $resourceGroup

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 3 -ParameterFilter { $ResourceGroupName -eq $resourceGroup }
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 0
            }
            It "Doesn't disable anything when checkType = NoWaitingOrRunningRuns but returns a zero count on an the waiting runs for stopType = None" {
                # Arrange
                $script:i = 0
                $resourceGroup = "my-resource-group"
                $logicAppNames = @("snd-async", "ord-sthp-harvest-order-doublechecker")
                Mock Get-AzLogicAppRunHistory {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be "snd-async"
                    $script:i++
                    if ($script:i -gt 2) {
                        Write-Host "Returning empty (no running, no waiting) runs"
                        return @()
                    } else {
                        Write-Host "Returning 1 waiting run"
                        return @(
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
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\LogicApps\deploy-orderControl-noWaitingOrRunningRunsWithNoneStopType.json" -ResourceGroupName $resourceGroup

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Times 2 -ParameterFilter { $ResourceGroupName -eq $resourceGroup }
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 0
            }
            It "Disables all logic apps when checkType = NoWaitingOrRunningRuns with found waiting and no running runs for stopType = Immediate" {
                # Arrange
                $script:i = 0
                $resourceGroup = "my-resource-group"
                $logicAppNames = @("snd-async", "ord-sthp-harvest-order-doublechecker", "rcv-sthp-harvest-order-af-ftp", "rcv-sthp-harvest-order-af-sft", "rcv-sthp-harvest-order-af-file")
                Mock Get-AzLogicAppRunHistory {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -BeIn $logicAppNames
                    $script:i++
                    if ($script:i -gt 2) {
                        Write-Host "Returning empty (no running, no waiting) runs"
                        return @()
                    } else {
                        Write-Host "Returning 1 waiting run"
                        return @(
                            [pscustomobject]@{ Status = "Waiting" }
                        )
                    }
                }
                Mock Disable-AzLogicApp {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $LogicAppName | Should -BeIn $logicAppNames
                }
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\LogicApps\deploy-orderControl-noWaitingOrRunningRunsWithImmediate.json" -ResourceGroupName $resourceGroup

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 5 -ParameterFilter { $ResourceGroupName -eq $resourceGroup }
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 5 -ParameterFilter { $resourceGroupName -eq $resourceGroup }
            }
            It "Disables all logic apps when checkType = NoWaitingOrRunningRuns with found waiting and running runs for stopType = Immediate" {
                # Arrange
                $resourceGroup = "my-resource-group"
                $script:i = 0
                Mock Get-AzLogicAppRunHistory {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be "snd-async"
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
                Mock Disable-AzLogicApp {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $LogicAppName | Should -Be "snd-async"
                }
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\LogicApps\deploy-orderControl-noWaitingOrRunningRunsWithSingleImmediate.json" -ResourceGroupName $resourceGroup

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $LogicAppName -eq "snd-async" }
            }
            It "Disables all logic apps with option maximumFollowNextPageLink set to 25" {
                # Arrange
                $resourceGroup = "my-resource-group"
                Mock Get-AzLogicAppRunHistory {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be "snd-async"
                    $MaximumFollowNextPageLink | Should -Be 25
                    Write-Host "Returning empty (no running, no waiting) runs"
                    return @()
                }
                Mock Disable-AzLogicApp {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $LogicAppName | Should -Be "snd-async"
                }
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\LogicApps\deploy-orderControl-maximumFollowNextPageLink.json" -ResourceGroupName $resourceGroup

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $LogicAppName -eq "snd-async" }
            }
            It "Disables all logic apps with option maximumFollowNextPageLink defaults to 10" {
                # Arrange
                $resourceGroup = "my-resource-group"
                Mock Get-AzLogicAppRunHistory {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be "snd-async"
                    $MaximumFollowNextPageLink | Should -Be 10
                    Write-Host "Returning empty (no running, no waiting) runs"
                    return @()
                }
                Mock Disable-AzLogicApp {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $LogicAppName | Should -Be "snd-async"
                }
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                # Act
                Disable-AzLogicAppsFromConfig -DeployFileName "$PSScriptRoot\Files\LogicApps\deploy-orderControl-noMaximumFollowNextPageLink.json" -ResourceGroupName $resourceGroup

                # Assert
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Disable-AzLogicApp -Scope It -Exactly 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $LogicAppName -eq "snd-async" }
            }
        }
        Context "Cancel Logic Apps runs" {
            It "Cancelling all runs from Logic App history should succeed" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"

                Mock Get-AzLogicAppRunHistory -MockWith {
                    return @{
                        Name = "test"
                        Status = "Running"
                    }
                }

                Mock Stop-AzLogicAppRun -MockWith {
                   return $null
                }

                # Act
                { Cancel-AzLogicAppRuns -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName } | 
                    Should -Not -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 1
                Assert-MockCalled Stop-AzLogicAppRun -Scope It -Times 1
            }
            It "Cancelling all runs should fail when retrieving Logic App history fails" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"

                Mock Get-AzLogicAppRunHistory { throw 'some error' }

                Mock Stop-AzLogicAppRun -MockWith {
                   return $null
                }

                # Act
                { Cancel-AzLogicAppRuns -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName } | 
                    Should -Throw -ExpectedMessage "Failed to cancel all running instances for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'. Details: some error"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 1
                Assert-MockCalled Stop-AzLogicAppRun -Scope It -Times 0
            }
            It "Cancelling all runs from Logic App history with option maximumFollowNextPageLink set to 25" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"

                Mock Get-AzLogicAppRunHistory -MockWith {
                    $MaximumFollowNextPageLink | Should -Be 25
                    return @{
                        Name = "test"
                        Status = "Running"
                    }
                }

                Mock Stop-AzLogicAppRun -MockWith {
                   return $null
                }

                # Act
                { Cancel-AzLogicAppRuns -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName -MaximumFollowNextPageLink 25 } | 
                    Should -Not -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 1
                Assert-MockCalled Stop-AzLogicAppRun -Scope It -Times 1
            }
            It "Cancelling all runs from Logic App history with option maximumFollowNextPageLink defaults to 10" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"

                Mock Get-AzLogicAppRunHistory -MockWith {
                    $MaximumFollowNextPageLink | Should -Be 10
                    return @{
                        Name = "test"
                        Status = "Running"
                    }
                }

                Mock Stop-AzLogicAppRun -MockWith {
                   return $null
                }

                # Act
                { Cancel-AzLogicAppRuns -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName } | 
                    Should -Not -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 1
                Assert-MockCalled Stop-AzLogicAppRun -Scope It -Times 1
            }
        }
        Context "Resubmitting failed Logic Apps runs" {
            It "Resubmitting a single failed run from Logic App history should succeed" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $startTime = '2023-01-01 00:00:00'

                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                Mock Get-AzLogicAppRunHistory -MockWith {
                    return @{
                        Name = "test"
                        Status = "Failed"
                        StartTime = "2023-01-01 01:00:00"
                    }
                }

                Mock Invoke-WebRequest -MockWith {
                   return $null
                }

                # Act
                { Resubmit-FailedAzLogicAppRuns -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName -StartTime $startTime } | 
                    Should -Not -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 1
                Assert-MockCalled Invoke-WebRequest -Scope It -Times 1
             }
            It "Resubmitting a single failed run from Logic App history with specifying an EndTime should succeed" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $startTime = '2023-01-01 00:00:00'
                $endTime = '2023-02-01 00:00:00'

                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                Mock Get-AzLogicAppRunHistory -MockWith {
                    return @{
                        Name = "test"
                        Status = "Failed"
                        StartTime = "2023-01-01 01:00:00"
                    }
                }

                Mock Invoke-WebRequest -MockWith {
                   return $null
                }

                # Act
                { Resubmit-FailedAzLogicAppRuns -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName -StartTime $startTime -EndTime $endTime } | 
                    Should -Not -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 1
                Assert-MockCalled Invoke-WebRequest -Scope It -Times 1
             }
            It "Resubmitting multiple failed runs from Logic App history should succeed" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $startTime = '2023-01-01 00:00:00'

                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }


                $logicAppRunHistory = @([pscustomobject]@{Name="Test1";Status="Failed";StartTime="2023-01-01 01:00:00"},
                                      [pscustomobject]@{Name="Test2";Status="Failed";StartTime="2023-01-01 01:00:00"})

                Mock Get-AzLogicAppRunHistory -MockWith {
                    return $logicAppRunHistory
                }

                Mock Invoke-WebRequest -MockWith {
                   return $null
                }

                # Act
                { Resubmit-FailedAzLogicAppRuns -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName -StartTime $startTime } | 
                    Should -Not -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 1
                Assert-MockCalled Invoke-WebRequest -Scope It -Times 2
             }
            It "Resubmitting multiple failed runs from Logic App history with specifying an EndTime should succeed" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $startTime = '2023-01-01 00:00:00'
                $endTime = '2023-02-01 00:00:00'

                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }


                $logicAppRunHistory = @([pscustomobject]@{Name="Test1";Status="Failed";StartTime="2023-01-01 01:00:00"},
                                      [pscustomobject]@{Name="Test2";Status="Failed";StartTime="2023-01-01 01:00:00"})

                Mock Get-AzLogicAppRunHistory -MockWith {
                    return $logicAppRunHistory
                }

                Mock Invoke-WebRequest -MockWith {
                   return $null
                }

                # Act
                { Resubmit-FailedAzLogicAppRuns -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName -StartTime $startTime -EndTime $endTime } | 
                    Should -Not -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 1
                Assert-MockCalled Invoke-WebRequest -Scope It -Times 2
             }
            It "Resubmitting failed runs should fail when retrieving Logic App history fails" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $startTime = '01/01/2023 00:00:00'

                Mock Get-AzLogicAppRunHistory { throw 'some error' }

                Mock Invoke-WebRequest -MockWith {
                   return $null
                }

                # Act
                { Resubmit-FailedAzLogicAppRuns -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName -StartTime $startTime } | 
                    Should -Throw -ExpectedMessage "Failed to resubmit all failed instances for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName' from '$startTime'. Details: some error"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 1
                Assert-MockCalled Invoke-WebRequest -Scope It -Times 0
            }
            It "Resubmitting runs from Logic App history with option maximumFollowNextPageLink set to 25" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $startTime = '2023-01-01 00:00:00'

                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                Mock Get-AzLogicAppRunHistory -MockWith {
                    $MaximumFollowNextPageLink | Should -Be 25
                    return @{
                        Name = "test"
                        Status = "Failed"
                        StartTime = "2023-01-01 01:00:00"
                    }
                }

                Mock Invoke-WebRequest -MockWith {
                   return $null
                }

                # Act
                { Resubmit-FailedAzLogicAppRuns -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName -StartTime $startTime -MaximumFollowNextPageLink 25 } | 
                    Should -Not -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 1
                Assert-MockCalled Invoke-WebRequest -Scope It -Times 1
             }
            It "Resubmitting runs from Logic App history with option maximumFollowNextPageLink defaults to 10" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $startTime = '2023-01-01 00:00:00'

                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                Mock Get-AzLogicAppRunHistory -MockWith {
                    $MaximumFollowNextPageLink | Should -Be 10
                    return @{
                        Name = "test"
                        Status = "Failed"
                        StartTime = "2023-01-01 01:00:00"
                    }
                }

                Mock Invoke-WebRequest -MockWith {
                   return $null
                }

                # Act
                { Resubmit-FailedAzLogicAppRuns -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName -StartTime $startTime } | 
                    Should -Not -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Get-AzLogicAppRunHistory -Scope It -Times 1
                Assert-MockCalled Invoke-WebRequest -Scope It -Times 1
             }
        }
    }
    Describe "Arcus Azure Logic Apps Standard unit tests" {
        Context "Enable Logic Apps without configuration" {
             It "Fails to enable an unknown Azure Logic App" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $workflowName = "test"
                Mock Write-Warning -MockWith { }
                Mock Set-AzAppServiceSetting {
                    Throw 'Not found error'
                } 

                # Act
                Enable-AzLogicApp -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName -WorkflowName $workflowName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Set-AzAppServiceSetting -Times 1
                Assert-MockCalled Write-Warning -Scope It -Times 1 -ParameterFilter { $Message -contains "Failed to enable workflow '$workflowName' in Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'" }
            }
            It "Enabling an Azure Logic App should succeed" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $workflowName = "test"
                Mock Write-Host -MockWith { }
                Mock Set-AzAppServiceSetting { } 

                # Act
                Enable-AzLogicApp -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName -WorkflowName $workflowName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Set-AzAppServiceSetting -Times 1
                Assert-MockCalled Write-Host -Scope It -Times 1 -ParameterFilter { $Message -contains "Successfully enabled workflow '$workflowName' in Azure Logic App '$logicAppName' in resource group '$resourceGroupName'" }
            }
        }
        Context "Disable Logic Apps without configuration" {
             It "Fails to disable an unknown Azure Logic App" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $workflowName = "test"
                Mock Write-Warning -MockWith { }
                Mock Set-AzAppServiceSetting {
                    Throw 'Not found error'
                } 

                # Act
                Disable-AzLogicApp -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName -WorkflowName $workflowName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Set-AzAppServiceSetting -Times 1
                Assert-MockCalled Write-Warning -Scope It -Times 1 -ParameterFilter { $Message -contains "Failed to disable workflow '$workflowName' in Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'" }
            }
            It "Disabling an Azure Logic App should succeed" {
                # Arrange
                $resourceGroupName = "codit-arcus-scripting"
                $logicAppName = "arc-dev-we-rcv-unknown-http"
                $workflowName = "test"
                Mock Write-Host -MockWith { }
                Mock Set-AzAppServiceSetting { } 

                # Act
                Disable-AzLogicApp -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName -WorkflowName $workflowName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Set-AzAppServiceSetting -Times 1
                Assert-MockCalled Write-Host -Scope It -Times 1 -ParameterFilter { $Message -contains "Successfully disabled workflow '$workflowName' in Azure Logic App '$logicAppName' in resource group '$resourceGroupName'" }
            }
        }
    }
}