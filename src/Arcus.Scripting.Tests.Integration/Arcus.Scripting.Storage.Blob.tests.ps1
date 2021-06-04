Import-Module Az.Storage
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Storage.Blob -ErrorAction Stop

InModuleScope Arcus.Scripting.Storage.Blob {
    Describe "Arcus Azure Blob storage integration tests" {
        BeforeEach {
            $filePath = "$PSScriptRoot\appsettings.json"
            [string]$appsettings = Get-Content $filePath
            $config = ConvertFrom-Json $appsettings
            
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
        }
        Context "Upload files to Azure Blob storage"{
            It "Uploads files to existing Azure Blob storage resource" {
                try {
                    # Arrange
                    $targetFolderPath = "arcus-scripting-storage-folder"
                    $containerName = "arcus-scripting-storage-container"

                    # Act
                    Upload-AzFilesToBlobStorage `
                        -ResourceGroupName $config.Arcus.ResourceGroupName `
                        -StorageAccountName $config.Arcus.Storage.StorageAccountName `
                        -TargetFolderPath $targetFolderPath `
                        -ContainerName $containerName

                    # Assert
                    $blob = Get-AzStorageBlob -Container $containerName -Blob "arcus.png"
                    $blob | Should -Not -Be $null
                    $blob.IsDeleted | Should -Be $false
                } finally {
                    $storageAccount = Get-AzStorageAccount -ResourceGroupName $config.Arcus.ResourceGroupName -Name $config.Arcus.Storage.StorageAccountName
                    Remove-AzStorageContainer -Name $containerName -Context $storageAccount.Context -Force
                }
            }
        }
    }
}

