using module Az
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Storage.FileShare -DisableNameChecking

Describe "Arcus" {
    Context "File Share" {
        InModuleScope Arcus.Scripting.Storage.FileShare {
            It "Create folder on Azure File Share" {
                # Arrange
                $resourceGroup = "stock"
                $folderName = "shipped"
                $fileShareName = "shipped-file"
                $storageAccountName = "admin"
                $tableName = "products"
               
                # Test values, not really pointing to anything
                $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
                $testSasToken = "?st=2013-09-03T04%3A12%3A15Z&se=2013-09-03T05%3A12%3A15Z&sr=c&sp=r&sig=fN2NPxLK99tR2%2BWnk48L3lMjutEj7nOwBo7MXs2hEV8%3D"
                $testEndpoint = "http://storageaccountname.blob.core.windows.net"
                $testConnection = [System.String]::Format("BlobEndpoint={0};QueueEndpoint={0};TableEndpoint={0};SharedAccessSignature={1}", $testEndpoint, $testSasToken)
                $storageAccount = [Microsoft.Azure.Storage.CloudStorageAccount]::Parse($testConnection)
                $storageContext = New-Object -TypeName Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext -ArgumentList $storageAccount
                
                $cloudShare = New-Object -TypeName Microsoft.Azure.Storage.File.CloudFileShare -ArgumentList (New-Object -TypeName System.Uri "https://something")
                $fileShare = New-Object -TypeName Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageFileShare -ArgumentList $cloudShare, $storageContext

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable
                Mock Get-AzStorageShare {
                    $Context | Should -Be $psStorageAccount
                    $Name | Should -Be $fileShareName
                    return $fileShare } -Verifiable
                Mock New-AzStorageDirectory {
                    $Share | Should -Not -Be $null
                    $Path | Should -Be $folderName }

                # Act
                Create-AzFileShareStorageFolder -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName -FileShareName $fileShareName -FolderName $folderName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccount -Times 1
                Assert-MockCalled Get-AzStorageShare -Times 1
                Assert-MockCalled New-AzStorageDirectory -Times 1
            }
        }
        It "Copy files to Azure File Share" {
            # Arrange
            $resourceGroup = "stock"
            $storageAccountName = "admin"
            $fileShareName = "shipped-file"
            $sourceFolderPath = "shipped"
            $destinationFolderName = "shipped"
            $fileMask "suffix"

            # Test values, not really pointing to anything
            $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
            $testSasToken = "?st=2013-09-03T04%3A12%3A15Z&se=2013-09-03T05%3A12%3A15Z&sr=c&sp=r&sig=fN2NPxLK99tR2%2BWnk48L3lMjutEj7nOwBo7MXs2hEV8%3D"
            $testEndpoint = "http://storageaccountname.blob.core.windows.net"
            $testConnection = [System.String]::Format("BlobEndpoint={0};QueueEndpoint={0};TableEndpoint={0};SharedAccessSignature={1}", $testEndpoint, $testSasToken)
            $storageAccount = [Microsoft.Azure.Storage.CloudStorageAccount]::Parse($testConnection)
            $storageContext = New-Object -TypeName Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext -ArgumentList $storageAccount
            
            $cloudShare = New-Object -TypeName Microsoft.Azure.Storage.File.CloudFileShare -ArgumentList (New-Object -TypeName System.Uri "https://something")
            $fileShare = New-Object -TypeName Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageFileShare -ArgumentList $cloudShare, $storageContext
            $files = @( [pscustomobject]@{ Name = "Container 1"; FullName = "Container 1-full" }, [pscustomobject]@{ Name = "Container 2"; FullName = "Container 2-full" })

            Mock Get-AzStorageAccount {
                $ResourceGroupName | Should -Be $resourceGroup
                $Name | Should -Be $storageAccountName
                return $psStorageAccount } -Verifiable 
            Mock Get-AzStorageShare {
                $Context | Should -Be $psStorageAccount
                $Name | Should -Be $fileShareName
                return $fileShare } -Verifiable
            Mock Get-ChildItem {
                $Path | Should -Be $sourceFolderPath
                return $files }
            Mock Set-AzStorageFileContent {
                $Context | Should -Be $psStorageAccount
                $ShareName | Should -Be $fileShareName
                $Source | Should -BeIn ($files | % { $_.FullName })
                $Path | Should -Be $destinationFolderName }

            # Act
            Copy-AzFileShareStorageFiles -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName -FilesShareName $fileShareName -SourceFolderPath $sourceFolderPath -DestinationFolderName $destinationFolderName -FileMask $fileMask
            
            # Assert
            Assert-VerifiableMock
            Assert-MockCalled Get-AzStorageacount -Times 1
            Assert-MockCalled Get-AzStorageShare -Times 1
            Assert-MockCalled Get-ChildItem -Times 1
            Assert-MockCalled Set-AzStorageFileContent -Times 1
        }
        It "Copy files to Azure File Share fails when no File Share is found" {
            # Arrange
            $resourceGroup = "stock"
            $storageAccountName = "admin"
            $fileShareName = "shipped-file"
            $sourceFolderPath = "shipped"
            $destinationFolderName = "shipped"
            $fileMask "suffix"

            # Test values, not really pointing to anything
            $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
            $testSasToken = "?st=2013-09-03T04%3A12%3A15Z&se=2013-09-03T05%3A12%3A15Z&sr=c&sp=r&sig=fN2NPxLK99tR2%2BWnk48L3lMjutEj7nOwBo7MXs2hEV8%3D"
            $testEndpoint = "http://storageaccountname.blob.core.windows.net"
            $testConnection = [System.String]::Format("BlobEndpoint={0};QueueEndpoint={0};TableEndpoint={0};SharedAccessSignature={1}", $testEndpoint, $testSasToken)
            $storageAccount = [Microsoft.Azure.Storage.CloudStorageAccount]::Parse($testConnection)
            $storageContext = New-Object -TypeName Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext -ArgumentList $storageAccount
            
            $cloudShare = New-Object -TypeName Microsoft.Azure.Storage.File.CloudFileShare -ArgumentList (New-Object -TypeName System.Uri "https://something")
            $fileShare = New-Object -TypeName Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageFileShare -ArgumentList $cloudShare, $storageContext

            Mock Get-AzStorageAccount {
                $ResourceGroupName | Should -Be $resourceGroup
                $Name | Should -Be $storageAccountName
                return $psStorageAccount } -Verifiable 
            Mock Get-AzStorageShare {
                $Context | Should -Be $psStorageAccount
                $Name | Should -Be $fileShareName
                throw [Microsoft.Azure.Storage.StorageException] "Sabotage getting file share" } -Verifiable
            Mock Get-ChildItem { }
            Mock Set-AzStorageFileContent { }

            # Act
            Copy-AzFileShareStorageFiles -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName -FilesShareName $fileShareName -SourceFolderPath $sourceFolderPath -DestinationFolderName $destinationFolderName -FileMask $fileMask
            
            # Assert
            Assert-VerifiableMock
            Assert-MockCalled Get-AzStorageacount -Times 1
            Assert-MockCalled Get-AzStorageShare -Times 1
            Assert-MockCalled Get-ChildItem -Times 0
            Assert-MockCalled Set-AzStorageFileContent -Times 0
        }
    }
}
