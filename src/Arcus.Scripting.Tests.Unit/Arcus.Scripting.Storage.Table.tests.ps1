Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Storage.Table -ErrorAction Stop

InModuleScope Arcus.Scripting.Storage.Table {
    Describe "Arcus Azure Table storage unit tests" {
        Context "Creating Azure Table storage" {
            It "Create w/o recreating non-existing table in Azure Table Storage on Azure Storage Account" {
                # Arrange
                $resourceGroup = "stock"
                $storageAccountName = "admin"
                $tableName = "products"
                $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
                $psStorageAccount = New-Object -TypeName Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount -ArgumentList $storageAccount

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable
                Mock Get-AzStorageTable {
                    $Context | Should -Be $psStorageAccount.Context
                    return $null } -Verifiable
                Mock New-AzStorageTable {
                    $Context | Should -Be $psStorageAccount.Context
                    $Name | Should -Be $tableName } -Verifiable
                Mock Remove-AzStorageTable { }

                # Act
                Create-AzStorageTable -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccount -Times 1
                Assert-MockCalled Get-AzStorageTable -Times 1
                Assert-MockCalled New-AzStorageTable -Times 1
                Assert-MockCalled Remove-AzStorageTable -Times 0
            }
            It "Create w/o recreating existing table in Azure Table Storage Azure Storage Account" {
                # Arrange
                $resourceGroup = "stock"
                $storageAccountName = "admin"
                $tableName = "products"
                $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
                $psStorageAccount = New-Object -TypeName Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount -ArgumentList $storageAccount

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable
                Mock Get-AzStorageTable {
                    $Context | Should -Be $psStorageAccount.Context
                    return @([pscustomobject]@{ Name = $tableName }) } -Verifiable
                Mock New-AzStorageTable { }
                Mock Remove-AzStorageTable { }

                # Act
                Create-AzStorageTable -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName

                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccount -Times 1
                Assert-MockCalled Get-AzStorageTable -Times 1
                Assert-MockCalled New-AzStorageTable -Times 0
                Assert-MockCalled Remove-AzStorageTable -Times 0
            }
            It "Create w/ recreating existing table in Azure Table Storage Azure Storage Account" {
                # Arrange
                $resourceGroup = "stock"
                $storageAccountName = "admin"
                $tableName = "products"
                $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
                $psStorageAccount = New-Object -TypeName Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount -ArgumentList $storageAccount

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable
                Mock Get-AzStorageTable {
                    $Context | Should -Be $psStorageAccount.Context
                    return [pscustomobject]@{ Name = $tableName } } -Verifiable
                Mock New-AzStorageTable {
                    $Context | Should -Be $psStorageAccount.Context
                    $Name | Should -Be $tableName } -Verifiable
                Mock Remove-AzStorageTable { 
                    $Context | Should -Be $psStorageAccount.Context
                    $Name | Should -Be $tableName } -Verifiable

                # Act
                Create-AzStorageTable -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName -Recreate

                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccount -Times 1
                Assert-MockCalled Get-AzStorageTable -Times 1
                Assert-MockCalled New-AzStorageTable -Times 1
                Assert-MockCalled Remove-AzStorageTable -Times 1
            }
            It "Create w/ recreating non-existing table in Azure Table Storage Azure Storage Account" {
                # Arrange
                $resourceGroup = "stock"
                $storageAccountName = "admin"
                $tableName = "products"
                $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
                $psStorageAccount = New-Object -TypeName Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount -ArgumentList $storageAccount

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable
                Mock Get-AzStorageTable {
                    $Context | Should -Be $psStorageAccount.Context
                    return $null } -Verifiable
                Mock New-AzStorageTable {
                    $Context | Should -Be $psStorageAccount.Context
                    $Name | Should -Be $tableName } -Verifiable
                Mock Remove-AzStorageTable { }

                # Act
                Create-AzStorageTable -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName -Recreate

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccount -Times 1
                Assert-MockCalled Get-AzStorageTable -Times 1
                Assert-MockCalled New-AzStorageTable -Times 1
                Assert-MockCalled Remove-AzStorageTable -Times 0
            }
            It "Create table with zero retry interval in seconds fails" {
                { Create-AzStorageTable -ResourceGroupName "stock" -StorageAccountName "admin" -TableName "products" -RetryIntervalInSeconds 0 } |
                    Should -Throw
            }
            It "Create table with less than zero retry interval in seconds fails" {
                { Create-AzStorageTable -ResourceGroupName "stock" -StorageAccountName "admin" -TableName "products" -RetryIntervalInSeconds -3 } |
                    Should -Throw
            }
            It "Create table with zero max retry-cycle count fails" {
                { Create-AzStorageTable -ResourceGroupName "stock" -StorageAccountName "admin" -TableName "products" -MaxRetryCount 0 } |
                    Should -Throw
            }
            It "Create table with less than zero max retry-cycle count fails" {
                { Create-AzStorageTable -ResourceGroupName "stock" -StorageAccountName "admin" -TableName "products" -MaxRetryCount -2 } |
                    Should -Throw
            }
        }
        Context "Setting Azure Table Storage Entities" {
            It "Setting entities in an Azure Table Storage account should succeed" {
                # Arrange
                $resourceGroup = "SomeResourceGroup"
                $storageAccountName = "SomeStorageAccountName"
                $tableName = "SomeTableName"
                $configFile = "$PSScriptRoot\Files\TableStorage\set-aztablestorageentities-config.json"
                $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
                $psStorageAccount = New-Object -TypeName Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount -ArgumentList $storageAccount

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable
                Mock Get-AzStorageTable {
                    $Context | Should -Be $psStorageAccount.Context
                    return @{
                        CloudTable = "123456"
                    } 
                } -Verifiable
                Mock Get-AzTableRow {} 
                Mock Remove-AzTableRow {} 
                Mock Add-AzTableRow {} 

                # Act
                Set-AzTableStorageEntities -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName -ConfigurationFile $configFile

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccount -Times 1
                Assert-MockCalled Get-AzStorageTable -Times 1
                Assert-MockCalled Get-AzTableRow -Times 1
                Assert-MockCalled Remove-AzTableRow -Times 0
                Assert-MockCalled Add-AzTableRow -Times 2
            }
            It "Setting entities in an Azure Table Storage account without PartitionKey and RowKey should succeed" {
                # Arrange
                $resourceGroup = "SomeResourceGroup"
                $storageAccountName = "SomeStorageAccountName"
                $tableName = "SomeTableName"
                $configFile = "$PSScriptRoot\Files\TableStorage\set-aztablestorageentities-config-nokeys.json"
                $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
                $psStorageAccount = New-Object -TypeName Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount -ArgumentList $storageAccount

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable
                Mock Get-AzStorageTable {
                    $Context | Should -Be $psStorageAccount.Context
                    return @{
                        CloudTable = "123456"
                    } 
                } -Verifiable
                Mock Get-AzTableRow {} 
                Mock Remove-AzTableRow {} 
                Mock Add-AzTableRow {} 

                # Act
                Set-AzTableStorageEntities -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName -ConfigurationFile $configFile

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccount -Times 1
                Assert-MockCalled Get-AzStorageTable -Times 1
                Assert-MockCalled Get-AzTableRow -Times 1
                Assert-MockCalled Remove-AzTableRow -Times 0
                Assert-MockCalled Add-AzTableRow -Times 2
            }
            It "Setting entities in an Azure Table Storage account with a storage account that does not exist fails" {
                # Arrange
                $resourceGroup = "SomeResourceGroup"
                $storageAccountName = "SomeStorageAccountName"
                $tableName = "SomeTableName"
                $configFile = "$PSScriptRoot\Files\TableStorage\set-aztablestorageentities-config.json"
                $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
                $psStorageAccount = New-Object -TypeName Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount -ArgumentList $storageAccount

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $null } -Verifiable

                # Act
                { Set-AzTableStorageEntities -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName -ConfigurationFile $configFile } |
                    Should -Throw -ExpectedMessage "Retrieving Azure storage account context for Azure storage account '$storageAccountName' in resource group '$resourceGroup' failed."

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccount -Times 1
            }
            It "Setting entities in an Azure Table Storage account with a storage table that does not exist fails" {
                # Arrange
                $resourceGroup = "SomeResourceGroup"
                $storageAccountName = "SomeStorageAccountName"
                $tableName = "SomeTableName"
                $configFile = "$PSScriptRoot\Files\TableStorage\set-aztablestorageentities-config.json"
                $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
                $psStorageAccount = New-Object -TypeName Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount -ArgumentList $storageAccount

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable
                Mock Get-AzStorageTable {
                    $Context | Should -Be $psStorageAccount.Context
                    return $null
                } -Verifiable

                # Act
                { Set-AzTableStorageEntities -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName -ConfigurationFile $configFile } |
                    Should -Throw -ExpectedMessage "Retrieving Azure storage table '$tableName' for Azure storage account '$storageAccountName' in resource group '$resourceGroup' failed."

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccount -Times 1
                Assert-MockCalled Get-AzStorageTable -Times 1
            }
            It "Setting entities in an Azure Table Storage account with a config file that does not exist fails" {
                $resourceGroup = "SomeResourceGroup"
                $storageAccountName = "SomeStorageAccountName"
                $tableName = "SomeTableName"
                $configFile = ".\SomeFileThatDoesNotExist.json"

                { Set-AzTableStorageEntities -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName -ConfigurationFile $configFile } |
                    Should -Throw -ExpectedMessage "Cannot re-create entities based on JSON configuration file because no file was found at: '$configFile'"
            }
            It "Setting entities in an Azure Table Storage account with a config file that is empty fails" {
                $resourceGroup = "SomeResourceGroup"
                $storageAccountName = "SomeStorageAccountName"
                $tableName = "SomeTableName"
                $configFile = "$PSScriptRoot\Files\TableStorage\set-aztablestorageentities-config-empty.json"

                { Set-AzTableStorageEntities -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName -ConfigurationFile $configFile } |
                    Should -Throw -ExpectedMessage "Cannot re-create entities based on JSON configuration file because the file is empty."
            }
            It "Setting entities in an Azure Table Storage account with a config file that is not valid JSON fails" {
                $resourceGroup = "SomeResourceGroup"
                $storageAccountName = "SomeStorageAccountName"
                $tableName = "SomeTableName"
                $configFile = "$PSScriptRoot\Files\TableStorage\set-aztablestorageentities-config-invalid.json"

                { Set-AzTableStorageEntities -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName -ConfigurationFile $configFile } |
                    Should -Throw -ExpectedMessage "Cannot re-create entities based on JSON configuration file because the file does not contain valid JSON."
            }
        }
    }
}
