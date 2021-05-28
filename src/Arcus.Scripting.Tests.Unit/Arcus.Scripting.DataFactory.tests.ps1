Describe "Arcus" {
    InModuleScope Arcus.Scripting.DataFactory {
        Context "DataFactory" {
            It "Enable Data Factory trigger" {
                # Arrange
                $resourceGroup = "my resource group"
                $dataFactoryName = "my data factory"
                $dataFactoryTriggerName = "my data factory trigger"

                Mock Get-AzDataFactoryV2 { }
                Mock Get-AzDataFactoryV2Trigger { return [pscustomobject]@{ } }
                Mock Start-AzDataFactoryV2Trigger { return $true }
                Mock Stop-AzDataFactoryV2Trigger { return $true }

                # Act
                Enable-AzDataFactoryTrigger -ResourceGroupName $resourceGroup -DataFactoryName $dataFactoryName -DataFactoryTriggerName $dataFactoryTriggerName

                # Assert
                Assert-MockCalled Start-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
                Assert-MockCalled Stop-AzDataFactoryV2Trigger -Times 0
                Assert-MockCalled Get-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
                Assert-MockCalled Get-AzDataFactoryV2 -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $Name -eq $dataFactoryName }
            }
            It "Disable Data Factory trigger" {
                # Arrange
                $resourceGroup = "my resource group"
                $dataFactoryName = "my data factory"
                $dataFactoryTriggerName = "my data factory trigger"

                Mock Get-AzDataFactoryV2 { }
                Mock Get-AzDataFactoryV2Trigger { return [pscustomobject]@{ } }
                Mock Start-AzDataFactoryV2Trigger { return $true }
                Mock Stop-AzDataFactoryV2Trigger { return $true }

                # Act
                Disable-AzDataFactoryTrigger -ResourceGroupName $resourceGroup -DataFactoryName $dataFactoryName -DataFactoryTriggerName $dataFactoryTriggerName

                # Assert
                Assert-MockCalled Start-AzDataFactoryV2Trigger -Times 0
                Assert-MockCalled Stop-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
                Assert-MockCalled Get-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
                Assert-MockCalled Get-AzDataFactoryV2 -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $Name -eq $dataFactoryName }
            }
            It "Skips actions when trigger was not found and 'FailWhenTriggerIsNotFound' is not set during enabling a trigger" {
                # Arrange
                $resourceGroup = "my resource group"
                $dataFactoryName = "my data factory"
                $dataFactoryTriggerName = "my data factory trigger"

                Mock Get-AzDataFactoryV2 { }
                Mock Get-AzDataFactoryV2Trigger { throw "Sabotage the trigger retrieval" }
                Mock Start-AzDataFactoryV2Trigger { return $true }
                Mock Stop-AzDataFactoryV2Trigger { return $true }

                # Act
                Enable-AzDataFactoryTrigger -ResourceGroupName $resourceGroup -DataFactoryName $dataFactoryName -DataFactoryTriggerName $dataFactoryTriggerName

                # Assert
                Assert-MockCalled Start-AzDataFactoryV2Trigger -Times 0
                Assert-MockCalled Stop-AzDataFactoryV2Trigger -Times 0
                Assert-MockCalled Get-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
                Assert-MockCalled Get-AzDataFactoryV2 -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $Name -eq $dataFactoryName }
            }
            It "Skips actions when trigger was not found and 'FailWhenTriggerIsNotFound' is not set during disabling a trigger" {
                # Arrange
                $resourceGroup = "my resource group"
                $dataFactoryName = "my data factory"
                $dataFactoryTriggerName = "my data factory trigger"

                Mock Get-AzDataFactoryV2 { }
                Mock Get-AzDataFactoryV2Trigger { throw "Sabotage the trigger retrieval" }
                Mock Start-AzDataFactoryV2Trigger { return $true }
                Mock Stop-AzDataFactoryV2Trigger { return $true }

                # Act
                Disable-AzDataFactoryTrigger -ResourceGroupName $resourceGroup -DataFactoryName $dataFactoryName -DataFactoryTriggerName $dataFactoryTriggerName

                # Assert
                Assert-MockCalled Start-AzDataFactoryV2Trigger -Times 0
                Assert-MockCalled Stop-AzDataFactoryV2Trigger -Times 0
                Assert-MockCalled Get-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
                Assert-MockCalled Get-AzDataFactoryV2 -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $Name -eq $dataFactoryName }
            }
            It "Throw when trigger was not found and 'FailWhenTriggerIsNotFound' is set during enabling a trigger" {
                # Arrange
                $resourceGroup = "my resource group"
                $dataFactoryName = "my data factory"
                $dataFactoryTriggerName = "my data factory trigger"

                Mock Get-AzDataFactoryV2 { }
                Mock Get-AzDataFactoryV2Trigger { throw "Sabotage the trigger retrieval" }
                Mock Start-AzDataFactoryV2Trigger { return $true }
                Mock Stop-AzDataFactoryV2Trigger { return $true }

                # Act
                { Enable-AzDataFactoryTrigger -ResourceGroupName $resourceGroup -DataFactoryName $dataFactoryName -DataFactoryTriggerName $dataFactoryTriggerName -FailWhenTriggerIsNotFound } |
                    # Assert
                    Should -Throw

                # Assert
                Assert-MockCalled Start-AzDataFactoryV2Trigger -Times 0
                Assert-MockCalled Stop-AzDataFactoryV2Trigger -Times 0
                Assert-MockCalled Get-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
                Assert-MockCalled Get-AzDataFactoryV2 -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $Name -eq $dataFactoryName }
            }
            It "Throw when trigger was not found and 'FailWhenTriggerIsNotFound' is set during disabling a trigger" {
                # Arrange
                $resourceGroup = "my resource group"
                $dataFactoryName = "my data factory"
                $dataFactoryTriggerName = "my data factory trigger"

                Mock Get-AzDataFactoryV2 { }
                Mock Get-AzDataFactoryV2Trigger { throw "Sabotage the trigger retrieval" }
                Mock Start-AzDataFactoryV2Trigger { return $true }
                Mock Stop-AzDataFactoryV2Trigger { return $true }

                # Act
                { Disable-AzDataFactoryTrigger -ResourceGroupName $resourceGroup -DataFactoryName $dataFactoryName -DataFactoryTriggerName $dataFactoryTriggerName -FailWhenTriggerIsNotFound } |
                    # Assert
                    Should -Throw

                # Assert
                Assert-MockCalled Start-AzDataFactoryV2Trigger -Times 0
                Assert-MockCalled Stop-AzDataFactoryV2Trigger -Times 0
                Assert-MockCalled Get-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
                Assert-MockCalled Get-AzDataFactoryV2 -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $Name -eq $dataFactoryName }
            }
        }
    }
}
