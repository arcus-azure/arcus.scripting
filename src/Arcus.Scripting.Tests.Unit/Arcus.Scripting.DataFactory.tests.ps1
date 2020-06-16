Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.DataFactory -ErrorAction Stop

Describe "Arcus" {
	Context "DataFactory" {
		It "Starts Data Factory trigger" {
			# Arrange
			$resourceGroup = "my resource group"
			$dataFactoryName = "my data factory"
			$dataFactoryTriggerName = "my data factory trigger"

			Mock Get-AzDataFactoryV2 { }
			Mock Get-AzDataFactoryV2Trigger { return [pscustomobject]@{ } }
			Mock Start-AzDataFactoryV2Trigger { return $true }
			Mock Stop-AzDataFactoryV2Trigger { return $true }

			# Act
			Start-AzDataFactoryTriggerState -ResourceGroupName $resourceGroup -DataFactoryName $dataFactoryName -DataFactoryTriggerName $dataFactoryTriggerName

			# Assert
			Assert-MockCalled Start-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
			Assert-MockCalled Stop-AzDataFactoryV2Trigger -Times 0
			Assert-MockCalled Get-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
			Assert-MockCalled Get-AzDataFactoryV2 -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $Name -eq $dataFactoryName }
		}
		It "Stops Data Factory trigger" {
			# Arrange
			$resourceGroup = "my resource group"
			$dataFactoryName = "my data factory"
			$dataFactoryTriggerName = "my data factory trigger"

			Mock Get-AzDataFactoryV2 { }
			Mock Get-AzDataFactoryV2Trigger { return [pscustomobject]@{ } }
			Mock Start-AzDataFactoryV2Trigger { return $true }
			Mock Stop-AzDataFactoryV2Trigger { return $true }

			# Act
			Stop-AzDataFactoryTriggerState -ResourceGroupName $resourceGroup -DataFactoryName $dataFactoryName -DataFactoryTriggerName $dataFactoryTriggerName

			# Assert
			Assert-MockCalled Start-AzDataFactoryV2Trigger -Times 0
			Assert-MockCalled Stop-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
			Assert-MockCalled Get-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
			Assert-MockCalled Get-AzDataFactoryV2 -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $Name -eq $dataFactoryName }
		}
		It "Skips actions when trigger was not found and 'FailWhenTriggerIsNotFound' is not set during starting a trigger" {
			# Arrange
			$resourceGroup = "my resource group"
			$dataFactoryName = "my data factory"
			$dataFactoryTriggerName = "my data factory trigger"

			Mock Get-AzDataFactoryV2 { }
			Mock Get-AzDataFactoryV2Trigger { throw "Sabotage the trigger retrieval" }
			Mock Start-AzDataFactoryV2Trigger { return $true }
			Mock Stop-AzDataFactoryV2Trigger { return $true }

			# Act
			Start-AzDataFactoryTriggerState -ResourceGroupName $resourceGroup -DataFactoryName $dataFactoryName -DataFactoryTriggerName $dataFactoryTriggerName

			# Assert
			Assert-MockCalled Start-AzDataFactoryV2Trigger -Times 0
			Assert-MockCalled Stop-AzDataFactoryV2Trigger -Times 0
			Assert-MockCalled Get-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
			Assert-MockCalled Get-AzDataFactoryV2 -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $Name -eq $dataFactoryName }
		}
		It "Skips actions when trigger was not found and 'FailWhenTriggerIsNotFound' is not set during stopping a trigger" {
			# Arrange
			$resourceGroup = "my resource group"
			$dataFactoryName = "my data factory"
			$dataFactoryTriggerName = "my data factory trigger"

			Mock Get-AzDataFactoryV2 { }
			Mock Get-AzDataFactoryV2Trigger { throw "Sabotage the trigger retrieval" }
			Mock Start-AzDataFactoryV2Trigger { return $true }
			Mock Stop-AzDataFactoryV2Trigger { return $true }

			# Act
			Stop-AzDataFactoryTriggerState -ResourceGroupName $resourceGroup -DataFactoryName $dataFactoryName -DataFactoryTriggerName $dataFactoryTriggerName

			# Assert
			Assert-MockCalled Start-AzDataFactoryV2Trigger -Times 0
			Assert-MockCalled Stop-AzDataFactoryV2Trigger -Times 0
			Assert-MockCalled Get-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
			Assert-MockCalled Get-AzDataFactoryV2 -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $Name -eq $dataFactoryName }
		}
		It "Throw when trigger was not found and 'FailWhenTriggerIsNotFound' is set during starting a trigger" {
			# Arrange
			$resourceGroup = "my resource group"
			$dataFactoryName = "my data factory"
			$dataFactoryTriggerName = "my data factory trigger"

			Mock Get-AzDataFactoryV2 { }
			Mock Get-AzDataFactoryV2Trigger { throw "Sabotage the trigger retrieval" }
			Mock Start-AzDataFactoryV2Trigger { return $true }
			Mock Stop-AzDataFactoryV2Trigger { return $true }

			# Act
			{ Start-AzDataFactoryTriggerState -ResourceGroupName $resourceGroup -DataFactoryName $dataFactoryName -DataFactoryTriggerName $dataFactoryTriggerName -FailWhenTriggerIsNotFound } |
				# Assert
				Should -Throw

			# Assert
			Assert-MockCalled Start-AzDataFactoryV2Trigger -Times 0
			Assert-MockCalled Stop-AzDataFactoryV2Trigger -Times 0
			Assert-MockCalled Get-AzDataFactoryV2Trigger -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $DataFactoryName -eq $dataFactoryName -and $Name -eq $dataFactoryTriggerName }
			Assert-MockCalled Get-AzDataFactoryV2 -Times 1 -ParameterFilter { $ResourceGroupName -eq $resourceGroup -and $Name -eq $dataFactoryName }
		}
		It "Throw when trigger was not found and 'FailWhenTriggerIsNotFound' is set during stopping a trigger" {
			# Arrange
			$resourceGroup = "my resource group"
			$dataFactoryName = "my data factory"
			$dataFactoryTriggerName = "my data factory trigger"

			Mock Get-AzDataFactoryV2 { }
			Mock Get-AzDataFactoryV2Trigger { throw "Sabotage the trigger retrieval" }
			Mock Start-AzDataFactoryV2Trigger { return $true }
			Mock Stop-AzDataFactoryV2Trigger { return $true }

			# Act
			{ Stop-AzDataFactoryTriggerState -ResourceGroupName $resourceGroup -DataFactoryName $dataFactoryName -DataFactoryTriggerName $dataFactoryTriggerName -FailWhenTriggerIsNotFound } |
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