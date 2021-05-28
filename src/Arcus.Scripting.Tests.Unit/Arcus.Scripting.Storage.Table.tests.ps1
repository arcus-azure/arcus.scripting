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
                    $Name | Should -Be $tableName
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
                    $Name | Should -Be $tableName
                    return [pscustomobject]@{} } -Verifiable
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
                    $Name | Should -Be $tableName
                    return [pscustomobject]@{} } -Verifiable
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
                    $Name | Should -Be $tableName
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
        }
    }
}
