Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Security -ErrorAction Stop
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.LogicApps -ErrorAction Stop

function global:Create-AzLogicAppName () {
    $id = [Guid]::NewGuid()
    return "arcus-test-$($id)"
}

InModuleScope Arcus.Scripting.LogicApps {
    Describe "Arcus Azure Logic Apps integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config

            $oldLogicAppName = "arc-dev-we-rcv-http-trigger"
            $workflowDefinition = '{
              "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
              "actions": {},
              "outputs": {},
              "parameters": {},
              "triggers": {
                "manual": {
                  "inputs": {
                    "schema": {}
                  },
                  "kind": "Http",
                  "type": "Request"
                }
              },
              "contentVersion": "1.0.0.0"
            }'
        }
        Context "Enabling Logic Apps without configuration" {
            It "Enables a specific Logic App" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $logicAppName = Create-AzLogicAppName

                New-AzLogicApp `
                    -ResourceGroupName $resourceGroupName `
                    -Location westeurope `
                    -Name $logicAppName `
                    -Definition $workflowDefinition `
                    -State Disabled

                try {
                    # Act
                    Enable-AzLogicApp -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName

                    # Assert
                    $logicApp = Get-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName
                    $logicApp | Should -Not -Be $null
                    $logicApp.State | Should -Be "Enabled"
                } finally {
                    Remove-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName -Force
                }
            }
        }
        Context "Disabling Logic Apps without configuration" {
            It "Disables a specific Logic App" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $logicAppName = Create-AzLogicAppName

                New-AzLogicApp `
                    -ResourceGroupName $resourceGroupName `
                    -Location westeurope `
                    -Name $logicAppName `
                    -Definition $workflowDefinition `
                    -State Enabled

                try {
                    # Act
                    Disable-AzLogicApp -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName

                    # Assert
                    $logicApp = Get-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName
                    $logicApp | Should -Not -Be $null
                    $logicApp.State | Should -Be "Disabled"
                } finally {
                    Remove-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName -Force
                }
            }
        }
        Context "Disabling Logic Apps with configuration" {
            It "Disable logic app when stopType = Immediate" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $logicAppName = Create-AzLogicAppName

                $filePath = [System.IO.Path]::GetTempFileName()
                $json = '[
                  {
                    "description": "Sender(s)",
                    "checkType": "None",
                    "stopType": "Immediate",
                    "logicApps": [
                      "' + $logicAppName + '"
                    ]
                  }
                ]'
                Set-Content $filePath $json
               
                New-AzLogicApp `
                    -ResourceGroupName $resourceGroupName `
                    -Location westeurope `
                    -Name $logicAppName `
                    -Definition $workflowDefinition `
                    -State Enabled

                try {
                    # Act
                    Disable-AzLogicAppsFromConfig -DeployFileName $filePath -ResourceGroupName $resourceGroupName

                    # Assert
                    $logicApp = Get-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName
                    $logicApp | Should -Not -Be $null
                    $logicApp.State | Should -Be "Disabled"
                } finally {
                    Remove-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName -Force
                    Remove-Item $filePath -Force

                }
            }
        }
        Context "Enabling Logic Apps with configuration" {
            It "Enable logic app when stopType = Immediate" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $logicAppName = Create-AzLogicAppName
               
                $filePath = [System.IO.Path]::GetTempFileName()
                $json = '[
                  {
                    "description": "Sender(s)",
                    "checkType": "None",
                    "stopType": "Immediate",
                    "logicApps": [
                      "' + $logicAppName + '"
                    ]
                  }
                ]'
                Set-Content $filePath $json

                New-AzLogicApp `
                    -ResourceGroupName $resourceGroupName `
                    -Location westeurope `
                    -Name $logicAppName `
                    -Definition $workflowDefinition `
                    -State Disabled

                try {
                    # Act
                    Enable-AzLogicAppsFromConfig -DeployFileName $filePath -ResourceGroupName $resourceGroupName

                    # Assert
                    $logicApp = Get-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName
                    $logicApp | Should -Not -Be $null
                    $logicApp.State | Should -Be "Enabled"
                } finally {
                    Remove-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName -Force
                    Remove-Item $filePath -Force
                }
            }
        }
        Context "Cancel Logic Apps runs" {
            It "Cancel all running instances for a Logic App" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $logicAppName = Create-AzLogicAppName
                $workflowDefinition = '{
                    "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
                    "actions": {
                        "Delay": {
                            "inputs": {
                                "interval": {
                                    "count": 5,
                                    "unit": "Minute"
                                }
                            },
                            "runAfter": {},
                            "type": "wait"
                        }
                    },
                    "outputs": {},
                    "parameters": {},
                    "triggers": {
                        "Recurrence": {
                            "recurrence": {
                                "frequency": "Second",
                                "interval": 1
                            },
                            "type": "recurrence"
                        }
                    },
                    "contentVersion": "1.0.0.0"
                }'

                New-AzLogicApp `
                    -ResourceGroupName $resourceGroupName `
                    -Location westeurope `
                    -Name $logicAppName `
                    -Definition $workflowDefinition `
                    -State Enabled

                Start-Sleep -Seconds 5

                try {
                    Set-AzLogicApp `
                        -ResourceGroupName $resourceGroupName `
                        -Name $logicAppName `
                        -State Disabled `
                        -Force

                    # Act
                    Cancel-AzLogicAppRuns -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName

                    # Assert
                    $runs = Get-AzLogicAppRunHistory -ResourceGroupName $resourceGroupName -Name $logicAppName | 
                    Where-Object { $_.Status -eq 'Cancelled' } | Measure-Object

                    $runs.Count | Should -BeGreaterThan 0

                } finally {
                    Remove-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName -Force
                }
            }
        }
        Context "Resubmit Failed Logic Apps runs" {
            It "Resubmit all failed instances for a Logic App" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $logicAppName = Create-AzLogicAppName
                $workflowDefinition = '{
                    "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
                    "actions": {
                        "Terminate": {
                            "inputs": {
                                "runStatus": "Failed"
                            },
                            "runAfter": {},
                            "type": "Terminate"
                        }
                    },
                    "outputs": {},
                    "parameters": {},
                    "triggers": {
                        "Recurrence": {
                            "recurrence": {
                                "frequency": "Minute",
                                "interval": 1
                            },
                            "type": "recurrence"
                        }
                    },
                    "contentVersion": "1.0.0.0"
                }'

                $startTime = [datetime]::Now.ToUniversalTime()

                New-AzLogicApp `
                    -ResourceGroupName $resourceGroupName `
                    -Location westeurope `
                    -Name $logicAppName `
                    -Definition $workflowDefinition `
                    -State Enabled

                Start-Sleep -Seconds 5

                try {
                    # Act                    
                    Resubmit-FailedAzLogicAppRuns -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName -StartTime $startTime

                    # Assert
                    $runs = Get-AzLogicAppRunHistory -ResourceGroupName $resourceGroupName -Name $logicAppName | 
                    Where-Object { $_.StartTime -ge $startTime } | Measure-Object

                    $runs.Count | Should -BeGreaterThan 0

                } finally {
                    Remove-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName -Force
                }
            }
            It "Resubmit all failed instances for a Logic App with specifying an EndTime" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $logicAppName = Create-AzLogicAppName
                $workflowDefinition = '{
                    "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
                    "actions": {
                        "Terminate": {
                            "inputs": {
                                "runStatus": "Failed"
                            },
                            "runAfter": {},
                            "type": "Terminate"
                        }
                    },
                    "outputs": {},
                    "parameters": {},
                    "triggers": {
                        "Recurrence": {
                            "recurrence": {
                                "frequency": "Minute",
                                "interval": 1
                            },
                            "type": "recurrence"
                        }
                    },
                    "contentVersion": "1.0.0.0"
                }'

                $startTime = [datetime]::Now.ToUniversalTime()
                $endTime = [datetime]::Now.AddDays(1).ToUniversalTime()

                New-AzLogicApp `
                    -ResourceGroupName $resourceGroupName `
                    -Location westeurope `
                    -Name $logicAppName `
                    -Definition $workflowDefinition `
                    -State Enabled

                Start-Sleep -Seconds 5

                try {
                    # Act                    
                    Resubmit-FailedAzLogicAppRuns -ResourceGroupName $resourceGroupName -LogicAppName $logicAppName -StartTime $startTime -EndTime $endTime

                    # Assert
                    $runs = Get-AzLogicAppRunHistory -ResourceGroupName $resourceGroupName -Name $logicAppName | 
                    Where-Object { $_.StartTime -ge $startTime } | Measure-Object

                    $runs.Count | Should -BeGreaterThan 0

                } finally {
                    Remove-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName -Force
                }
            }
        }
    }
}