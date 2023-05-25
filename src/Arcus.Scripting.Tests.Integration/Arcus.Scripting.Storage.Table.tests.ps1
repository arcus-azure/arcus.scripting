Import-Module Az.Storage
Import-Module AzTable
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Storage.Table -ErrorAction Stop

function global:Retry-Func ($scriptBlock) {
    $success = $false
    while ($success -eq $false) {
        $currentErrorCount = $Error.Count
        . $scriptBlock

        if ($Error.Count -eq $currentErrorCount) {
            $success = $true
        } else {
            Start-Sleep -Seconds 3
        }
    }
}

InModuleScope Arcus.Scripting.Storage.Table {
    Describe "Azure Arcus Table storage integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
        }
        Context "Create Azure table storage table" {
            It "Create an new Azure table within an Azure storage account" {
                # Arrange
                $tableName = "arcusnewtable"
                $storageAccount = Get-AzStorageAccount -ResourceGroupName $config.Arcus.ResourceGroupName -Name $config.Arcus.Storage.StorageAccount.Name
                try {
                    # Act
                    Create-AzStorageTable `
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
            It "Re-creates a new Azure table within an Azure storage account" {
                # Arrange
                $tableName = "arcusalreadyexistingtable"
                try {
                    $storageAccount = Get-AzStorageAccount -ResourceGroupName $config.Arcus.ResourceGroupName -Name $config.Arcus.Storage.StorageAccount.Name
                    Retry-Func { New-AzStorageTable -Name $tableName -Context $storageAccount.Context -ErrorAction SilentlyContinue }
                    $storageTable = Get-AzStorageTable –Name $tableName –Context $storageAccount.Context
                    $partitionKey = "arcus-azure-resources"
                    Add-AzTableRow -Table $storageTable.CloudTable -PartitionKey $partitionKey -RowKey ("Scripting") -Property @{"Resource"="Table storage"}
                    Get-AzTableRow -Table $storageTable.CloudTable -PartitionKey $partitionKey |
                            Should -Not -Be $null

                    # Act
                    Create-AzStorageTable `
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
            It "Fails to re-create a new Azure table within an Azure storage account with not enough retry time" {
                # Arrange
                $tableName = "arcusfailedrecreatetable"
                try {
                    $storageAccount = Get-AzStorageAccount -ResourceGroupName $config.Arcus.ResourceGroupName -Name $config.Arcus.Storage.StorageAccount.Name
                    Retry-Func { New-AzStorageTable -Name $tableName -Context $storageAccount.Context -ErrorAction SilentlyContinue }

                    # Act
                    { Create-AzStorageTable `
                        -ResourceGroupName $config.Arcus.ResourceGroupName `
                        -StorageAccountName $config.Arcus.Storage.StorageAccount.Name `
                        -Table $tableName `
                        -Recreate `
                        -MaxRetryCount 2 } | Should -Throw
                } finally {
                    Remove-AzStorageTable -Name $tableName -Context $storageAccount.Context -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }
}
