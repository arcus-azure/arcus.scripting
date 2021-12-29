Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.IntegrationAccount -ErrorAction Stop

InModuleScope Arcus.Scripting.IntegrationAccount {
    Describe "Arcus Azure Integration Account integration tests" {
        BeforeEach {
            $filePath = "$PSScriptRoot\appsettings.json"
            [string]$appsettings = Get-Content $filePath
            $config = ConvertFrom-Json $appsettings
            
            $clientSecret = ConvertTo-SecureString $config.Arcus.ServicePrincipal.ClientSecret -AsPlainText -Force
            $pscredential = New-Object -TypeName System.Management.Automation.PSCredential($config.Arcus.ServicePrincipal.ClientId, $clientSecret)
            Disable-AzContextAutosave -Scope Process
            Connect-AzAccount -Credential $pscredential -TenantId $config.Arcus.TenantId -ServicePrincipal
        }
        Context "Handling Schemas" {
            It "Try to upload single schema to unexisting Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = "unexisting-integration-account"
                $schemaFilePath = "$PSScriptRoot\Files\IntegrationAccount\Schemas\NestedSchema.xsd"
                $schema = Get-ChildItem($schemaFilePath) -File

                # Act
                { Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaFilePath $schema.FullName -ErrorAction Stop } | 
                    Should -Throw
            }
            It "Create a single schema in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $schemaFilePath = "$PSScriptRoot\Files\IntegrationAccount\Schemas\NestedSchema.xsd"
                $schema = Get-ChildItem($schemaFilePath) -File
                $expectedSchemaName = $schema.Name
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaFilePath $schema.FullName

                    # Assert
                    $actual = Get-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName -Force
                }
            }
            It "Update a single schema in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $schemaFilePath = "$PSScriptRoot\Files\IntegrationAccount\Schemas\NestedSchema.xsd"
                $schema = Get-ChildItem($schemaFilePath) -File
                $expectedSchemaName = $schema.Name
                $executionDateTime = (Get-Date).ToUniversalTime()

                $existingSchema = New-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName -SchemaFilePath $schema.FullName

                try {
                    # Act
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaFilePath $schema.FullName

                    # Assert
                    $actual = Get-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($existingSchema.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $existingSchema.CreatedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.ChangedTime.ToUniversalTime() | Should -BeGreaterOrEqual $executionDateTime
                    $existingSchema.CreatedTime.ToUniversalTime() | Should -BeLessOrEqual $actual.ChangedTime.ToUniversalTime()

                } finally {
                    Remove-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName -Force
                }
            }
            It "Create a single schema, without extension, in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $schemaFilePath = "$PSScriptRoot\Files\IntegrationAccount\Schemas\NestedSchema.xsd"
                $schema = Get-ChildItem($schemaFilePath) -File
                $expectedSchemaName = $schema.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaFilePath $schema.FullName -RemoveFileExtensions

                    # Assert
                    $actual = Get-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName -Force
                }
            }
            It "Create a single schema, without extension and with prefix, in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $schemaFilePath = "$PSScriptRoot\Files\IntegrationAccount\Schemas\NestedSchema.xsd"
                $schema = Get-ChildItem($schemaFilePath) -File
                $artifactsPrefix = "dev-"
                $expectedSchemaName = $artifactsPrefix + $schema.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaFilePath $schema.FullName -ArtifactsPrefix $artifactsPrefix -RemoveFileExtensions

                    # Assert
                    $actual = Get-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName -Force
                }
            }
            It "Create multiple schemas located in a folder in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $schemasFolder = "$PSScriptRoot\Files\IntegrationAccount\Schemas"
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemasFolder $schemasFolder

                    # Assert
                    foreach ($schema in Get-ChildItem("$schemasFolder") -File) {
                        $expectedSchemaName = $schema.Name
                        
                        $actual = Get-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                        $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($schema in Get-ChildItem("$schemasFolder") -File) {
                        $expectedSchemaName = $schema.Name
                        
                        Remove-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName -Force
                    }
                }
            }
            It "Create multiple schemas, without extension, located in a folder in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $schemasFolder = "$PSScriptRoot\Files\IntegrationAccount\Schemas"
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemasFolder $schemasFolder -RemoveFileExtensions

                    # Assert
                    foreach ($schema in Get-ChildItem("$schemasFolder") -File) {
                        $expectedSchemaName = $schema.BaseName
                        
                        $actual = Get-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                        $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($schema in Get-ChildItem("$schemasFolder") -File) {
                        $expectedSchemaName = $schema.BaseName
                        
                        Remove-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName -Force
                    }
                }
            }
            It "Create multiple schemas, without extension and with prefix, located in a folder in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $schemasFolder = "$PSScriptRoot\Files\IntegrationAccount\Schemas"
                $artifactsPrefix = "dev-"
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemasFolder $schemasFolder -ArtifactsPrefix $artifactsPrefix -RemoveFileExtensions

                    # Assert
                    foreach ($schema in Get-ChildItem("$schemasFolder") -File) {
                        $expectedSchemaName = $artifactsPrefix + $schema.BaseName
                        
                        $actual = Get-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                        $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($schema in Get-ChildItem("$schemasFolder") -File) {
                        $expectedSchemaName = $artifactsPrefix + $schema.BaseName
                        
                        Remove-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName -Force
                    }
                }
            }
        }
        Context "Handling Maps" {
            It "Try to upload single map to unexisting Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = "unexisting-integration-account"
                $mapFilePath = "$PSScriptRoot\Files\IntegrationAccount\Maps\BankTransfer_CSV-to-BankTransfer_Canonical.xslt"
                $map = Get-ChildItem($mapFilePath) -File

                # Act
                { Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapFilePath $map.FullName -ErrorAction Stop} |
                    Should -Throw
            }
            It "Create a single map in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $mapFilePath = "$PSScriptRoot\Files\IntegrationAccount\Maps\BankTransfer_CSV-to-BankTransfer_Canonical.xslt"
                $map = Get-ChildItem($mapFilePath) -File
                $expectedMapName = $map.Name
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapFilePath $map.FullName

                    # Assert
                    $actual = Get-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName
                    $actual | Should -Not -BeNullOrEmpty 
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn @($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName -Force
                }
            }
            It "Update a single map in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $mapFilePath = "$PSScriptRoot\Files\IntegrationAccount\Maps\BankTransfer_CSV-to-BankTransfer_Canonical.xslt"
                $map = Get-ChildItem($mapFilePath) -File
                $expectedMapName = $map.Name
                $executionDateTime = (Get-Date).ToUniversalTime()

                $existingMap = New-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName -MapFilePath $map.FullName

                try {
                    # Act
                    Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapFilePath $map.FullName

                    # Assert
                    $actual = Get-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($existingMap.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $existingMap.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.ChangedTime.ToUniversalTime() | Should -BeGreaterOrEqual $executionDateTime
                    $existingMap.CreatedTime.ToUniversalTime() | Should -BeLessOrEqual $actual.ChangedTime.ToUniversalTime()

                } finally {
                    Remove-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName -Force
                }
            }
            It "Create a single map, without extension, in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $mapFilePath = "$PSScriptRoot\Files\IntegrationAccount\Maps\BankTransfer_CSV-to-BankTransfer_Canonical.xslt"
                $map = Get-ChildItem($mapFilePath) -File
                $expectedMapName = $map.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapFilePath $map.FullName -RemoveFileExtensions

                    # Assert
                    $actual = Get-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName -Force
                }
            }
            It "Create a single map, without extension and with prefix, in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $mapFilePath = "$PSScriptRoot\Files\IntegrationAccount\Maps\BankTransfer_CSV-to-BankTransfer_Canonical.xslt"
                $map = Get-ChildItem($mapFilePath) -File
                $artifactsPrefix = "dev-"
                $expectedMapName = $artifactsPrefix + $map.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapFilePath $map.FullName -ArtifactsPrefix $artifactsPrefix -RemoveFileExtensions

                    # Assert
                    $actual = Get-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName -Force
                }
            }
            It "Create multiple maps located in a folder in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $mapsFolder = "$PSScriptRoot\Files\IntegrationAccount\Maps"
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapsFolder $mapsFolder

                    # Assert
                    foreach ($map in Get-ChildItem($mapsFolder) -File) {
                        $expectedMapName = $map.Name
                        
                        $actual = Get-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                        $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($map in Get-ChildItem($mapsFolder) -File) {
                        $expectedMapName = $map.Name
                        
                        Remove-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName -Force
                    }
                }
            }
            It "Create multiple maps, without extension, located in a folder in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $mapsFolder = "$PSScriptRoot\Files\IntegrationAccount\Maps"
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapsFolder $mapsFolder -RemoveFileExtensions

                    # Assert
                    foreach ($map in Get-ChildItem($mapsFolder) -File) {
                        $expectedMapName = $map.BaseName
                        
                        $actual = Get-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                        $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($map in Get-ChildItem($mapsFolder) -File) {
                        $expectedMapName = $map.BaseName
                        
                        Remove-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName -Force
                    }
                }
            }
            It "Create multiple maps, without extension and with prefix, located in a folder in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $mapsFolder = "$PSScriptRoot\Files\IntegrationAccount\Maps"
                $artifactsPrefix = "dev-"
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapsFolder $mapsFolder -ArtifactsPrefix $artifactsPrefix -RemoveFileExtensions

                    # Assert
                    foreach ($map in Get-ChildItem($mapsFolder) -File) {
                        $expectedMapName = $artifactsPrefix + $map.BaseName
                        
                        $actual = Get-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                        $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($map in Get-ChildItem($mapsFolder) -File) {
                        $expectedMapName = $artifactsPrefix + $map.BaseName
                        
                        Remove-AzIntegrationAccountMap -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapName $expectedMapName -Force
                    }
                }
            }
        }
        Context "Handling Assemblies" {
            It "Try to upload single assembly to unexisting Integration Account fails" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = "unexisting-integration-account"
                $assemblyFilePath = "$PSScriptRoot\Files\IntegrationAccount\Assemblies\AssemblyThatDoesSomething.dll"
                $assembly = Get-ChildItem($assemblyFilePath) -File

                # Act
                { Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssemblyFilePath $assembly.FullName -ErrorAction Stop} |
                    Should -Throw
            }
            It "Create a single assembly in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $assemblyFilePath = "$PSScriptRoot\Files\IntegrationAccount\Assemblies\AssemblyThatDoesSomething.dll"
                $assembly = Get-ChildItem($assemblyFilePath) -File
                $expectedAssemblyName = $assembly.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssemblyFilePath $assembly.FullName

                    # Assert
                    $actual = Get-AzIntegrationAccountAssembly -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AssemblyName $expectedAssemblyName
                    $actual | Should -Not -BeNullOrEmpty 
                    $actual.Properties.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn @($actual.Properties.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.Properties.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.Properties.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountAssembly -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AssemblyName $expectedAssemblyName
                }
            }
            It "Update a single assembly in an existing Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $assemblyFilePath = "$PSScriptRoot\Files\IntegrationAccount\Assemblies\AssemblyThatDoesSomething.dll"
                $assembly = Get-ChildItem($assemblyFilePath) -File
                $expectedAssemblyName = $assembly.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()

                $existingAssembly = New-AzIntegrationAccountAssembly -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AssemblyName $expectedAssemblyName -AssemblyFilePath $assembly.FullName

                try {
                    # Act
                    Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssemblyFilePath $assembly.FullName

                    # Assert
                    $actual = Get-AzIntegrationAccountAssembly -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AssemblyName $expectedAssemblyName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.Properties.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($existingAssembly.Properties.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $existingAssembly.Properties.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.Properties.ChangedTime.ToUniversalTime() | Should -BeGreaterOrEqual $executionDateTime
                    $existingAssembly.Properties.CreatedTime.ToUniversalTime() | Should -BeLessOrEqual $actual.Properties.ChangedTime.ToUniversalTime()

                } finally {
                    Remove-AzIntegrationAccountAssembly -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AssemblyName $expectedAssemblyName
                }
            }
            It "Create a single assembly, with prefix, in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $assemblyFilePath = "$PSScriptRoot\Files\IntegrationAccount\Assemblies\AssemblyThatDoesSomething.dll"
                $assembly = Get-ChildItem($assemblyFilePath) -File
                $artifactsPrefix = "dev-"
                $expectedAssemblyName = $artifactsPrefix + $assembly.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssemblyFilePath $assembly.FullName -ArtifactsPrefix $artifactsPrefix

                    # Assert
                    $actual = Get-AzIntegrationAccountAssembly -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AssemblyName $expectedAssemblyName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.Properties.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.Properties.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.Properties.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.Properties.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountAssembly -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AssemblyName $expectedAssemblyName
                }
            }
            It "Create multiple assemblies located in a folder in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $assembliesFolder = "$PSScriptRoot\Files\IntegrationAccount\Assemblies"
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssembliesFolder $assembliesFolder

                    # Assert
                    foreach ($assembly in Get-ChildItem($assembliesFolder) -File) {
                        $expectedAssemblyName = $assembly.BaseName
                        
                        $actual = Get-AzIntegrationAccountAssembly -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AssemblyName $expectedAssemblyName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.Properties.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.Properties.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.Properties.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                        $actual.Properties.CreatedTime | Should -BeGreaterOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($assembly in Get-ChildItem($assembliesFolder) -File) {
                        $expectedAssemblyName = $assembly.BaseName
                        
                        Remove-AzIntegrationAccountAssembly -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AssemblyName $expectedAssemblyName
                    }
                }
            }
            It "Create multiple assemblies, with prefix, located in a folder in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $assembliesFolder = "$PSScriptRoot\Files\IntegrationAccount\Assemblies"
                $artifactsPrefix = "dev-"
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssembliesFolder $assembliesFolder -ArtifactsPrefix $artifactsPrefix

                    # Assert
                    foreach ($assembly in Get-ChildItem($assembliesFolder) -File) {
                        $expectedAssemblyName = $artifactsPrefix + $assembly.BaseName
                        
                        $actual = Get-AzIntegrationAccountAssembly -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AssemblyName $expectedAssemblyName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.Properties.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.Properties.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.Properties.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                        $actual.Properties.CreatedTime | Should -BeGreaterOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($assembly in Get-ChildItem($assembliesFolder) -File) {
                        $expectedAssemblyName = $artifactsPrefix + $assembly.BaseName
                        
                        Remove-AzIntegrationAccountAssembly -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AssemblyName $expectedAssemblyName
                    }
                }
            }
        }
    }
}