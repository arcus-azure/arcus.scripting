Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.IntegrationAccount -ErrorAction Stop

InModuleScope Arcus.Scripting.IntegrationAccount {
    Describe "Arcus Azure Integration Account integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1
            
            $clientSecret = ConvertTo-SecureString $config.Arcus.ServicePrincipal.ClientSecret -AsPlainText -Force
            $pscredential = New-Object -TypeName System.Management.Automation.PSCredential($config.Arcus.ServicePrincipal.ClientId, $clientSecret)
            Disable-AzContextAutosave -Scope Process
            Connect-AzAccount -Credential $pscredential -TenantId $config.Arcus.TenantId -ServicePrincipal
        }
        Context "Uploading Schemas into an Azure Integration Account" {
            It "Try to upload single schema to unexisting Integration Account fails" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = "unexisting-integration-account"
                $schemaFilePath = "$PSScriptRoot\Files\IntegrationAccount\Schemas\NestedSchema.xsd"
                $schema = Get-ChildItem($schemaFilePath) -File

                # Act
                { Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaFilePath $schema.FullName -ErrorAction Stop } | 
                    Should -Throw
            }
            It "Create a single schema in an Integration Account succeeds" {
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
            It "Update a single schema in an Integration Account succeeds" {
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
            It "Create a single schema, without extension, in an Integration Account succeeds" {
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
            It "Create a single schema, without extension and with prefix, in an Integration Account succeeds" {
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
            It "Create multiple schemas located in a folder in an Integration Account succeeds" {
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
            It "Create multiple schemas, without extension, located in a folder in an Integration Account succeeds" {
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
            It "Create multiple schemas, without extension and with prefix, located in a folder in an Integration Account succeeds" {
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
        Context "Uploading Maps into an Azure Integration Account" {
            It "Try to upload single map to unexisting Integration Account fails" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = "unexisting-integration-account"
                $mapFilePath = "$PSScriptRoot\Files\IntegrationAccount\Maps\BankTransfer_CSV-to-BankTransfer_Canonical.xslt"
                $map = Get-ChildItem($mapFilePath) -File

                # Act
                { Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapFilePath $map.FullName -ErrorAction Stop} |
                    Should -Throw
            }
            It "Create a single map in an Integration Account succeeds" {
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
            It "Update a single map in an Integration Account succeeds" {
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
            It "Create a single map, without extension, in an Integration Account succeeds" {
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
            It "Create a single map, without extension and with prefix, in an Integration Account succeeds" {
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
            It "Create multiple maps located in a folder in an Integration Account succeeds" {
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
            It "Create multiple maps, without extension, located in a folder in an Integration Account succeeds" {
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
            It "Create multiple maps, without extension and with prefix, located in a folder in an Integration Account succeeds" {
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
        Context "Uploading Assemblies into an Azure Integration Account" {
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
            It "Update a single assembly in an Integration Account succeeds" {
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
            It "Create multiple assemblies, with prefix, located in a folder in an Integration Account succeeds" {
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
        Context "Uploading Certificates into an Azure Integration Account" {
            It "Try to upload single public certificate to unexisting Integration Account fails" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = "unexisting-integration-account"
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\certificate1.cer"
                $certificate = Get-ChildItem($certificateFilePath) -File

                # Act
                { Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Public' -CertificateFilePath $certificate.FullName -ErrorAction Stop} |
                    Should -Throw
            }
            It "Create a single public certificate in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\certificate1.cer"
                $certificate = Get-ChildItem($certificateFilePath) -File
                $expectedCertificateName = $certificate.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Public' -CertificateFilePath $certificate.FullName

                    # Assert
                    $actual = Get-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName
                    $actual | Should -Not -BeNullOrEmpty 
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn @($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName -Force
                }
            }
            It "Update a single public certificate in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\certificate1.cer"
                $certificate = Get-ChildItem($certificateFilePath) -File
                $expectedCertificateName = $certificate.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()

                $existingCertificate = New-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName -PublicCertificateFilePath $certificate.FullName

                try {
                    # Act
                    Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Public' -CertificateFilePath $certificate.FullName

                    # Assert
                    $actual = Get-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($existingCertificate.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $existingCertificate.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.ChangedTime.ToUniversalTime() | Should -BeGreaterOrEqual $executionDateTime
                    $existingCertificate.CreatedTime.ToUniversalTime() | Should -BeLessOrEqual $actual.ChangedTime.ToUniversalTime()

                } finally {
                    Remove-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName -Force
                }
            }
            It "Create a single public certificate, with prefix, in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\certificate1.cer"
                $certificate = Get-ChildItem($certificateFilePath) -File
                $artifactsPrefix = "dev-"
                $expectedCertificateName = $artifactsPrefix + $certificate.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Public' -CertificateFilePath $certificate.FullName -ArtifactsPrefix $artifactsPrefix

                    # Assert
                    $actual = Get-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName -Force
                }
            }
            It "Create multiple public certificates located in a folder in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $certificatesFolder = "$PSScriptRoot\Files\IntegrationAccount\Certificates"
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Public' -CertificatesFolder $certificatesFolder

                    # Assert
                    foreach ($certificate in Get-ChildItem($certificatesFolder) -File) {
                        $expectedCertificateName = $certificate.BaseName
                        
                        $actual = Get-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                        $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($certificate in Get-ChildItem($certificatesFolder) -File) {
                        $expectedCertificateName = $certificate.BaseName
                        
                        Remove-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName -Force
                    }
                }
            }
            It "Create multiple public certificates, with prefix, located in a folder in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $certificatesFolder = "$PSScriptRoot\Files\IntegrationAccount\Certificates"
                $artifactsPrefix = "dev-"
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Public' -CertificatesFolder $certificatesFolder -ArtifactsPrefix $artifactsPrefix

                    # Assert
                    foreach ($certificate in Get-ChildItem($certificatesFolder) -File) {
                        $expectedCertificateName = $artifactsPrefix + $certificate.BaseName
                        
                        $actual = Get-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                        $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($certificate in Get-ChildItem($certificatesFolder) -File) {
                        $expectedCertificateName = $artifactsPrefix + $certificate.BaseName
                        
                        Remove-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName -Force
                    }
                }
            }
            It "Create a single private certificate in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\certificate1.cer"
                $certificate = Get-ChildItem($certificateFilePath) -File
                $expectedCertificateName = $certificate.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()
                $subscriptionId = $config.Arcus.SubscriptionId
                $keyName = "PrivateCertificateKey-$([System.Guid]::NewGuid())"
                $keyVaultName = $config.Arcus.KeyVault.VaultName
                $keyVaultId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"

                $key = Add-AzKeyVaultKey -VaultName $config.Arcus.KeyVault.VaultName -Name $keyName -Destination 'Software'

                try {
                    # Act
                    Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Private' -CertificateFilePath $certificate.FullName -KeyName $key.Name -KeyVersion $key.Version -KeyVaultId $keyVaultId

                    # Assert
                    $actual = Get-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName
                    $actual | Should -Not -BeNullOrEmpty 
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH") | Should -Be $actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH")
                    $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName -Force
                    Remove-AzKeyVaultKey -VaultName $config.Arcus.KeyVault.VaultName -Name $keyName -Force
                }
            }
            It "Create a single private certificate, with prefix, in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\certificate1.cer"
                $certificate = Get-ChildItem($certificateFilePath) -File
                $artifactsPrefix = "dev-"
                $expectedCertificateName = $artifactsPrefix + $certificate.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()
                $subscriptionId = $config.Arcus.SubscriptionId
                $keyName = "PrivateCertificateKeyPrefix-$([System.Guid]::NewGuid())"
                $keyVaultName = $config.Arcus.KeyVault.VaultName
                $keyVaultId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"

                $key = Add-AzKeyVaultKey -VaultName $config.Arcus.KeyVault.VaultName -Name $keyName -Destination 'Software'

                try {
                    # Act
                    Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Private' -CertificateFilePath $certificate.FullName -ArtifactsPrefix $artifactsPrefix -KeyName $key.Name -KeyVersion $key.Version -KeyVaultId $keyVaultId

                    # Assert
                    $actual = Get-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName
                    $actual | Should -Not -BeNullOrEmpty 
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH") | Should -Be $actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH")
                    $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountCertificate -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -CertificateName $expectedCertificateName -Force
                    Remove-AzKeyVaultKey -VaultName $config.Arcus.KeyVault.VaultName -Name $keyName -Force
                }
            }
        }
        Context "Uploading Partners into an Azure Integration Account" {
            It "Try to upload single partner to unexisting Integration Account fails" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = "unexisting-integration-account"
                $partnerFilePath = "$PSScriptRoot\Files\IntegrationAccount\Partners\partner1.json"
                $partner = Get-ChildItem($partnerFilePath) -File

                # Act
                { Set-AzIntegrationAccountPartners -ResourceGroupName $resourceGroupName -Name $integrationAccountName -PartnerFilePath $partner.FullName -ErrorAction Stop} |
                    Should -Throw
            }
            It "Create a single partner in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $partnerFilePath = "$PSScriptRoot\Files\IntegrationAccount\Partners\partner1.json"
                $partner = Get-ChildItem($partnerFilePath) -File
                $expectedPartnerName = $partner.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountPartners -ResourceGroupName $resourceGroupName -Name $integrationAccountName -PartnerFilePath $partner.FullName

                    # Assert
                    $actual = Get-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName $expectedPartnerName
                    $actual | Should -Not -BeNullOrEmpty 
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH") | Should -Be $actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH")
                    $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName $expectedPartnerName -Force
                }
            }
            It "Update a single partner in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $partnerFilePath = "$PSScriptRoot\Files\IntegrationAccount\Partners\partner1.json"
                $partner = Get-ChildItem($partnerFilePath) -File
                $expectedPartnerName = $partner.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()

                $existingPartner = New-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName $expectedPartnerName -BusinessIdentities @("1", "12345"),@("1", "54321")

                try {
                    # Act
                    Set-AzIntegrationAccountPartners -ResourceGroupName $resourceGroupName -Name $integrationAccountName -PartnerFilePath $partner.FullName

                    # Assert
                    $actual = Get-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName $expectedPartnerName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH") | Should -Be $existingPartner.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH")
                    $actual.ChangedTime.ToUniversalTime() | Should -BeGreaterOrEqual $executionDateTime
                    $existingPartner.CreatedTime.ToUniversalTime() | Should -BeLessOrEqual $actual.ChangedTime.ToUniversalTime()

                } finally {
                    Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName $expectedPartnerName -Force
                }
            }
            It "Create a single partner, with prefix, in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $partnerFilePath = "$PSScriptRoot\Files\IntegrationAccount\Partners\partner1.json"
                $partner = Get-ChildItem($partnerFilePath) -File
                $artifactsPrefix = "dev-"
                $expectedPartnerName = $artifactsPrefix + $partner.BaseName
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountPartners -ResourceGroupName $resourceGroupName -Name $integrationAccountName -PartnerFilePath $partner.FullName -ArtifactsPrefix $artifactsPrefix

                    # Assert
                    $actual = Get-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName $expectedPartnerName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName $expectedPartnerName -Force
                }
            }
            It "Create multiple partners located in a folder in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $partnersFolder = "$PSScriptRoot\Files\IntegrationAccount\Partners"
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountPartners -ResourceGroupName $resourceGroupName -Name $integrationAccountName -PartnersFolder $partnersFolder

                    # Assert
                    foreach ($partner in Get-ChildItem($partnersFolder) -File) {
                        $expectedPartnerName = $partner.BaseName
                        
                        $actual = Get-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName $expectedPartnerName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                        $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($partner in Get-ChildItem($partnersFolder) -File) {
                        $expectedPartnerName = $partner.BaseName
                        
                        Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName $expectedPartnerName -Force
                    }
                }
            }
            It "Create multiple partners, with prefix, located in a folder in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $partnersFolder = "$PSScriptRoot\Files\IntegrationAccount\Partners"
                $artifactsPrefix = "dev-"
                $executionDateTime = (Get-Date).ToUniversalTime()

                try {
                    # Act
                    Set-AzIntegrationAccountPartners -ResourceGroupName $resourceGroupName -Name $integrationAccountName -PartnersFolder $partnersFolder -ArtifactsPrefix $artifactsPrefix

                    # Assert
                    foreach ($partner in Get-ChildItem($partnersFolder) -File) {
                        $expectedPartnerName = $artifactsPrefix + $partner.BaseName
                        
                        $actual = Get-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName $expectedPartnerName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                        $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($partner in Get-ChildItem($partnersFolder) -File) {
                        $expectedPartnerName = $artifactsPrefix + $partner.BaseName
                        
                        Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName $expectedPartnerName -Force
                    }
                }
            }
        }
        Context "Uploading Agreements into an Azure Integration Account" {
            It "Try to upload single agreement to unexisting Integration Account fails" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = "unexisting-integration-account"
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\agreement1.json"
                $agreement = Get-ChildItem($agreementFilePath) -File

                # Act
                { Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreement.FullName -ErrorAction Stop} |
                    Should -Throw
            }
            It "Create a single agreement in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\agreement1.json"
                $agreement = Get-ChildItem($agreementFilePath) -File
                $agreementData = Get-Content -Raw -Path $agreement.FullName | ConvertFrom-Json
                $expectedAgreementName = $agreementData.name
                $executionDateTime = (Get-Date).ToUniversalTime()

                New-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner1 -BusinessIdentities @("1", "12345")
                New-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner2 -BusinessIdentities @("1", "98765")

                try {
                    # Act
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreement.FullName

                    # Assert
                    $actual = Get-AzIntegrationAccountAgreement -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AgreementName $expectedAgreementName
                    $actual | Should -Not -BeNullOrEmpty 
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn @($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountAgreement -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AgreementName $expectedAgreementName -Force
                    Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner1 -Force
                    Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner2 -Force
                }
            }
            It "Update a single agreement in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\agreement1.json"
                $agreement = Get-ChildItem($agreementFilePath) -File
                $executionDateTime = (Get-Date).ToUniversalTime()
                $agreementData = Get-Content -Raw -Path $agreement.FullName | ConvertFrom-Json
                $expectedAgreementName = $agreementData.name
                $agreementType = $agreementData.properties.agreementType
                $hostPartner = $agreementData.properties.hostPartner
                $hostIdentityQualifier = $agreementData.properties.hostIdentity.qualifier
                $hostIdentityQualifierValue = $agreementData.properties.hostIdentity.value
                $guestPartner = $agreementData.properties.guestPartner    
                $guestIdentityQualifier = $agreementData.properties.guestIdentity.qualifier
                $guestIdentityQualifierValue = $agreementData.properties.guestIdentity.value
                $agreementData.properties.content.aS2.receiveAgreement.protocolSettings.messageConnectionSettings.ignoreCertificateNameMismatch = 'True'
                $agreementContent = $agreementData.properties.content | ConvertTo-Json -Depth 20 -Compress

                New-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner1 -BusinessIdentities @("1", "12345")
                New-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner2 -BusinessIdentities @("1", "98765")

                $existingAgreement = New-AzIntegrationAccountAgreement -ResourceGroupName $ResourceGroupName -IntegrationAccountName $integrationAccountName -AgreementName $expectedAgreementName -AgreementType $agreementType -HostPartner $hostPartner -HostIdentityQualifier $hostIdentityQualifier -HostIdentityQualifierValue $hostIdentityQualifierValue -GuestPartner $guestPartner -GuestIdentityQualifier $guestIdentityQualifier -GuestIdentityQualifierValue $guestIdentityQualifierValue -AgreementContent $agreementContent -ErrorAction Stop

                try {
                    # Act
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreement.FullName

                    # Assert
                    $actual = Get-AzIntegrationAccountAgreement -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AgreementName $expectedAgreementName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($existingAgreement.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $existingAgreement.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.ChangedTime.ToUniversalTime() | Should -BeGreaterOrEqual $executionDateTime
                    $actual.content.aS2.receiveAgreement.protocolSettings.messageConnectionSettings.ignoreCertificateNameMismatch | Should -Be 'False'
                    $existingAgreement.CreatedTime.ToUniversalTime() | Should -BeLessOrEqual $actual.ChangedTime.ToUniversalTime()

                } finally {
                    Remove-AzIntegrationAccountAgreement -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AgreementName $expectedAgreementName -Force
                    Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner1 -Force
                    Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner2 -Force
                }
            }
            It "Create a single agreement, with prefix, in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\agreement1.json"
                $agreement = Get-ChildItem($agreementFilePath) -File
                $agreementData = Get-Content -Raw -Path $agreement.FullName | ConvertFrom-Json
                $artifactsPrefix = "dev-"
                $expectedAgreementName = $artifactsPrefix + $agreementData.name
                $executionDateTime = (Get-Date).ToUniversalTime()

                New-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner1 -BusinessIdentities @("1", "12345")
                New-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner2 -BusinessIdentities @("1", "98765")

                try {
                    # Act
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreement.FullName -ArtifactsPrefix $artifactsPrefix

                    # Assert
                    $actual = Get-AzIntegrationAccountAgreement -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AgreementName $expectedAgreementName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                    $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountAgreement -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AgreementName $expectedAgreementName -Force
                    Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner1 -Force
                    Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner2 -Force
                }
            }
            It "Create multiple agreements located in a folder in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $agreementsFolder = "$PSScriptRoot\Files\IntegrationAccount\Agreements"
                $executionDateTime = (Get-Date).ToUniversalTime()

                New-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner1 -BusinessIdentities @("1", "12345")
                New-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner2 -BusinessIdentities @("1", "98765")

                try {
                    # Act
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementsFolder $agreementsFolder

                    # Assert
                    foreach ($agreement in Get-ChildItem($agreementsFolder) -File) {
                        $agreementData = Get-Content -Raw -Path $agreement.FullName | ConvertFrom-Json
                        $expectedAgreementName = $agreementData.name
                        
                        $actual = Get-AzIntegrationAccountAgreement -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AgreementName $expectedAgreementName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                        $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($agreement in Get-ChildItem($agreementsFolder) -File) {
                        $agreementData = Get-Content -Raw -Path $agreement.FullName | ConvertFrom-Json
                        $expectedAgreementName = $agreementData.name
                        
                        Remove-AzIntegrationAccountAgreement -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AgreementName $expectedAgreementName -Force
                        Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner1 -Force
                        Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner2 -Force
                    }
                }
            }
            It "Create multiple agreements, with prefix, located in a folder in an Integration Account succeeds" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
                $agreementsFolder = "$PSScriptRoot\Files\IntegrationAccount\Agreements"
                $artifactsPrefix = "dev-"
                $executionDateTime = (Get-Date).ToUniversalTime()

                New-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner1 -BusinessIdentities @("1", "12345")
                New-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner2 -BusinessIdentities @("1", "98765")

                try {
                    # Act
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementsFolder $agreementsFolder -ArtifactsPrefix $artifactsPrefix

                    # Assert
                    foreach ($agreement in Get-ChildItem($agreementsFolder) -File) {
                        $agreementData = Get-Content -Raw -Path $agreement.FullName | ConvertFrom-Json
                        $expectedAgreementName = $artifactsPrefix + $agreementData.name
                        
                        $actual = Get-AzIntegrationAccountAgreement -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AgreementName $expectedAgreementName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") | Should -BeIn ($actual.ChangedTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss"), $actual.ChangedTime.ToUniversalTime().AddSeconds(-1).ToString("yyyy-MM-ddTHH:mm:ss"))
                        $actual.CreatedTime | Should -BeGreaterOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($agreement in Get-ChildItem($agreementsFolder) -File) {
                        $agreementData = Get-Content -Raw -Path $agreement.FullName | ConvertFrom-Json
                        $expectedAgreementName = $artifactsPrefix + $agreementData.name
                        
                        Remove-AzIntegrationAccountAgreement -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -AgreementName $expectedAgreementName -Force
                        Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner1 -Force
                        Remove-AzIntegrationAccountPartner -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -PartnerName Partner2 -Force
                    }
                }
            }
        }
    }
}
