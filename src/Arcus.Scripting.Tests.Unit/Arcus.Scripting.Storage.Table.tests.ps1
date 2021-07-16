Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Storage.Table -ErrorAction Stop

Describe "Arcus" {
    Context "Table Storage" {
        InModuleScope Arcus.Scripting.Storage.Table {
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
    }
}
