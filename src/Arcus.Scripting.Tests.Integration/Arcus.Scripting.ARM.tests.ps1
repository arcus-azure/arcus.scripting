Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.ARM -ErrorAction Stop

Describe "Arcus" {
	Context "ARM" {
		InModuleScope Arcus.Scripting.ARM {
			It "Replaces file path with file contents" {
				# Arrange
				$armTemplateFile = "$PSScriptRoot\Files\arm-template.json"
				try {
				    # Act
				    Inject-ArmContent -Path $armTemplateFile

				    # Assert
				    $expected = Get-Content "$PSScriptRoot\Files\sample-values.json"
				    $actual = Get-Content "$PSScriptRoot\Files\arm-template.json"
				    $actual[7].Trim(' ') | Should -Match $expected
				} finally {
				    $originalFile = "$PSScriptRoot\Files\arm-template-org.json"
				    Get-Content $originalFile | Out-File -FilePath $armTemplateFile
				}
			}
		}
	}
}