Import-Module Az.Storage
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Storage.FileShare -ErrorAction Stop

InModuleScope Arcus.Scripting.Storage.FileShare {
    Describe "Arcus Azure FileShare storage integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1 -fileName "appsettings.json"
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config

            $fileShareName = "arcus-scripting-storage-fileshare"
            $storageAccount = Get-AzStorageAccount -ResourceGroupName $config.Arcus.ResourceGroupName -Name $config.Arcus.Storage.StorageAccount.Name
            New-AzStorageShare -Context $storageAccount.Context -Name $fileShareName `
        }
        Context "Create Azure FileShare storage folder" {
            It "Create a new Azure FileShare storage folder" {
                try {
                    # Arrange
                    $folderName = "new-arcus-fileshare-folder"

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
        AfterEach {
            Remove-AzStorageShare -Name $fileShareName -Context $storageAccount.Context -IncludeAllSnapshot -Force
        }
    }
}