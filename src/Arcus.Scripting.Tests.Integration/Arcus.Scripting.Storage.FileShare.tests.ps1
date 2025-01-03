Import-Module Az.Storage
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Storage.FileShare -ErrorAction Stop

InModuleScope Arcus.Scripting.Storage.FileShare {
    Describe "Arcus Azure FileShare storage integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
            
            $guid = [System.Guid]::NewGuid()
            $fileShareName = "arcus-scripting-fileshare-$guid"
            $storageAccount = Get-AzStorageAccount -ResourceGroupName $config.Arcus.ResourceGroupName -Name $config.Arcus.Storage.StorageAccount.Name
            New-AzStorageShare -Context $storageAccount.Context -Name $fileShareName
        }
        Context "Create Azure FileShare storage folder" {
            It "Creates a new Azure FileShare storage folder" {
                # Arrange
                $folderName = "new-arcus-fileshare-folder"
                
                # Act
                Create-AzFileShareStorageFolder `
                    -ResourceGroupName $config.Arcus.ResourceGroupName `
                    -StorageAccountName $config.Arcus.Storage.StorageAccount.Name `
                    -FileShareName $fileShareName `
                    -FolderName $folderName

                # Assert
                Get-AzStorageFile -ShareName $fileShareName -Context $storageAccount.Context |
                Where-Object { $_.GetType().Name -eq "AzureStorageFileDirectory" } |
                ForEach-Object { $_.Name } |
                Should -Contain $folderName
            }
            It "Doesn't create a new Azure FileShare storage folder when already exists" {
                # Arrange
                $folderName = "already-existing-arcus-fileshare-folder"
                New-AzStorageDirectory -Context $storageAccount.Context -ShareName $fileShareName -Path $folderName

                # Act
                Create-AzFileShareStorageFolder `
                    -ResourceGroupName $config.Arcus.ResourceGroupName `
                    -StorageAccountName $config.Arcus.Storage.StorageAccount.Name `
                    -FileShareName $fileShareName `
                    -FolderName $folderName

                # Assert
                Get-AzStorageFile -ShareName $fileShareName -Context $storageAccount.Context |
                Where-Object { $_.GetType().Name -eq "AzureStorageFileDirectory" } |
                ForEach-Object { $_.Name } |
                Should -Contain $folderName
            }
        }
        Context "Upload files into Azure FileShare storage folder" {
            It "Uploads file into existing Azure FileShare storage" {
                # Arrange
                $folderName = "uploaded-arcus-fileshare-folder"
                New-AzStorageDirectory -Context $storageAccount.Context -ShareName $fileShareName -Path $folderName

                # Act
                Upload-AzFileShareStorageFiles `
                    -ResourceGroupName $config.Arcus.ResourceGroupName `
                    -StorageAccountName $config.Arcus.Storage.StorageAccount.Name `
                    -FileShareName $fileShareName `
                    -SourceFolderPath "$PSScriptRoot\Blobs" `
                    -DestinationFolderName $folderName

                # Assert
                $tempLocation = "$PSScriptRoot\arcus.png"
                try {
                    Get-AzStorageFileContent `
                        -Context $storageAccount.Context `
                        -ShareName $fileShareName `
                        -Path "$folderName/arcus.png" `
                        -Destination $tempLocation -Force
                    $file = Get-Item $tempLocation
                    $file.Length | Should -BeGreaterThan 0
                } finally {
                    Remove-Item $tempLocation -Force
                }
            }
            It "Uploads file into non-existing Azure FileShare storage" {
                # Arrange
                $folderName = "non-existing-arcus-fileshare-folder"
                $nonExistingFileShareName = "non-existing-fileshare-storage"

                # Act / Assert
                { Upload-AzFileShareStorageFiles `
                        -ResourceGroupName $config.Arcus.ResourceGroupName `
                        -StorageAccountName $config.Arcus.Storage.StorageAccount.Name `
                        -FileShareName $nonExistingFileShareName `
                        -SourceFolderPath "$PSScriptRoot\Blobs" `
                        -DestinationFolderName $folderName } |
                Should -Throw
            }
            It "Copying file into existing Azure FileShare storage" {
                # Arrange
                $folderName = "uploaded-arcus-fileshare-folder"
                New-AzStorageDirectory -Context $storageAccount.Context -ShareName $fileShareName -Path $folderName

                # Act
                Copy-AzFileShareStorageFiles `
                    -ResourceGroupName $config.Arcus.ResourceGroupName `
                    -StorageAccountName $config.Arcus.Storage.StorageAccount.Name `
                    -FileShareName $fileShareName `
                    -SourceFolderPath "$PSScriptRoot\Blobs" `
                    -DestinationFolderName $folderName

                # Assert
                $tempLocation = "$PSScriptRoot\arcus.png"
                try {
                    Get-AzStorageFileContent `
                        -Context $storageAccount.Context `
                        -ShareName $fileShareName `
                        -Path "$folderName/arcus.png" `
                        -Destination $tempLocation -Force
                    $file = Get-Item $tempLocation
                    $file.Length | Should -BeGreaterThan 0
                } finally {
                    Remove-Item $tempLocation -Force
                }
            }
            It "Copying file into non-existing Azure FileShare storage" {
                # Arrange
                $folderName = "non-existing-arcus-fileshare-folder"
                $nonExistingFileShareName = "non-existing-fileshare-storage"

                # Act / Assert
                { Copy-AzFileShareStorageFiles `
                        -ResourceGroupName $config.Arcus.ResourceGroupName `
                        -StorageAccountName $config.Arcus.Storage.StorageAccount.Name `
                        -FileShareName $nonExistingFileShareName `
                        -SourceFolderPath "$PSScriptRoot\Blobs" `
                        -DestinationFolderName $folderName } |
                Should -Throw
            }
        }
        AfterEach {
            Remove-AzStorageShare -Name $fileShareName -Context $storageAccount.Context -IncludeAllSnapshot -Force
        }
    }
}
