Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.ARM -ErrorAction Stop

InModuleScope Arcus.Scripting.ARM {
    Describe "Arcus ARM integration tests" {
        Context "ARM injection" {
            It "Replaces file path with inline file contents" {
                # Arrange
                $armTemplateFile = "$PSScriptRoot\Files\arm-template-inline.json"
                try {
                    # Act
                    Inject-ArmContent -Path $armTemplateFile

                    # Assert
                    $expected = Get-Content "$PSScriptRoot\Files\arm-template-inline-value.json"
                    $actual = Get-Content $armTemplateFile
                    $actual[7] | Should -Be '    "value": "this is a test value",'
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
                    $actual[7] | Should -Be '    "value": "{\r\n   \"test\": \"this is a test value\"\r\n}",'
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
                    $actual[7] | Should -Be '    "value": "<Operation value=\"this is a test value\" />",'
                } finally {
                    $originalFile = "$PSScriptRoot\Files\arm-template-escape-org.json"
                    Get-Content $originalFile | Out-File -FilePath $armTemplateFile
                }
            }
        }
    }
}