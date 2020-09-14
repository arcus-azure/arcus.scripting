Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.ARM -ErrorAction Stop

Describe "Arcus" {
	Context "ARM" {
		InModuleScope Arcus.Scripting.ARM {
			It "Replaces file path with inline file contents" {
				# Arrange
				$armTemplateFile = "$PSScriptRoot\Files\arm-template-inline.json"
				try {
				    # Act
				    Inject-ArmContent -Path $armTemplateFile

				    # Assert
				    $expected = Get-Content "$PSScriptRoot\Files\arm-template-inline-value.json"
				    $actual = Get-Content $armTemplateFile
				    $actual[7].Trim(' ') | -Should Match $expected
				} finally {
				    $originalFile = "$PSScriptRoot\Files\arm-template-inline-org.json"
				    Get-Content $originalFile | Out-File -FilePath $armTemplateFile
				}
			}
			It "Replaces file path with file contents as JSON object" {
				# Arrange
				$armTemplateFile = "$PSScriptRoot\Files\arm-template-object.json"
				try {
				    # Act
				    Inject-ArmContent -Path $armTemplateFile

				    # Assert
				    $expected = Get-Content "$PSScriptRoot\Files\arm-template-object-value.json"
				    $actual = Get-Content $armTemplateFile
				    $actual[7].Trim(' ') | -Should Match """value"":  { ""test"": ""this is a test value"" }"
				} finally {
				    $originalFile = "$PSScriptRoot\Files\arm-template-object-org.json"
				    Get-Content $originalFile | Out-File -FilePath $armTemplateFile
				}
			}
			It "Replaces file path with file contents as escaped JSON and replaced special characters" {
				# Arrange
				$armTemplateFile = "$PSScriptRoot\Files\arm-template-escape.json"
				try {
				    # Act
				    Inject-ArmContent -Path $armTemplateFile

				    # Assert
				    $expected = Get-Content "$PSScriptRoot\Files\arm-template-escape-value.xml"
				    $actual = Get-Content $armTemplateFile
				    $actual[7].Trim(' ') | -Should Match "<Operation value=\\""this is a test value\\"" \/>"
				} finally {
				    $originalFile = "$PSScriptRoot\Files\arm-template-escape-org.json"
				    Get-Content $originalFile | Out-File -FilePath $armTemplateFile
				}
			}
		}
	}
}