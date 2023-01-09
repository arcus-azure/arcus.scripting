Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Bicep -ErrorAction Stop

InModuleScope Arcus.Scripting.Bicep {
    Describe "Arcus Bicep integration tests" {
        Context "Bicep injection" {
            It "Replaces file path with inline file contents" {
                # Arrange
                $bicepTemplateFile = "$PSScriptRoot\Files\bicep-template-inline.bicep"
                $originalContents = Get-Content $bicepTemplateFile

                try {
                    # Act
                    Inject-BicepContent -Path $bicepTemplateFile

                    # Assert
                    $expected = Get-Content "$PSScriptRoot\Files\bicep-template-inline-value.json"
                    $actual = Get-Content $bicepTemplateFile
                    $actual[5] | Should -Be '    value: ''this is a test value'''
                } finally {
                    $originalContents | Out-File -FilePath $bicepTemplateFile
                }
            }
            if ([Environment]::OSVersion.VersionString -like "*Windows*") {
                It "Replaces relative file path with file contents as Bicep object (windows)" {
                    # Arrange
                    $bicepTemplateFile = "$PSScriptRoot\Files\bicep-template-object (windows).bicep"
                    $originalContents = Get-Content $bicepTemplateFile
                    try {
                        # Act
                        Inject-BicepContent -Path $bicepTemplateFile

                        # Assert
                        $expected = Get-Content "$PSScriptRoot\Files\bicep-template-object-value (windows).json"
                        $actual = Get-Content $bicepTemplateFile
                        $actual[5] | Should -Be '    value: ''{\r\n   "test": "this is a test value"\r\n}'''
                    } finally {
                        $originalContents | Out-File -FilePath $bicepTemplateFile
                    }
                }
                It "Replaces absolute file path with file contents as Bicep object (windows)" {
                    # Arrange
                    $bicepTemplateFile = "$PSScriptRoot\Files\bicep-template-object-absolutepath (windows).bicep"
                    $bicepTemplateDirectory = Split-Path $bicepTemplateFile -Parent
                    $originalContents = Get-Content $bicepTemplateFile
                    $bicepTemplate = $originalContents -replace '#{ArmTemplateDirectory}#', $bicepTemplateDirectory
                    $bicepTemplate | Out-File -FilePath $bicepTemplateFile

                    try {
                        # Act
                        Inject-BicepContent -Path $bicepTemplateFile

                        # Assert
                        $expected = Get-Content "$PSScriptRoot\Files\bicep-template-object-value (windows).json"
                        $actual = Get-Content $bicepTemplateFile
                        $actual[5] | Should -Be '    value: ''{\r\n   "test": "this is a test value"\r\n}'''
                    } finally {
                        $originalContents | Out-File -FilePath $bicepTemplateFile
                    }
                }
            } else {
                It "Replaces relative file path with file contents as Bicep object (linux)" {
                    # Arrange
                    $bicepTemplateFile = "$PSScriptRoot\Files\bicep-template-object (linux).bicep"
                    $originalContents = Get-Content $bicepTemplateFile
                    try {
                        # Act
                        Inject-BicepContent -Path $bicepTemplateFile

                        # Assert
                        $expected = Get-Content "$PSScriptRoot\Files\bicep-template-object-value (linux).json"
                        $actual = Get-Content $bicepTemplateFile
                        $actual[5] | Should -Be '    value: ''{\r\n   \"test\": \"this is a test value\"\r\n}'''
                    } finally {
                        $originalContents | Out-File -FilePath $bicepTemplateFile
                    }
                }
                It "Replaces absolute file path with file contents as Bicep object (linux)" {
                    # Arrange
                    $bicepTemplateFile = "$PSScriptRoot\Files\bicep-template-object-absolutepath (linux).bicep"
                    $bicepTemplateDirectory = Split-Path $bicepTemplateFile -Parent
                    $originalContents = Get-Content -Path $bicepTemplateFile
                    $bicepTemplate = $originalContents -replace '#{ArmTemplateDirectory}#', $bicepTemplateDirectory
                    $bicepTemplate | Out-File -FilePath $bicepTemplateFile

                    try {
                        # Act
                        Inject-BicepContent -Path $bicepTemplateFile

                        # Assert
                        $expected = Get-Content "$PSScriptRoot\Files\bicep-template-object-value (linux).json"
                        $actual = Get-Content $bicepTemplateFile
                        $actual[5] | Should -Be '    value: ''{\r\n   \"test\": \"this is a test value\"\r\n}'''
                    } finally {
                        $originalContents | Out-File -FilePath $bicepTemplateFile
                    }
                }
            }
            It "Replaces file path with inline file contents and replaced special characters" {
                # Arrange
                $bicepTemplateFile = "$PSScriptRoot\Files\bicep-template-replacespecialchars.bicep"
                $originalContents = Get-Content $bicepTemplateFile
                try {
                    # Act
                    Inject-BicepContent -Path $bicepTemplateFile

                    # Assert
                    $expected = Get-Content "$PSScriptRoot\Files\bicep-template-replacespecialchars-value.xml"
                    $actual = Get-Content $bicepTemplateFile
                    $actual[5] | Should -Be '    value: ''<Operation value="this is a test value" />'''
                } finally {
                    $originalContents | Out-File -FilePath $bicepTemplateFile
                }
            }
        }
    }
}