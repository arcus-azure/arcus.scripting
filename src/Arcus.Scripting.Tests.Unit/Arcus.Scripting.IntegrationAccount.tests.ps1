﻿Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.IntegrationAccount -ErrorAction Stop

InModuleScope Arcus.Scripting.IntegrationAccount {
    Describe "Arcus" {
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
                        new-item -name "Schema1.xsd" -type file -fo
                        new-item -name "Schema2.xsd" -type file -fo
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

                # Act
                { 
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemasFolder $schemasFolder
                 } | Should -Not -Throw
 
                 # Assert
                 Assert-VerifiableMock
                 Assert-MockCalled Get-AzIntegrationAccount -Times 1
                 Assert-MockCalled Get-AzIntegrationAccountSchema -Times 2
                 Assert-MockCalled Set-AzIntegrationAccountSchema -Times 0
                 Assert-MockCalled New-AzIntegrationAccountSchema -Times 2
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
                        new-item -name "Schema1.xsd" -type file -fo
                        new-item -name "Schema2.xsd" -type file -fo
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

                # Act
                { 
                    Set-AzIntegrationAccountSchemas -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemasFolder $schemasFolder
                 } | Should -Not -Throw
 
                 # Assert
                 Assert-VerifiableMock
                 Assert-MockCalled Get-AzIntegrationAccount -Times 1
                 Assert-MockCalled Get-AzIntegrationAccountSchema -Times 2
                 Assert-MockCalled Set-AzIntegrationAccountSchema -Times 2
                 Assert-MockCalled New-AzIntegrationAccountSchema -Times 0
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
				$mapName = 'Dummy_New_Map'
                $mapResourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Logic/integrationAccounts/$integrationAccountName/maps/$schemaName"
				$mapFilePath = "$PSScriptRoot\Files\IntegrationAccount\Maps\$mapName.xslt"

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
                    return [pscustomobject]@{ Id = $mapResourceId; Name = $mapName; Type = 'Microsoft.Logic/integrationAccounts/maps'; MapType = 'Xslt'; CreatedTime = [datetime]::UtcNow; ChangedTime = [datetime]::UtcNow }
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
				$mapName = 'Dummy_Existing_Map'
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
                        new-item -name "map1.xslt" -type file -fo
                        new-item -name "Map2.xslt" -type file -fo
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

                # Act
                { 
                    Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapsFolder $mapsFolder
                 } | Should -Not -Throw
 
                 # Assert
                 Assert-VerifiableMock
                 Assert-MockCalled Get-AzIntegrationAccount -Times 1
                 Assert-MockCalled Get-AzIntegrationAccountMap -Times 2
                 Assert-MockCalled Set-AzIntegrationAccountMap -Times 0
                 Assert-MockCalled New-AzIntegrationAccountMap -Times 2
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
                        new-item -name "Map1.xslt" -type file -fo
                        new-item -name "Map2.xslt" -type file -fo
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

                # Act
                { 
                    Set-AzIntegrationAccountMaps -ResourceGroupName $resourceGroupName -Name $integrationAccountName -MapsFolder $mapsFolder
                 } | Should -Not -Throw
 
                 # Assert
                 Assert-VerifiableMock
                 Assert-MockCalled Get-AzIntegrationAccount -Times 1
                 Assert-MockCalled Get-AzIntegrationAccountMap -Times 2
                 Assert-MockCalled Set-AzIntegrationAccountMap -Times 2
                 Assert-MockCalled New-AzIntegrationAccountMap -Times 0
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
                { 
                    Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssemblyFilePath $assemblyFilePath
                 } | Should -Not -Throw
 
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
                { 
                    Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssemblyFilePath $assemblyFilePath
                 } | Should -Not -Throw
 
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
                { 
                    Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssembliesFolder $assembliesFolder
                 } | Should -Not -Throw
 
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
                { 
                    Set-AzIntegrationAccountAssemblies -ResourceGroupName $resourceGroupName -Name $integrationAccountName -AssembliesFolder $assembliesFolder
                 } | Should -Not -Throw
 
                 # Assert
                 Assert-VerifiableMock
                 Assert-MockCalled Get-AzIntegrationAccount -Times 1
                 Assert-MockCalled Get-AzIntegrationAccountAssembly -Times 2
                 Assert-MockCalled Set-AzIntegrationAccountAssembly -Times 2
                 Assert-MockCalled New-AzIntegrationAccountAssembly -Times 0
            }
        }
    }
}
