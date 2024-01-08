Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.IntegrationAccount -ErrorAction Stop

InModuleScope Arcus.Scripting.IntegrationAccount {
    Describe "Arcus Azure Integration Account unit tests" {
        Context "Azure Integration Account Schemas" {
            It "Providing both schemaFilePath and schemasFolder should fail" {
                # Arrange
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $schemaFilePath = "$PSScriptRoot\Files\IntegrationAccount\Schemas\NestedSchema.xsd"
                $SchemasFolder = "$PSScriptRoot\Files\IntegrationAccount\Schemas\"

                # Act
                { 
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaFilePath $schemaFilePath -SchemasFolder $schemasFolder
                } | Should -Throw -ExpectedMessage "Either the file path of a specific schema or the file path of a folder containing multiple schemas is required, e.g.: -SchemaFilePath 'C:\Schemas\Schema.xsd' or -SchemasFolder 'C:\Schemas'"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing neither a schemaFilePath nor schemasFolder should fail" {
                # Arrange
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"

                # Act
                { 
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName
                } | Should -Throw -ExpectedMessage "Either the file path of a specific schema or the file path of a folder containing multiple schemas is required, e.g.: -SchemaFilePath 'C:\Schemas\Schema.xsd' or -SchemasFolder 'C:\Schemas'"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing only the schemaFilePath to create a schema is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $schemaName = 'Dummy_New_Schema'
                $schemaResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/schemas/$schemaName"
                $schemaFilePath = "$PSScriptRoot\Files\IntegrationAccount\Schemas\$schemaName.xsd"

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountSchema {
                    return $null
                } -Verifiable

                Mock Set-AzIntegrationAccountSchema {
                    return $null
                }

                Mock New-AzIntegrationAccountSchema {
                    return [pscustomobject]@{ Id = $schemaResourceId; Name = $schemaName; Type = 'Microsoft.Logic/integrationAccounts/schemas'; SchemaType = 'Xml'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                # Act
                { 
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaFilePath $schemaFilePath
                } | Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountSchema -Times 1
                Assert-MockCalled Set-AzIntegrationAccountSchema -Times 0
                Assert-MockCalled New-AzIntegrationAccountSchema -Times 1
            }
            It "Providing only the schemaFilePath to update a schema is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $schemaName = 'Dummy_Existing_Schema'
                $schemaResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/schemas/$schemaName"
                $schemaFilePath = "$PSScriptRoot\Files\IntegrationAccount\Schemas\$schemaName.xsd"

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountSchema {
                    return [pscustomobject]@{ Id = $schemaResourceId; Name = $schemaName; Type = 'Microsoft.Logic/integrationAccounts/schemas'; SchemaType = 'Xml'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                } -Verifiable

                Mock Set-AzIntegrationAccountSchema {
                    return [pscustomobject]@{ Id = $schemaResourceId; Name = $schemaName; Type = 'Microsoft.Logic/integrationAccounts/schemas'; SchemaType = 'Xml'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                Mock New-AzIntegrationAccountSchema {
                    return $null
                }

                # Act
                { 
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaFilePath $schemaFilePath
                } | Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountSchema -Times 1
                Assert-MockCalled Set-AzIntegrationAccountSchema -Times 1
                Assert-MockCalled New-AzIntegrationAccountSchema -Times 0
            }
            It "Providing only a schemasFolder to create schemas is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $schemasFolder = "$PSScriptRoot\Files\IntegrationAccount\Schemas\"

                Mock Get-ChildItem {
                    return @(
                        New-Item -Name "Schema1.xsd" -Type File -fo
                        New-Item -Name "Schema2.xsd" -Type File -fo
                    )
                }
                
                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountSchema {
                    return $null
                } -Verifiable

                Mock Set-AzIntegrationAccountSchema {
                    return $null
                }

                Mock New-AzIntegrationAccountSchema {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.xsd'; Type = 'Microsoft.Logic/integrationAccounts/schemas'; SchemaType = 'Xml'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                try {
                    # Act
                    { Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemasFolder $schemasFolder } | 
                    Should -Not -Throw
 
                    # Assert
                    Assert-VerifiableMock
                    Assert-MockCalled Get-AzIntegrationAccount -Times 1
                    Assert-MockCalled Get-AzIntegrationAccountSchema -Times 2
                    Assert-MockCalled Set-AzIntegrationAccountSchema -Times 0
                    Assert-MockCalled New-AzIntegrationAccountSchema -Times 2
                } finally {
                    Remove-Item -Path .\* -Filter "*.xsd"  -ErrorAction SilentlyContinue
                }
            }
            It "Providing only a schemasFolder to update schemas is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $schemasFolder = "$PSScriptRoot\Files\IntegrationAccount\Schemas\"

                Mock Get-ChildItem {
                    return @(
                        New-Item -Name "Schema1.xsd" -Type File -fo
                        New-Item -Name "Schema2.xsd" -Type File -fo
                    )
                }
                
                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountSchema {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.xsd'; Type = 'Microsoft.Logic/integrationAccounts/schemas'; SchemaType = 'Xml'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                } -Verifiable

                Mock Set-AzIntegrationAccountSchema {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.xsd'; Type = 'Microsoft.Logic/integrationAccounts/schemas'; SchemaType = 'Xml'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                Mock New-AzIntegrationAccountSchema {
                    return $null
                }

                try {
                    # Act
                    { Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemasFolder $schemasFolder } | 
                    Should -Not -Throw
 
                    # Assert
                    Assert-VerifiableMock
                    Assert-MockCalled Get-AzIntegrationAccount -Times 1
                    Assert-MockCalled Get-AzIntegrationAccountSchema -Times 2
                    Assert-MockCalled Set-AzIntegrationAccountSchema -Times 2
                    Assert-MockCalled New-AzIntegrationAccountSchema -Times 0
                } finally {
                    Remove-Item -Path .\* -Filter "*.xsd"  -ErrorAction SilentlyContinue
                }
            }
        }
        Context "Azure Integration Account Maps" {
            It "Providing both mapFilePath and mapsFolder should fail" {
                # Arrange
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $mapFilePath = "$PSScriptRoot\Files\IntegrationAccount\Maps\BankTransfer_CSV-to-BankTransfer_Canonical.xslt"
                $mapsFolder = "$PSScriptRoot\Files\IntegrationAccount\Maps\"

                # Act
                { 
                    Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapFilePath $mapFilePath -MapsFolder $mapsFolder
                } | Should -Throw -ExpectedMessage "Either the file path of a specific map or the file path of a folder containing multiple maps is required, e.g.: -MapFilePath 'C:\Maps\map.xslt' or -MapsFolder 'C:\Maps'"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing neither a mapFilePath nor mapsFolder should fail" {
                # Arrange
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"

                # Act
                { 
                    Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName
                } | Should -Throw -ExpectedMessage "Either the file path of a specific map or the file path of a folder containing multiple maps is required, e.g.: -MapFilePath 'C:\Maps\map.xslt' or -MapsFolder 'C:\Maps'"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing only the mapFilePath to create a map is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $mapName = "Dummy_New_Map"
                $mapResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/maps/$schemaName"
                $mapFilePath = "$PSScriptRoot\Files\IntegrationAccount\Maps\$mapName.xslt"

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = "Microsoft.Logic/integrationAccounts"; Location = "westeurope"; Sku = "Free" }
                } -Verifiable

                Mock Get-AzIntegrationAccountMap {
                    return $null
                } -Verifiable

                Mock Set-AzIntegrationAccountMap {
                    return $null
                }

                Mock New-AzIntegrationAccountMap {
                    return [pscustomobject]@{ Id = $mapResourceId; Name = $mapName; Type = "Microsoft.Logic/integrationAccounts/maps"; MapType = "Xslt"; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                # Act
                { 
                    Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapFilePath $mapFilePath
                } | Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountMap -Times 1
                Assert-MockCalled Set-AzIntegrationAccountMap -Times 0
                Assert-MockCalled New-AzIntegrationAccountMap -Times 1
            }
            It "Providing only the mapFilePath to update a map is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $mapName = "Dummy_Existing_Map"
                $mapResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/maps/$schemaName"
                $mapFilePath = "$PSScriptRoot\Files\IntegrationAccount\Maps\$mapName.xslt"

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountMap {
                    return [pscustomobject]@{ Id = $mapResourceId; Name = $mapName; Type = 'Microsoft.Logic/integrationAccounts/maps'; MapType = 'Xslt'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                } -Verifiable

                Mock Set-AzIntegrationAccountMap {
                    return [pscustomobject]@{ Id = $mapResourceId; Name = $mapName; Type = 'Microsoft.Logic/integrationAccounts/maps'; MapType = 'Xslt'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                Mock New-AzIntegrationAccountMap {
                    return $null
                }

                # Act
                { 
                    Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapFilePath $mapFilePath
                } | Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountMap -Times 1
                Assert-MockCalled Set-AzIntegrationAccountMap -Times 1
                Assert-MockCalled New-AzIntegrationAccountMap -Times 0
            }
            It "Providing only a mapsFolder to create maps is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $mapsFolder = "$PSScriptRoot\Files\IntegrationAccount\Maps\"

                Mock Get-ChildItem {
                    return @(
                        New-Item -Name "map1.xslt" -Type File -fo
                        New-Item -Name "Map2.xslt" -Type File -fo
                    )
                }
                
                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountMap {
                    return $null
                } -Verifiable

                Mock Set-AzIntegrationAccountMap {
                    return $null
                }

                Mock New-AzIntegrationAccountMap {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.xslt'; Type = 'Microsoft.Logic/integrationAccounts/maps'; MapType = 'Xslt'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                try {
                    # Act
                    { Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapsFolder $mapsFolder } | 
                    Should -Not -Throw
 
                    # Assert
                    Assert-VerifiableMock
                    Assert-MockCalled Get-AzIntegrationAccount -Times 1
                    Assert-MockCalled Get-AzIntegrationAccountMap -Times 2
                    Assert-MockCalled Set-AzIntegrationAccountMap -Times 0
                    Assert-MockCalled New-AzIntegrationAccountMap -Times 2
                } finally {
                    Remove-Item -Path .\* -Filter "*.xslt" -ErrorAction SilentlyContinue
                }
            }
            It "Providing only a mapsFolder to update maps is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $mapsFolder = "$PSScriptRoot\Files\IntegrationAccount\Maps\"

                Mock Get-ChildItem {
                    return @(
                        New-Item -Name "Map1.xslt" -Type File -fo
                        New-Item -Name "Map2.xslt" -Type File -fo
                    )
                }
                
                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountMap {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.xslt'; Type = 'Microsoft.Logic/integrationAccounts/maps'; MapType = 'Xslt'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                } -Verifiable

                Mock Set-AzIntegrationAccountMap {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.xslt'; Type = 'Microsoft.Logic/integrationAccounts/maps'; MapType = 'Xslt'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                Mock New-AzIntegrationAccountMap {
                    return $null
                }

                try {
                    # Act
                    { Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapsFolder $mapsFolder } | 
                    Should -Not -Throw
 
                    # Assert
                    Assert-VerifiableMock
                    Assert-MockCalled Get-AzIntegrationAccount -Times 1
                    Assert-MockCalled Get-AzIntegrationAccountMap -Times 2
                    Assert-MockCalled Set-AzIntegrationAccountMap -Times 2
                    Assert-MockCalled New-AzIntegrationAccountMap -Times 0
                } finally {
                    Remove-Item -Path .\* -Filter "*.xslt" -ErrorAction SilentlyContinue
                }
            }
        }
        Context "Azure Integration Account Assemblies" {
            It "Providing both assemblyFilePath and assembliesFolder should fail" {
                # Arrange
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $assemblyFilePath = "$PSScriptRoot\Files\IntegrationAccount\Assemblies\LibraryThatDoesSomething.dll"
                $assembliesFolder = "$PSScriptRoot\Files\IntegrationAccount\Assemblies\"

                # Act
                { 
                    Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssemblyFilePath $assemblyFilePath -AssembliesFolder $assembliesFolder
                } | Should -Throw -ExpectedMessage "Either the file path of a specific assembly or the file path of a folder containing multiple assemblies is required, e.g.: -AssemblyFilePath 'C:\Assemblies\assembly.dll' or -AssembliesFolder 'C:\Assemblies'"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing neither a assemblyFilePath and assembliesFolder should fail" {
                # Arrange
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"

                # Act
                { 
                    Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName
                } | Should -Throw -ExpectedMessage "Either the file path of a specific assembly or the file path of a folder containing multiple assemblies is required, e.g.: -AssemblyFilePath 'C:\Assemblies\assembly.dll' or -AssembliesFolder 'C:\Assemblies'"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing only the assemblyFilePath to create an assembly is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $assemblyName = 'Dummy_New_Assembly'
                $assemblyResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/assemblies/$assemblyName"
                $assemblyFilePath = "$PSScriptRoot\Files\IntegrationAccount\Assemblies\$assemblyName.dll"

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountAssembly {
                    return $null
                } -Verifiable

                Mock Set-AzIntegrationAccountAssembly {
                    return $null
                }

                Mock New-AzIntegrationAccountAssembly {
                    return [pscustomobject]@{ Id = $assemblyResourceId; Name = $assemblyName; Type = 'Microsoft.Logic/integrationAccounts/assemblies'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                # Act
                { Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssemblyFilePath $assemblyFilePath } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountAssembly -Times 1
                Assert-MockCalled Set-AzIntegrationAccountAssembly -Times 0
                Assert-MockCalled New-AzIntegrationAccountAssembly -Times 1
            }
            It "Providing only the assemblyFilePath to update an assembly is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $assemblyName = 'Dummy_Existing_Assembly'
                $assemblyResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/assemblies/$assemblyName"
                $assemblyFilePath = "$PSScriptRoot\Files\IntegrationAccount\Assemblies\$assemblyName.xslt"

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountAssembly {
                    return [pscustomobject]@{ Id = $assemblyResourceId; Name = $assemblyName; Type = 'Microsoft.Logic/integrationAccounts/assemblies'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                } -Verifiable

                Mock Set-AzIntegrationAccountAssembly {
                    return [pscustomobject]@{ Id = $assemblyResourceId; Name = $assemblyName; Type = 'Microsoft.Logic/integrationAccounts/assemblies'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                Mock New-AzIntegrationAccountAssembly {
                    return $null
                }

                # Act
                { Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssemblyFilePath $assemblyFilePath } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountAssembly -Times 1
                Assert-MockCalled Set-AzIntegrationAccountAssembly -Times 1
                Assert-MockCalled New-AzIntegrationAccountAssembly -Times 0
            }
            It "Providing only a assembliesFolder to create assemblies is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $assembliesFolder = "$PSScriptRoot\Files\IntegrationAccount\Assemblies\"

                Mock Get-ChildItem {
                    return @(
                        New-Item -Name "assembly1.dll" -Type File -fo
                        New-Item -Name "assembly2.dll" -Type File -fo
                    )
                }
                
                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountAssembly {
                    return $null
                } -Verifiable

                Mock Set-AzIntegrationAccountAssembly {
                    return $null
                }

                Mock New-AzIntegrationAccountAssembly {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.dll'; Type = 'Microsoft.Logic/integrationAccounts/assemblies'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                # Act
                { Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssembliesFolder $assembliesFolder } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountAssembly -Times 2
                Assert-MockCalled Set-AzIntegrationAccountAssembly -Times 0
                Assert-MockCalled New-AzIntegrationAccountAssembly -Times 2
            }
            It "Providing only a assembliesFolder to update assemblies is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $assembliesFolder = "$PSScriptRoot\Files\IntegrationAccount\Assemblies\"

                Mock Get-ChildItem {
                    return @(
                        New-Item -Name "assembly1.dll" -Type File -fo
                        New-Item -Name "assembly2.dll" -Type File -fo
                    )
                }
                
                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountAssembly {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.dll'; Type = 'Microsoft.Logic/integrationAccounts/assemblies'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                } -Verifiable

                Mock Set-AzIntegrationAccountAssembly {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.dll'; Type = 'Microsoft.Logic/integrationAccounts/assemblies'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                Mock New-AzIntegrationAccountAssembly {
                    return $null
                }

                # Act
                { Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssembliesFolder $assembliesFolder } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountAssembly -Times 2
                Assert-MockCalled Set-AzIntegrationAccountAssembly -Times 2
                Assert-MockCalled New-AzIntegrationAccountAssembly -Times 0
            }
        }
        Context "Azure Integration Account Certificates" {
            It "Providing both certificateFilePath and certificatesFolder should fail" {
                # Arrange
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\certificate.cer"
                $certificatesFolder = "$PSScriptRoot\Files\IntegrationAccount\Certificates\"

                # Act
                { 
                    Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Public' -CertificateFilePath $certificateFilePath -CertificatesFolder $certificatesFolder
                } | Should -Throw -ExpectedMessage "Either the file path of a specific certificate or the file path of a folder containing multiple certificates is required, e.g.: -CertificateFilePath 'C:\Certificates\certificate.cer' or -CertificatesFolder 'C:\Certificates'"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing neither a certificateFilePath and certificatesFolder should fail" {
                # Arrange
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"

                # Act
                { 
                    Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Public'
                } | Should -Throw -ExpectedMessage "Either the file path of a specific certificate or the file path of a folder containing multiple certificates is required, e.g.: -CertificateFilePath 'C:\Certificates\certificate.cer' or -CertificatesFolder 'C:\Certificates'"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing an invalid CertificateType should fail" {
                # Arrange
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\certificate.cer"

                # Act
                { 
                    Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Wrong' -CertificateFilePath $certificateFilePath
                } | Should -Throw -ExpectedMessage "The CertificateType should be either 'Public' or 'Private'"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing a Private CertificateType and a certificatesFolder should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $certificatesFolder = "$PSScriptRoot\Files\IntegrationAccount\Certificates\"
                $keyName = "privateKey"
                $keyVersion = "1"
                $keyVaultName = "vault"
                $keyVaultId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"

                # Act
                { 
                    Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Private' -CertificatesFolder $certificatesFolder -KeyName $keyName -KeyVersion $keyVersion -KeyVaultId $keyVaultId
                } | Should -Throw -ExpectedMessage "Using the CertificatesFolder parameter in combination with Private certificates is not possible, since this would upload multiple certificates using the same Key in Azure KeyVault"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing a Private CertificateType and not a KeyName should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\certificate.cer"
                $keyVersion = "1"
                $keyVaultName = "vault"
                $keyVaultId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"

                # Act
                { 
                    Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Private' -CertificateFilePath $certificateFilePath -KeyVersion $keyVersion -KeyVaultId $keyVaultId
                } | Should -Throw -ExpectedMessage "If the CertificateType is set to 'Private', the KeyName must be supplied"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing a Private CertificateType and not a KeyVersion should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\certificate.cer"
                $keyName = "privateKey"
                $keyVaultName = "vault"
                $keyVaultId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"

                # Act
                { 
                    Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Private' -CertificateFilePath $certificateFilePath -KeyName $keyName -KeyVaultId $keyVaultId
                } | Should -Throw -ExpectedMessage "If the CertificateType is set to 'Private', the KeyVersion must be supplied"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing a Private CertificateType and not a KeyVaultId should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\certificate.cer"
                $keyName = "privateKey"
                $keyVersion = "1"

                # Act
                { 
                    Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Private' -CertificateFilePath $certificateFilePath -KeyName $keyName -KeyVersion $keyVersion
                } | Should -Throw -ExpectedMessage "If the CertificateType is set to 'Private', the KeyVaultId must be supplied"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing only the certificateFilePath to create a public certificate is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $certificateName = 'Dummy_New_Certificate'
                $certificateResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/certificates/$certificateName"
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\$certificateName.cer"

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountCertificate {
                    return $null
                } -Verifiable

                Mock Set-AzIntegrationAccountCertificate {
                    return $null
                }

                Mock New-AzIntegrationAccountCertificate {
                    return [pscustomobject]@{ Id = $certificateResourceId; Name = $certificateName; Type = 'Microsoft.Logic/integrationAccounts/certificates'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                # Act
                { Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Public' -CertificateFilePath $certificateFilePath } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountCertificate -Times 1
                Assert-MockCalled Set-AzIntegrationAccountCertificate -Times 0
                Assert-MockCalled New-AzIntegrationAccountCertificate -Times 1
            }
            It "Providing only the certificateFilePath to update a public certificate is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $certificateName = 'Dummy_Existing_Certificate'
                $certificateResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/certificates/$certificateName"
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\$certificateName.cer"

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountCertificate {
                    return [pscustomobject]@{ Id = $certificateResourceId; Name = $certificateName; Type = 'Microsoft.Logic/integrationAccounts/certificates'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                } -Verifiable

                Mock Set-AzIntegrationAccountCertificate {
                    return [pscustomobject]@{ Id = $certificateResourceId; Name = $certificateName; Type = 'Microsoft.Logic/integrationAccounts/certificates'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                Mock New-AzIntegrationAccountCertificate {
                    return $null
                }

                # Act
                { Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Public' -CertificateFilePath $certificateFilePath } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountCertificate -Times 1
                Assert-MockCalled Set-AzIntegrationAccountCertificate -Times 1
                Assert-MockCalled New-AzIntegrationAccountCertificate -Times 0
            }
            It "Providing only a certificatesFolder to create public certificates is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $certificatesFolder = "$PSScriptRoot\Files\IntegrationAccount\Certificates\"

                Mock Get-ChildItem {
                    return @(
                        New-Item -Name "certificate1.cer" -Type File -fo
                        New-Item -Name "certificate2.cer" -Type File -fo
                    )
                }
                
                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountCertificate {
                    return $null
                } -Verifiable

                Mock Set-AzIntegrationAccountCertificate {
                    return $null
                }

                Mock New-AzIntegrationAccountCertificate {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.cer'; Type = 'Microsoft.Logic/integrationAccounts/certificates'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                # Act
                { Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Public' -CertificatesFolder $certificatesFolder } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountCertificate -Times 2
                Assert-MockCalled Set-AzIntegrationAccountCertificate -Times 0
                Assert-MockCalled New-AzIntegrationAccountCertificate -Times 2
            }
            It "Providing only a certificatesFolder to update public certificates is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $certificatesFolder = "$PSScriptRoot\Files\IntegrationAccount\Certificates\"

                Mock Get-ChildItem {
                    return @(
                        New-Item -Name "certificate1.cer" -Type File -fo
                        New-Item -Name "certificate2.cer" -Type File -fo
                    )
                }
                
                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountCertificate {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.cer'; Type = 'Microsoft.Logic/integrationAccounts/certificates'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                } -Verifiable

                Mock Set-AzIntegrationAccountCertificate {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.cer'; Type = 'Microsoft.Logic/integrationAccounts/certificates'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                Mock New-AzIntegrationAccountCertificate {
                    return $null
                }

                # Act
                { Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Public' -CertificatesFolder $certificatesFolder } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountCertificate -Times 2
                Assert-MockCalled Set-AzIntegrationAccountCertificate -Times 2
                Assert-MockCalled New-AzIntegrationAccountCertificate -Times 0
            }
            It "Providing only the certificateFilePath to create a private certificate is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $certificateName = 'Dummy_New_Certificate'
                $certificateResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/certificates/$certificateName"
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\$certificateName.cer"
                $keyName = "privateKey"
                $keyVersion = "1"
                $keyVaultName = "vault"
                $keyVaultId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountCertificate {
                    return $null
                } -Verifiable

                Mock Set-AzIntegrationAccountCertificate {
                    return $null
                }

                Mock New-AzIntegrationAccountCertificate {
                    return [pscustomobject]@{ Id = $certificateResourceId; Name = $certificateName; Type = 'Microsoft.Logic/integrationAccounts/certificates'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                # Act
                { Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Private' -CertificateFilePath $certificateFilePath -KeyName $keyName -KeyVersion $keyVersion -KeyVaultId $keyVaultId } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountCertificate -Times 1
                Assert-MockCalled Set-AzIntegrationAccountCertificate -Times 0
                Assert-MockCalled New-AzIntegrationAccountCertificate -Times 1
            }
            It "Providing only the certificateFilePath to update a private certificate is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $certificateName = 'Dummy_Existing_Certificate'
                $certificateResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/certificates/$certificateName"
                $certificateFilePath = "$PSScriptRoot\Files\IntegrationAccount\Certificates\$certificateName.cer"
                $keyName = "privateKey"
                $keyVersion = "1"
                $keyVaultName = "vault"
                $keyVaultId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountCertificate {
                    return [pscustomobject]@{ Id = $certificateResourceId; Name = $certificateName; Type = 'Microsoft.Logic/integrationAccounts/certificates'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                } -Verifiable

                Mock Set-AzIntegrationAccountCertificate {
                    return [pscustomobject]@{ Id = $certificateResourceId; Name = $certificateName; Type = 'Microsoft.Logic/integrationAccounts/certificates'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                Mock New-AzIntegrationAccountCertificate {
                    return $null
                }

                # Act
                { Set-AzIntegrationAccountCertificates -ResourceGroupName $resourceGroupName -Name $integrationAccountName -CertificateType 'Public' -CertificateFilePath $certificateFilePath -KeyName $keyName -KeyVersion $keyVersion -KeyVaultId $keyVaultId } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountCertificate -Times 1
                Assert-MockCalled Set-AzIntegrationAccountCertificate -Times 1
                Assert-MockCalled New-AzIntegrationAccountCertificate -Times 0
            }
        }
        Context "Azure Integration Account Partners" {
            It "Providing both partnerFilePath and partnersFolder should fail" {
                # Arrange
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $partnerFilePath = "$PSScriptRoot\Files\IntegrationAccount\Partners\Partner1.json"
                $partnersFolder = "$PSScriptRoot\Files\IntegrationAccount\Partners\"

                # Act
                { 
                    Set-AzIntegrationAccountPartners -ResourceGroupName $resourceGroupName -Name $integrationAccountName -PartnerFilePath $partnerFilePath -PartnersFolder $partnersFolder
                } | Should -Throw -ExpectedMessage "Either the file path of a specific partner or the file path of a folder containing multiple partners is required, e.g.: -PartnerFilePath 'C:\Partners\partner.json' or -PartnersFolder 'C:\Partners'"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing neither a partnerFilePath and partnersFolder should fail" {
                # Arrange
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"

                # Act
                { 
                    Set-AzIntegrationAccountPartners -ResourceGroupName $resourceGroupName -Name $integrationAccountName
                } | Should -Throw -ExpectedMessage "Either the file path of a specific partner or the file path of a folder containing multiple partners is required, e.g.: -PartnerFilePath 'C:\Partners\partner.json' or -PartnersFolder 'C:\Partners'"

                # Assert
                Assert-VerifiableMock
            }
            It "Not Providing a PartnerName should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $partnerName = 'Dummy_New_Partner'
                $partnerResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/partners/$partnerName"
                $partnerFilePath = "$PSScriptRoot\Files\IntegrationAccount\Partners\$partnerName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        properties = [pscustomobject] @{
                            partnerType = 'B2B';
                            content     = [pscustomobject] @{
                                b2b = [pscustomobject] @{
                                    businessIdentities = [pscustomobject] @{
                                        qualifier = '1';
                                        value     = '12345';
                                    }
                                }
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                # Act
                { 
                    Set-AzIntegrationAccountPartners -ResourceGroupName $resourceGroupName -Name $integrationAccountName -PartnerFilePath $partnerFilePath
                } | Should -Throw -ExpectedMessage "Cannot upload Partner to Azure Integration Account '$integrationAccountName' because the partner name is empty"

                # Assert
                Assert-VerifiableMock
            }
            It "Not Providing a BusinessIdentity should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $partnerName = 'Dummy_New_Partner'
                $partnerResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/partners/$partnerName"
                $partnerFilePath = "$PSScriptRoot\Files\IntegrationAccount\Partners\$partnerName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        name = 'Partner1';
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                # Act
                { 
                    Set-AzIntegrationAccountPartners -ResourceGroupName $resourceGroupName -Name $integrationAccountName -PartnerFilePath $partnerFilePath
                } | Should -Throw -ExpectedMessage "Cannot upload Partner to Azure Integration Account '$integrationAccountName' because at least one business identity must be supplied"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing only the partnerFilePath to create an partner is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $partnerName = 'Dummy_New_Partner'
                $partnerResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/partners/$partnerName"
                $partnerFilePath = "$PSScriptRoot\Files\IntegrationAccount\Partners\$partnerName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = 'Partner1';
                        properties = [pscustomobject] @{
                            partnerType = 'B2B';
                            content     = [pscustomobject] @{
                                b2b = [pscustomobject] @{
                                    businessIdentities = [pscustomobject] @{
                                        qualifier = '1';
                                        value     = '12345';
                                    }
                                }
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable
                
                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountPartner {
                    return $null
                } -Verifiable

                Mock Set-AzIntegrationAccountPartner {
                    return $null
                }

                Mock New-AzIntegrationAccountPartner {
                    return [pscustomobject]@{ Id = $partnerResourceId; Name = $partnerName; Type = 'Microsoft.Logic/integrationAccounts/partners'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                # Act
                { Set-AzIntegrationAccountPartners -ResourceGroupName $resourceGroupName -Name $integrationAccountName -PartnerFilePath $partnerFilePath } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountPartner -Times 1
                Assert-MockCalled Set-AzIntegrationAccountPartner -Times 0
                Assert-MockCalled New-AzIntegrationAccountPartner -Times 1
            }
            It "Providing only the partnerFilePath to update an partner is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $partnerName = 'Dummy_Existing_Partner'
                $partnerResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/partners/$partnerName"
                $partnerFilePath = "$PSScriptRoot\Files\IntegrationAccount\Partners\$partnerName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = 'Partner1';
                        properties = [pscustomobject] @{
                            partnerType = 'B2B';
                            content     = [pscustomobject] @{
                                b2b = [pscustomobject] @{
                                    businessIdentities = [pscustomobject] @{
                                        qualifier = '1';
                                        value     = '12345';
                                    }
                                }
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountPartner {
                    return [pscustomobject]@{ Id = $partnerResourceId; Name = $partnerName; Type = 'Microsoft.Logic/integrationAccounts/partners'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                } -Verifiable

                Mock Set-AzIntegrationAccountPartner {
                    return [pscustomobject]@{ Id = $partnerResourceId; Name = $partnerName; Type = 'Microsoft.Logic/integrationAccounts/partners'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                Mock New-AzIntegrationAccountPartner {
                    return $null
                }

                # Act
                { Set-AzIntegrationAccountPartners -ResourceGroupName $resourceGroupName -Name $integrationAccountName -PartnerFilePath $partnerFilePath } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountPartner -Times 1
                Assert-MockCalled Set-AzIntegrationAccountPartner -Times 1
                Assert-MockCalled New-AzIntegrationAccountPartner -Times 0
            }
            It "Providing only a partnersFolder to create partners is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $partnersFolder = "$PSScriptRoot\Files\IntegrationAccount\Partners\"

                Mock Get-ChildItem {
                    return @(
                        New-Item -Name "partner1.json" -Type File -fo
                        New-Item -Name "partner2.json" -Type File -fo
                    )
                }
                
                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = 'Partner1';
                        properties = [pscustomobject] @{
                            partnerType = 'B2B';
                            content     = [pscustomobject] @{
                                b2b = [pscustomobject] @{
                                    businessIdentities = [pscustomobject] @{
                                        qualifier = '1';
                                        value     = '12345';
                                    }
                                }
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountPartner {
                    return $null
                } -Verifiable

                Mock Set-AzIntegrationAccountPartner {
                    return $null
                }

                Mock New-AzIntegrationAccountPartner {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.dll'; Type = 'Microsoft.Logic/integrationAccounts/partners'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                # Act
                { Set-AzIntegrationAccountPartners -ResourceGroupName $resourceGroupName -Name $integrationAccountName -PartnersFolder $partnersFolder } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountPartner -Times 2
                Assert-MockCalled Set-AzIntegrationAccountPartner -Times 0
                Assert-MockCalled New-AzIntegrationAccountPartner -Times 2
            }
            It "Providing only a partnersFolder to update partners is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $partnersFolder = "$PSScriptRoot\Files\IntegrationAccount\Partners\"

                Mock Get-ChildItem {
                    return @(
                        New-Item -Name "partner1.json" -Type File -fo
                        New-Item -Name "partner2.json" -Type File -fo
                    )
                }

                Mock Get-Content {
                    return [PSCustomObject] @{
                        name       = 'Partner1';
                        properties = [PSCustomObject] @{
                            partnerType = 'B2B';
                            content     = [PSCustomObject] @{
                                b2b = [PSCustomObject] @{
                                    businessIdentities = [PSCustomObject] @{
                                        qualifier = '1';
                                        value     = '12345';
                                    }
                                }
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable
                
                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountPartner {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.dll'; Type = 'Microsoft.Logic/integrationAccounts/partners'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                } -Verifiable

                Mock Set-AzIntegrationAccountPartner {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'Dummy.dll'; Type = 'Microsoft.Logic/integrationAccounts/partners'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                Mock New-AzIntegrationAccountPartner {
                    return $null
                }

                # Act
                { Set-AzIntegrationAccountPartners -ResourceGroupName $resourceGroupName -Name $integrationAccountName -PartnersFolder $partnersFolder } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountPartner -Times 2
                Assert-MockCalled Set-AzIntegrationAccountPartner -Times 2
                Assert-MockCalled New-AzIntegrationAccountPartner -Times 0
            }
        }
        Context "Azure Integration Account Agreements" {
            It "Providing both agreementFilePath and agreementsFolder should fail" {
                # Arrange
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\Agreement1.json"
                $agreementsFolder = "$PSScriptRoot\Files\IntegrationAccount\Agreements\"

                # Act
                { 
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreementFilePath -AgreementsFolder $agreementsFolder
                } | Should -Throw -ExpectedMessage "Either the file path of a specific agreement or the file path of a folder containing multiple agreements is required, e.g.: -AgreementFilePath 'C:\Agreements\agreement.json' or -AgreementsFolder 'C:\Agreements'"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing neither a agreementFilePath and agreementsFolder should fail" {
                # Arrange
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"

                # Act
                { 
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName
                } | Should -Throw -ExpectedMessage "Either the file path of a specific agreement or the file path of a folder containing multiple agreements is required, e.g.: -AgreementFilePath 'C:\Agreements\agreement.json' or -AgreementsFolder 'C:\Agreements'"

                # Assert
                Assert-VerifiableMock
            }
            It "Not Providing an Agreement Name should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $agreementName = 'Dummy_New_Agreement'
                $agreementResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/agreements/$agreementName"
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\$agreementName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        properties = [pscustomobject] @{
                            agreementType = 'AS2';
                            hostPartner   = 'Partner1';
                            guestPartner  = 'Partner2';
                            hostIdentity  = [pscustomobject] @{
                                qualifier = '1';
                                value     = '12345';
                            }
                            guestIdentity = [pscustomobject] @{
                                qualifier = '1';
                                value     = '98765';
                            }
                            content       = [pscustomobject] @{
                                aS2 = [pscustomobject] @{}
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                # Act
                { 
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreementFilePath
                } | Should -Throw -ExpectedMessage "Cannot upload Agreement to Azure Integration Account '$integrationAccountName' because the agreement name is empty"

                # Assert
                Assert-VerifiableMock
            }
            It "Not Providing an Agreement Type should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $agreementName = 'Dummy_New_Agreement'
                $agreementResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/agreements/$agreementName"
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\$agreementName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = $agreementName;
                        properties = [pscustomobject] @{
                            hostPartner   = 'Partner1';
                            guestPartner  = 'Partner2';
                            hostIdentity  = [pscustomobject] @{
                                qualifier = '1';
                                value     = '12345';
                            }
                            guestIdentity = [pscustomobject] @{
                                qualifier = '1';
                                value     = '98765';
                            }
                            content       = [pscustomobject] @{
                                aS2 = [pscustomobject] @{}
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                # Act
                { 
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreementFilePath
                } | Should -Throw -ExpectedMessage "Cannot upload Agreement to Azure Integration Account '$integrationAccountName' because the agreement type is empty"

                # Assert
                Assert-VerifiableMock
            }
            It "Not Providing an Host Partner should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $agreementName = 'Dummy_New_Agreement'
                $agreementResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/agreements/$agreementName"
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\$agreementName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = $agreementName;
                        properties = [pscustomobject] @{
                            agreementType = 'AS2';
                            guestPartner  = 'Partner2';
                            hostIdentity  = [pscustomobject] @{
                                qualifier = '1';
                                value     = '12345';
                            }
                            guestIdentity = [pscustomobject] @{
                                qualifier = '1';
                                value     = '98765';
                            }
                            content       = [pscustomobject] @{
                                aS2 = [pscustomobject] @{}
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                # Act
                { 
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreementFilePath
                } | Should -Throw -ExpectedMessage "Cannot upload Agreement to Azure Integration Account '$integrationAccountName' because the host partner is empty"

                # Assert
                Assert-VerifiableMock
            }
            It "Not Providing an Host Identity Qualifier should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $agreementName = 'Dummy_New_Agreement'
                $agreementResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/agreements/$agreementName"
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\$agreementName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = $agreementName;
                        properties = [pscustomobject] @{
                            agreementType = 'AS2';
                            hostPartner   = 'Partner1';
                            guestPartner  = 'Partner2';
                            hostIdentity  = [pscustomobject] @{
                                value = '12345';
                            }
                            guestIdentity = [pscustomobject] @{
                                qualifier = '1';
                                value     = '98765';
                            }
                            content       = [pscustomobject] @{
                                aS2 = [pscustomobject] @{}
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                # Act
                { 
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreementFilePath
                } | Should -Throw -ExpectedMessage "Cannot upload Agreement to Azure Integration Account '$integrationAccountName' because the host identity qualifier is empty"

                # Assert
                Assert-VerifiableMock
            }
            It "Not Providing an Host Identity Value should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $agreementName = 'Dummy_New_Agreement'
                $agreementResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/agreements/$agreementName"
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\$agreementName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = $agreementName;
                        properties = [pscustomobject] @{
                            agreementType = 'AS2';
                            hostPartner   = 'Partner1';
                            guestPartner  = 'Partner2';
                            hostIdentity  = [pscustomobject] @{
                                qualifier = '1';
                            }
                            guestIdentity = [pscustomobject] @{
                                qualifier = '1';
                                value     = '98765';
                            }
                            content       = [pscustomobject] @{
                                aS2 = [pscustomobject] @{}
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                # Act
                { 
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreementFilePath
                } | Should -Throw -ExpectedMessage "Cannot upload Agreement to Azure Integration Account '$integrationAccountName' because the host identity value is empty"

                # Assert
                Assert-VerifiableMock
            }
            It "Not Providing an Guest Partner should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $agreementName = 'Dummy_New_Agreement'
                $agreementResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/agreements/$agreementName"
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\$agreementName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = $agreementName;
                        properties = [pscustomobject] @{
                            agreementType = 'AS2';
                            hostPartner   = 'Partner1';
                            hostIdentity  = [pscustomobject] @{
                                qualifier = '1';
                                value     = '12345';
                            }
                            guestIdentity = [pscustomobject] @{
                                qualifier = '1';
                                value     = '98765';
                            }
                            content       = [pscustomobject] @{
                                aS2 = [pscustomobject] @{}
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                # Act
                { 
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreementFilePath
                } | Should -Throw -ExpectedMessage "Cannot upload Agreement to Azure Integration Account '$integrationAccountName' because the guest partner is empty"

                # Assert
                Assert-VerifiableMock
            }
            It "Not Providing an Guest Identity Qualifier should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $agreementName = 'Dummy_New_Agreement'
                $agreementResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/agreements/$agreementName"
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\$agreementName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = $agreementName;
                        properties = [pscustomobject] @{
                            agreementType = 'AS2';
                            hostPartner   = 'Partner1';
                            guestPartner  = 'Partner2';
                            hostIdentity  = [pscustomobject] @{
                                qualifier = '1';
                                value     = '12345';
                            }
                            guestIdentity = [pscustomobject] @{
                                value = '98765';
                            }
                            content       = [pscustomobject] @{
                                aS2 = [pscustomobject] @{}
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                # Act
                { 
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreementFilePath
                } | Should -Throw -ExpectedMessage "Cannot upload Agreement to Azure Integration Account '$integrationAccountName' because the guest identity qualifier is empty"

                # Assert
                Assert-VerifiableMock
            }
            It "Not Providing an Guest Identity Value should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $agreementName = 'Dummy_New_Agreement'
                $agreementResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/agreements/$agreementName"
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\$agreementName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = $agreementName;
                        properties = [pscustomobject] @{
                            agreementType = 'AS2';
                            hostPartner   = 'Partner1';
                            guestPartner  = 'Partner2';
                            hostIdentity  = [pscustomobject] @{
                                qualifier = '1';
                                value     = '12345';
                            }
                            guestIdentity = [pscustomobject] @{
                                qualifier = '1';
                            }
                            content       = [pscustomobject] @{
                                aS2 = [pscustomobject] @{}
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                # Act
                { 
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreementFilePath
                } | Should -Throw -ExpectedMessage "Cannot upload Agreement to Azure Integration Account '$integrationAccountName' because the guest identity value is empty"

                # Assert
                Assert-VerifiableMock
            }
            It "Not Providing an Agreement Content should fail" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $agreementName = 'Dummy_New_Agreement'
                $agreementResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/agreements/$agreementName"
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\$agreementName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = $agreementName;
                        properties = [pscustomobject] @{
                            agreementType = 'AS2';
                            hostPartner   = 'Partner1';
                            guestPartner  = 'Partner2';
                            hostIdentity  = [pscustomobject] @{
                                qualifier = '1';
                                value     = '12345';
                            }
                            guestIdentity = [pscustomobject] @{
                                qualifier = '1';
                                value     = '98765';
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                # Act
                { 
                    Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreementFilePath
                } | Should -Throw -ExpectedMessage "Cannot upload Agreement to Azure Integration Account '$integrationAccountName' because the agreement content is empty"

                # Assert
                Assert-VerifiableMock
            }
            It "Providing only the agreementFilePath to create an agreement is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $agreementName = 'Dummy_New_Agreement'
                $agreementResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/agreements/$agreementName"
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\$agreementName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = 'Agreement';
                        properties = [pscustomobject] @{
                            hostPartner   = 'Partner1';
                            guestPartner  = 'Partner2';
                            hostIdentity  = [pscustomobject] @{
                                qualifier = '1';
                                value     = '12345';
                            }
                            guestIdentity = [pscustomobject] @{
                                qualifier = '1';
                                value     = '98765';
                            }
                            agreementType = 'AS2';
                            content       = [pscustomobject] @{
                                aS2 = [pscustomobject] @{}
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable
                
                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountAgreement {
                    return $null
                } -Verifiable

                Mock Set-AzIntegrationAccountAgreement {
                    return $null
                }

                Mock New-AzIntegrationAccountAgreement {
                    return [pscustomobject]@{ Id = $agreementResourceId; Name = $agreementName; Type = 'Microsoft.Logic/integrationAccounts/agreements'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                # Act
                { Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreementFilePath } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountAgreement -Times 1
                Assert-MockCalled Set-AzIntegrationAccountAgreement -Times 0
                Assert-MockCalled New-AzIntegrationAccountAgreement -Times 1
            }
            It "Providing only the agreementFilePath to update an agreement is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $agreementName = 'Dummy_Existing_Agreement'
                $agreementResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/agreements/$agreementName"
                $agreementFilePath = "$PSScriptRoot\Files\IntegrationAccount\Agreements\$agreementName.json"

                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = 'Agreement';
                        properties = [pscustomobject] @{
                            hostPartner   = 'Partner1';
                            guestPartner  = 'Partner2';
                            hostIdentity  = [pscustomobject] @{
                                qualifier = '1';
                                value     = '12345';
                            }
                            guestIdentity = [pscustomobject] @{
                                qualifier = '1';
                                value     = '98765';
                            }
                            agreementType = 'AS2';
                            content       = [pscustomobject] @{
                                aS2 = [pscustomobject] @{}
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountAgreement {
                    return [pscustomobject]@{ Id = $agreementResourceId; Name = $agreementName; Type = 'Microsoft.Logic/integrationAccounts/agreements'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                } -Verifiable

                Mock Set-AzIntegrationAccountAgreement {
                    return [pscustomobject]@{ Id = $agreementResourceId; Name = $agreementName; Type = 'Microsoft.Logic/integrationAccounts/agreements'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                Mock New-AzIntegrationAccountAgreement {
                    return $null
                }

                # Act
                { Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementFilePath $agreementFilePath } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountAgreement -Times 1
                Assert-MockCalled Set-AzIntegrationAccountAgreement -Times 1
                Assert-MockCalled New-AzIntegrationAccountAgreement -Times 0
            }
            It "Providing only a agreementsFolder to create agreements is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $agreementsFolder = "$PSScriptRoot\Files\IntegrationAccount\Agreements\"

                Mock Get-ChildItem {
                    return @(
                        New-Item -Name "agreement1.json" -Type File -fo
                        New-Item -Name "agreement2.json" -Type File -fo
                    )
                }
                
                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = 'Agreement';
                        properties = [pscustomobject] @{
                            hostPartner   = 'Partner1';
                            guestPartner  = 'Partner2';
                            hostIdentity  = [pscustomobject] @{
                                qualifier = '1';
                                value     = '12345';
                            }
                            guestIdentity = [pscustomobject] @{
                                qualifier = '1';
                                value     = '98765';
                            }
                            agreementType = 'AS2';
                            content       = [pscustomobject] @{
                                aS2 = [pscustomobject] @{}
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable

                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountAgreement {
                    return $null
                } -Verifiable

                Mock Set-AzIntegrationAccountAgreement {
                    return $null
                }

                Mock New-AzIntegrationAccountAgreement {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'DummyAgreement'; Type = 'Microsoft.Logic/integrationAccounts/agreements'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                # Act
                { Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementsFolder $agreementsFolder } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountAgreement -Times 2
                Assert-MockCalled Set-AzIntegrationAccountAgreement -Times 0
                Assert-MockCalled New-AzIntegrationAccountAgreement -Times 2
            }
            It "Providing only a agreementsFolder to update agreements is OK" {
                # Arrange
                $subscriptionId = [guid]::NewGuid()
                $resourceGroupName = "rg-infrastructure"
                $integrationAccountName = "unexisting-integration-account"
                $integrationAccountResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName"
                $agreementsFolder = "$PSScriptRoot\Files\IntegrationAccount\Agreements\"

                Mock Get-ChildItem {
                    return @(
                        New-Item -Name "agreement1.json" -Type File -fo
                        New-Item -Name "agreement2.json" -Type File -fo
                    )
                }

                Mock Get-Content {
                    return [pscustomobject] @{
                        name       = 'Agreement';
                        properties = [pscustomobject] @{
                            hostPartner   = 'Partner1';
                            guestPartner  = 'Partner2';
                            hostIdentity  = [pscustomobject] @{
                                qualifier = '1';
                                value     = '12345';
                            }
                            guestIdentity = [pscustomobject] @{
                                qualifier = '1';
                                value     = '98765';
                            }
                            agreementType = 'AS2';
                            content       = [pscustomobject] @{
                                aS2 = [pscustomobject] @{}
                            }
                        }
                    } | ConvertTo-Json -Depth 5;
                } -Verifiable
                
                Mock Get-AzIntegrationAccount {
                    return [pscustomobject]@{ Id = $integrationAccountResourceId; Name = $integrationAccountName; Type = 'Microsoft.Logic/integrationAccounts'; Location = 'westeurope'; Sku = 'Free' }
                } -Verifiable

                Mock Get-AzIntegrationAccountAgreement {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'DummyAgreement'; Type = 'Microsoft.Logic/integrationAccounts/agreements'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                } -Verifiable

                Mock Set-AzIntegrationAccountAgreement {
                    return [pscustomobject]@{ Id = 'fake-resource-id'; Name = 'DummyAgreement'; Type = 'Microsoft.Logic/integrationAccounts/agreements'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
                }

                Mock New-AzIntegrationAccountAgreement {
                    return $null
                }

                # Act
                { Set-AzIntegrationAccountAgreements -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AgreementsFolder $agreementsFolder } | 
                Should -Not -Throw
 
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzIntegrationAccount -Times 1
                Assert-MockCalled Get-AzIntegrationAccountAgreement -Times 2
                Assert-MockCalled Set-AzIntegrationAccountAgreement -Times 2
                Assert-MockCalled New-AzIntegrationAccountAgreement -Times 0
            }
        }
    }
}