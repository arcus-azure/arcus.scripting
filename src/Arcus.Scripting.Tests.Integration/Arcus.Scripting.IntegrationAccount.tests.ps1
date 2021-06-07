Import-Module Az.KeyVault
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
            It "Create a single schema in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
				$schemaFilePath = "$PSScriptRoot\Files\IntegrationAccount\Schemas\NestedSchema.xsd"
                [System.IO.FileInfo]$schema = New-Object System.IO.FileInfo("$SchemaFilePath")
                $expectedSchemaName = $schema.Name
                $executionDateTime = Get-Date

                try {
                    # Act
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaFilePath $schema.FullName

                    # Assert
                    $actual = Get-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToString("yyyy-MM-ddTHH:mm:ss") | Should -Be $actual.ChangedTime.ToString("yyyy-MM-ddTHH:mm:ss")
                    $actual.CreatedTime | Should -BeLessOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName -Force
                }
            }
            It "Create a single schema, without extension, in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
				$schemaFilePath = "$PSScriptRoot\Files\IntegrationAccount\Schemas\NestedSchema.xsd"
                [System.IO.FileInfo]$schema = New-Object System.IO.FileInfo("$SchemaFilePath")
                $expectedSchemaName = $schema.BaseName
                $executionDateTime = Get-Date

                try {
                    # Act
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaFilePath $schema.FullName -RemoveFileExtensions

                    # Assert
                    $actual = Get-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToString("yyyy-MM-ddTHH:mm:ss") | Should -Be $actual.ChangedTime.ToString("yyyy-MM-ddTHH:mm:ss")
                    $actual.CreatedTime | Should -BeLessOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName -Force
                }
            }
            It "Create a single schema, without extension and with prefix, in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
				$schemaFilePath = "$PSScriptRoot\Files\IntegrationAccount\Schemas\NestedSchema.xsd"
                [System.IO.FileInfo]$schema = New-Object System.IO.FileInfo("$SchemaFilePath")
                $artifactsPrefix = "dev-"
                $expectedSchemaName = $artifactsPrefix + $schema.BaseName
                $executionDateTime = Get-Date

                try {
                    # Act
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaFilePath $schema.FullName -ArtifactsPrefix $artifactsPrefix -RemoveFileExtensions

                    # Assert
                    $actual = Get-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName
                    $actual | Should -Not -BeNullOrEmpty
                    $actual.CreatedTime.ToString("yyyy-MM-ddTHH:mm:ss") | Should -Be $actual.ChangedTime.ToString("yyyy-MM-ddTHH:mm:ss")
                    $actual.CreatedTime | Should -BeLessOrEqual $executionDateTime

                } finally {
                    Remove-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName -Force
                }
            }
            It "Create multiple schemas located in a folder in an Integration Account" {
                # Arrange
                $resourceGroupName = $config.Arcus.ResourceGroupName
                $integrationAccountName = $config.Arcus.IntegrationAccount.Name
				$schemasFolder = "$PSScriptRoot\Files\IntegrationAccount\Schemas"
                $executionDateTime = Get-Date

                try {
                    # Act
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemasFolder $schemasFolder

                    # Assert
                    foreach ($schema in Get-ChildItem("$schemasFolder") -File) {
                        $expectedSchemaName = $schema.Name
                        
                        $actual = Get-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToString("yyyy-MM-ddTHH:mm:ss") | Should -Be $actual.ChangedTime.ToString("yyyy-MM-ddTHH:mm:ss")
                        $actual.CreatedTime | Should -BeLessOrEqual $executionDateTime
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
                $executionDateTime = Get-Date

                try {
                    # Act
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemasFolder $schemasFolder -RemoveFileExtensions

                    # Assert
                    foreach ($schema in Get-ChildItem("$schemasFolder") -File) {
                        $expectedSchemaName = $schema.BaseName
                        
                        $actual = Get-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToString("yyyy-MM-ddTHH:mm:ss") | Should -Be $actual.ChangedTime.ToString("yyyy-MM-ddTHH:mm:ss")
                        $actual.CreatedTime | Should -BeLessOrEqual $executionDateTime
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
                $executionDateTime = Get-Date

                try {
                    # Act
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemasFolder $schemasFolder -ArtifactsPrefix $artifactsPrefix -RemoveFileExtensions

                    # Assert
                    foreach ($schema in Get-ChildItem("$schemasFolder") -File) {
                        $expectedSchemaName = $artifactsPrefix + $schema.BaseName
                        
                        $actual = Get-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName
                        $actual | Should -Not -BeNullOrEmpty
                        $actual.CreatedTime.ToString("yyyy-MM-ddTHH:mm:ss") | Should -Be $actual.ChangedTime.ToString("yyyy-MM-ddTHH:mm:ss")
                        $actual.CreatedTime | Should -BeLessOrEqual $executionDateTime
                    }

                } finally {
                    foreach ($schema in Get-ChildItem("$schemasFolder") -File) {
                        $expectedSchemaName = $artifactsPrefix + $schema.BaseName
                        
                        Remove-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $expectedSchemaName -Force
                    }
                }
            }
            
        }
    }
}