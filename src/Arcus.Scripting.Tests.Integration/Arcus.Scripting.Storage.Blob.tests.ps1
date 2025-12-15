Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Storage.Blob -ErrorAction Stop

InModuleScope Arcus.Scripting.Storage.Blob {
    Describe "Arcus Azure Blob storage integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
        }
        Context "Upload files to Azure Blob storage" {
            It "Uploads files to existing Azure Blob storage resource" {
                try {
                    # Arrange
                    $targetFolderPath = "$PSScriptRoot\Blobs"
                    $containerName = "arcus-scripting-storage-container"
                    $storageAccount = Get-AzStorageAccount -ResourceGroupName $config.Arcus.ResourceGroupName -Name $config.Arcus.Storage.StorageAccount.Name
                    New-AzStorageContainer -Context $storageAccount.Context -Name $containerName -Permission Blob

                    # Act
                    Upload-AzFilesToBlobStorage `
                        -ResourceGroupName $config.Arcus.ResourceGroupName `
                        -StorageAccountName $config.Arcus.Storage.StorageAccount.Name `
                        -TargetFolderPath $targetFolderPath `
                        -ContainerName $containerName `
                        -ContainerPermissions "Blob"

                    # Assert
                    $blob = Get-AzStorageBlob -Container $containerName -Blob "arcus.png" -Context $storageAccount.Context
                    $blob | Should -Not -Be $null
                    $blob.IsDeleted | Should -Be $false
                } finally {
                    Remove-AzStorageContainer -Name $containerName -Context $storageAccount.Context -Force
                }
            }
            It "Uploads files to new Azure Blob storage resource" {
                try {
                    # Arrange
                    $targetFolderPath = "$PSScriptRoot\Blobs"
                    $containerName = "new-arcus-storage-container"
                    $storageAccount = Get-AzStorageAccount -ResourceGroupName $config.Arcus.ResourceGroupName -Name $config.Arcus.Storage.StorageAccount.Name

                    # Act
                    Upload-AzFilesToBlobStorage `
                        -ResourceGroupName $config.Arcus.ResourceGroupName `
                        -StorageAccountName $config.Arcus.Storage.StorageAccount.Name `
                        -TargetFolderPath $targetFolderPath `
                        -ContainerName $containerName `
                        -ContainerPermissions "Blob"

                    # Assert
                    $blob = Get-AzStorageBlob -Container $containerName -Blob "arcus.png" -Context $storageAccount.Context
                    $blob | Should -Not -Be $null
                    $blob.IsDeleted | Should -Be $false
                } finally {
                    Remove-AzStorageContainer -Name $containerName -Context $storageAccount.Context -Force
                }
            }
        }
    }
}

