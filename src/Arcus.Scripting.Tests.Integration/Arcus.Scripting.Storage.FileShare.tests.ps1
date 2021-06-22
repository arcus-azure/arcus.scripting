Import-Module Az.Storage
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Storage.FileShare -ErrorAction Stop

InModuleScope Arcus.Scripting.Storage.FileShare {
    Describe "Arcus Azure FileShare storage integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1 -fileName "appsettings.json"
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
                try {
                    # Act
                    Create-AzFileShareStorageFolder `
                        -ResourceGroupName $config.Arcus.ResourceGroupName `
                        -StorageAccountName $config.Arcus.Storage.StorageAccount.Name `
                        -FileShareName $fileShareName `
                        -FolderName $folderName

                    # Assert
                    Get-AzStorageFile -ShareName $fileShareName |
                        % { $_.GetType().Name } | 
                        Should -Contain $folderName
                    
                } catch {
                    Remove-AzStorageDirectory -Context $storageAccount.Context -ShareName $fileShareName -Path $folderName
                }
            }
            It "Doesn't create a new Azure FileShare storage folder when already exists" {
                # Arrange
                $folderName = "already-existing-arcus-fileshare-folder"
                try {
                    New-AzStorageDirectory -Context $storageAccount.Context -ShareName $fileShareName -Path $folderName

                    # Act
                    Create-AzFileShareStorageFolder `
                        -ResourceGroupName $config.Arcus.ResourceGroupName `
                        -StorageAccountName $config.Arcus.Storage.StorageAccount.Name `
                        -FileShareName $fileShareName `
                        -FolderName $folderName

                    # Assert
                    Get-AzStorageFile -ShareName $fileShareName |
                        % { $_.GetType().Name } |
                        Should -Contain $folderName
                } catch {
                    Remove-AzStorageDirectory -Context $storageAccount.Context -ShareName $fileShareName -Path $folderName
                }
            }
        }
        Context "Copy files into Azure FileShare storage folder" {
            It "Uploads file into existing Azure FileShare" {
                # Arrange
                $folderName = "uploaded-arcus-fileshare-folder"
                try {
                    New-AzStorageDirectory -Context $storageAccount.Context -ShareName $fileShareName -Path $folderName

                    # Act
                    Copy-AzFileShareStorageFiles `
                        -ResourceGroupName $config.Arcus.ResourceGroupName `
                        -SourceFolderPath "$PSScriptPath\Blobs" `
                        -DestinationFolderPath $folderName

                    # Assert
                    Get-AzStorageFile -ShareName $fileShareName -Path $folderName |
                        % { Write-Host $_.Name
                            return $_.Name } |
                        Should -Contain "arcus.png"
                } catch {
                    Remove-AzStorageDirectory -Context $storageAccount.Context -ShareName $fileShareName -Path $folderName
                }
            }
        }
        AfterEach {
            Remove-AzStorageShare -Name $fileShareName -Context $storageAccount.Context -IncludeAllSnapshot -Force
        }
    }
}