using module Az
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.TableStorage -ErrorAction Stop

class StubCloudTable : Microsoft.WindowsAzure.Storage.Table.CloudTable {
	StubCloudTable ([string] $tableAddress) : base({New-Object -Type System.Uri -ArgumentList $tableAddress}) {
	}
	StubCloudTable ([System.Uri] $tableAddress) : base($tableAddress) { 
	}
	StubCloudTable ([Microsoft.WindowsAzure.Storage.StorageUri] $storageUri, [Microsoft.WindowsAzure.Storage.Auth.StorageCredentials] $storageCredentials) : base($storageUri, $storageCredentials) {
	}
	StubCloudTable ([System.Uri] $tableAbsoluteUri, [Microsoft.WindowsAzure.Storage.Auth.StorageCredentials] $storageCredentials) : base($storageAbsoluteUri, $storageCredentials) {
	}
	[System.Threading.Tasks.Task[Microsoft.WindowsAzure.Storage.Table.TableResult]] ExecuteAsync ([Microsoft.WindowsAzure.Storage.Table.TableOperation] $tableOperation) {
		return $null
	}
}

$cloudTable = New-Object -TypeName StubCloudTable -ArgumentList "https://some-table/"
$azTable = New-Object -TypeName Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageTable 

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

				

				Mock Get-AzStorageAccount {
					$ResourceGroupName | Should -Be $resourceGroup
					$Name | Should -Be $storageAccountName
					return $psStorageAccount } -Verifiable
				Mock Get-AzStorageTable {
					$Context | Should -Be $psStorageAccount.Context
					$Name | Should -Be $tableName
					return $azTable } -Verifiable
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
					return $azTable } -Verifiable
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