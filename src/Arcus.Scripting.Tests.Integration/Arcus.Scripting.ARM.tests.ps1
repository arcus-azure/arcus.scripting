Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.ARM -ErrorAction Stop

InModuleScope Arcus.Scripting.ARM {
    Describe "Arcus ARM integration tests" {
        Context "ARM injection" {
            It "Replaces file path with inline file contents" {
                # Arrange
                $armTemplateFile = "$PSScriptRoot\Files\arm-template-inline.json"
                $originalContents = Get-Content $armTemplateFile

                try {
                    # Act
                    Inject-ArmContent -Path $armTemplateFile

                    # Assert
                    $expected = Get-Content "$PSScriptRoot\Files\arm-template-inline-value.json"
                    $actual = Get-Content $armTemplateFile
                    $actual[7] | Should -Be '    "value": "this is a test value",'
                } finally {
                    $originalContents | Out-File -FilePath $armTemplateFile
                }
            }
            if ([Environment]::OSVersion.VersionString -like "*Windows*") {
                It "Replaces relative file path with file contents as JSON object (windows)" {
                    # Arrange
                    $armTemplateFile = "$PSScriptRoot\Files\arm-template-object (windows).json"
                    $originalContents = Get-Content $armTemplateFile
                    try {
                        # Act
                        Inject-ArmContent -Path $armTemplateFile

                        # Assert
                        $expected = Get-Content "$PSScriptRoot\Files\arm-template-object-value (windows).json"
                        $actual = Get-Content $armTemplateFile
                        $actual[7] | Should -Be '    "value": "{\r\n   \"test\": \"this is a test value\"\r\n}",'
                    } finally {
                        $originalContents | Out-File -FilePath $armTemplateFile
                    }
                }
                It "Replaces absolute file path with file contents as JSON object (windows)" {
                    # Arrange
                    $armTemplateFile = "$PSScriptRoot\Files\arm-template-object-absolutepath (windows).json"
                    $armTemplateDirectory = Split-Path $armTemplateFile -Parent
                    $originalContents = Get-Content $armTemplateFile
                    $armTemplate = $originalContents -replace '#{ArmTemplateDirectory}#', $armTemplateDirectory
                    $armTemplate | Out-File -FilePath $armTemplateFile

                    try {
                        # Act
                        Inject-ArmContent -Path $armTemplateFile

                        # Assert
                        $expected = Get-Content "$PSScriptRoot\Files\arm-template-object-value (windows).json"
                        $actual = Get-Content $armTemplateFile
                        $actual[7] | Should -Be '    "value": "{\r\n   \"test\": \"this is a test value\"\r\n}",'
                    } finally {
                        $originalContents | Out-File -FilePath $armTemplateFile
                    }
                }
            } else {
                It "Replaces relative file path with file contents as JSON object (linux)" {
                    # Arrange
                    $armTemplateFile = "$PSScriptRoot\Files\arm-template-object (linux).json"
                    $originalContents = Get-Content $armTemplateFile
                    try {
                        # Act
                        Inject-ArmContent -Path $armTemplateFile

                        # Assert
                        $expected = Get-Content "$PSScriptRoot\Files\arm-template-object-value (linux).json"
                        $actual = Get-Content $armTemplateFile
                        $actual[7] | Should -Be '    "value": "{\n   \"test\": \"this is a test value\"\n}",'
                    } finally {
                        $originalContents | Out-File -FilePath $armTemplateFile
                    }
                }
                It "Replaces absolute file path with file contents as JSON object (linux)" {
                    # Arrange
                    $armTemplateFile = "$PSScriptRoot\Files\arm-template-object-absolutepath (linux).json"
                    $armTemplateDirectory = Split-Path $armTemplateFile -Parent
                    $originalContents = Get-Content -Path $armTemplateFile
                    $armTemplate = $originalContents -replace '#{ArmTemplateDirectory}#', $armTemplateDirectory
                    $armTemplate | OutFile -FilePath $armTemplateFile

                    try {
                        # Act
                        Inject-ArmContent -Path $armTemplateFile

                        # Assert
                        $expected = Get-Content "$PSScriptRoot\Files\arm-template-object-value (linux).json"
                        $actual = Get-Content $armTemplateFile
                        $actual[7] | Should -Be '    "value": "{\n   \"test\": \"this is a test value\"\n}",'
                    } finally {
                        $originalContents | Out-File -FilePath $armTemplateFile
                    }
                }
            }
            It "Replaces file path with file contents as escaped JSON and replaced special characters" {
                # Arrange
                $armTemplateFile = "$PSScriptRoot\Files\arm-template-escape.json"
                $originalContents = Get-Content $armTemplateFile
                try {
                    # Act
                    Inject-ArmContent -Path $armTemplateFile

                    # Assert
                    $expected = Get-Content "$PSScriptRoot\Files\arm-template-escape-value.xml"
                    $actual = Get-Content $armTemplateFile
                    $actual[7] | Should -Be '    "value": "<Operation value=\"this is a test value\" />",'
                } finally {
                    $originalContents | Out-File -FilePath $armTemplateFile
                }
            }
        }
    }
}