using module Az
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.TableStorage -ErrorAction Stop

Describe "Arcus" {
	Context "Table Storage" {
		InModuleScope Arcus.Scripting.TableStorage {
			It "Create w/o recreating non-existing table in Table Storage on Storage Account" {
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
				Create-AzTableStorageAccountTable -ResourceGroup $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName

				# Assert
				Assert-VerifiableMock
			    Assert-MockCalled Get-AzStorageAccount -Times 1
				Assert-MockCalled Get-AzStorageTable -Times 1
				Assert-MockCalled New-AzStorageTable -Times 1
				Assert-MockCalled Remove-AzStorageTable -Times 0
			}
			It "Create w/o recreating existing table in Table Storage Storage Account" {
				# Arrange
				$resourceGroup = "stock"
				$storageAccountName = "admin"
				$tableName = "products"
				$storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
				$psStorageAccount = New-Object -TypeName Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount -ArgumentList $storageAccount
				$azTable = New-MockObject -Type Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageTable

				Mock Get-AzStorageAccount {
					$ResourceGroupName | Should -Be $resourceGroup
					$Name | Should -Be $storageAccountName
					return $psStorageAccount } -Verifiable
				Mock Get-AzStorageTable {
					$Context | Should -Be $psStorageAccount.Context
					$Name | Should -Be $tableName
					return [pscustomobjec]@{} } -Verifiable
				Mock New-AzStorageTable {
					$Context | Should -Be $psStorageAccount.Context
					$Name | Should -Be $tableName } -Verifiable
				Mock Remove-AzStorageTable { }

				# Act
				Create-AzTableStorageAccountTable -ResourceGroup $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName

				Assert-VerifiableMock
			    Assert-MockCalled Get-AzStorageAccount -Times 1
				Assert-MockCalled Get-AzStorageTable -Times 1
				Assert-MockCalled New-AzStorageTable -Times 1
				Assert-MockCalled Remove-AzStorageTable -Times 0
			}
			It "Create w/ recreating existing table in Table Storage Storage Account" {
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
				Create-AzTableStorageAccountTable -ResourceGroup $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName -DeleteAndCreate

				Assert-VerifiableMock
			    Assert-MockCalled Get-AzStorageAccount -Times 1
				Assert-MockCalled Get-AzStorageTable -Times 1
				Assert-MockCalled New-AzStorageTable -Times 1
				Assert-MockCalled Remove-AzStorageTable -Times 1
			}
			It "Create w/ recreating non-existing table in Table Storage Storage Account" {
				# Arrange
				$resourceGroup = "stock"
				$storageAccountName = "admin"
				$tableName = "products"
				$storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
				$psStorageAccount = New-Object -TypeName Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount -ArgumentList $storageAccount
				$azTable = New-MockObject -Type Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageTable

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
				Create-AzTableStorageAccountTable -ResourceGroup $resourceGroup -StorageAccountName $storageAccountName -TableName $tableName -DeleteAndCreate

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
