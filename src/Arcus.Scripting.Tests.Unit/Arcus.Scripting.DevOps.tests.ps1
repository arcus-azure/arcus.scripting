Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.DevOps -ErrorAction Stop

Describe "Arcus" {
	Context "Azure DevOps" {
		InModuleScope Arcus.Scripting.DevOps {
			It "Set-DevOpsVariable" {
				# Arrange
				Mock Write-Host { $Object | Should -Be "#vso[task.setvariable variable=test] value" } -Verifiable

				# Act
				Set-AzDevOpsVariable "test" "value"

				# Assert
				Assert-VerifiableMock
			}
		}
	}
}
