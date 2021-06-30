Import-Module Az.Storage
Import-Module AzTable
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Storage.Table -ErrorAction Stop

InModuleScope Arcus.Scripting.Storage.Table {
    Describe "Azure Arcus Table storage integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1 -fileName "appsettings.json"
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
        }
        Context "Create Azure Table storage table" {
            It "Create an new Azure Table within an Azure storage account" {
                # Arrange
                $tableName = "arcusnewtable"
                $storageAccount = Get-AzStorageAccount -ResourceGroupName $config.Arcus.ResourceGroupName -Name $config.Arcus.Storage.StorageAccount.Name
                try {
                    # Act
                    Create-AzTableStorageAccountTable `
                        -ResourceGroupName $config.Arcus.ResourceGroupName `
                        -StorageAccountName $config.Arcus.Storage.StorageAccount.Name `
                        -Table $tableName

                    # Assert
                    $storageTable = Get-AzStorageTable -Name $tableName -Context $storageAccount.Context
                    $storageTable.Name | Should -Be $tableName
                } finally {
                    Remove-AzStorageTable -Name $tableName -Context $storageAccount.Context -Force
                }
            }
            It "Re-creates a new Azure Table within an Azure storage account" {
                # Arrange
                $tableName = "arcusalreadyexistingtable"
                try {
                    $storageAccount = Get-AzStorageAccount -ResourceGroupName $config.Arcus.ResourceGroupName -Name $config.Arcus.Storage.StorageAccount.Name
                    New-AzStorageTable -Name $tableName -Context $storageAccount.Context
                    $storageTable = Get-AzStorageTable –Name $tableName –Context $storageAccount.Context
                    $partitionKey = "arcus-azure-resources"
                    Add-AzTableRow -Table $storageTable.CloudTable -PartitionKey $partitionKey -RowKey ("Scripting") -Property @{"Resource"="Table storage"}
                    Get-AzTableRow -Table $storageTable.CloudTable -PartitionKey $partitionKey |
                            Should -Not -Be $null

                    # Act
                    Create-AzTableStorageAccountTable `
                        -ResourceGroupName $config.Arcus.ResourceGroupName `
                        -StorageAccountName $config.Arcus.Storage.StorageAccount.Name `
                        -Table $tableName `
                        -Recreate

                    # Assert
                    Get-AzTableRow -Table $storageTable.CloudTable -PartitionKey $partitionKey |
                        Should -Be $null
                    
                } finally {
                    Remove-AzStorageTable -Name $tableName -Context $storageAccount.Context -Force
                }
            }
        }
    }
}
