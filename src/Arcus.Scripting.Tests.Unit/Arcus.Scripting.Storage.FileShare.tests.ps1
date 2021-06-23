Describe "Arcus" {
    Context "File Share" {
        InModuleScope Arcus.Scripting.Storage.FileShare {
            BeforeEach {
                # Test values, not really pointing to anything
                $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
                $testSasToken = "?st=2013-09-03T04%3A12%3A15Z&se=2013-09-03T05%3A12%3A15Z&sr=c&sp=r&sig=fN2NPxLK99tR2%2BWnk48L3lMjutEj7nOwBo7MXs2hEV8%3D"
                $testEndpoint = "http://storageaccountname.blob.core.windows.net"
                $testConnection = [System.String]::Format("BlobEndpoint={0};QueueEndpoint={0};TableEndpoint={0};SharedAccessSignature={1}", $testEndpoint, $testSasToken)
                $storageAccount = [Microsoft.Azure.Storage.CloudStorageAccount]::Parse($testConnection)
                $psStorageAccount = New-Object -TypeName Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount -ArgumentList $storageAccount
                $storageContext = New-Object -TypeName Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext -ArgumentList $storageAccount

                $cloudShare = New-Object -TypeName Microsoft.Azure.Storage.File.CloudFileShare -ArgumentList (New-Object -TypeName System.Uri "https://something")
                $fileShare = New-Object -TypeName Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageFileShare -ArgumentList $cloudShare, $storageContext
            }
            It "Create folder on Azure File Share" {
                # Arrange
                $resourceGroup = "stock"
                $folderName = "shipped"
                $fileShareName = "shipped-file"
                $storageAccountName = "admin"
                $tableName = "products"
                
                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable
                Mock Get-AzStorageFile { return @() }
                Mock Get-AzStorageShare {
                    $Context | Should -Be $psStorageAccount
                    $Name | Should -Be $fileShareName
                    return $fileShare } -Verifiable
                Mock New-AzStorageDirectory {
                    $Share | Should -Not -Be $null
                    $Path | Should -Be $folderName }

                # Act
                Create-AzFileShareStorageFolder `
                    -ResourceGroupName $resourceGroup `
                    -StorageAccountName $storageAccountName `
                    -FileShareName $fileShareName `
                    -FolderName $folderName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccount -Times 1
                Assert-MockCalled Get-AzStorageFile -Times 1
                Assert-MockCalled Get-AzStorageShare -Times 1
                Assert-MockCalled New-AzStorageDirectory -Times 1
            }
            It "Creates duplicate folder on Azure FileShare" {
                # Arrange
                $resourceGroup = "stock"
                $folderName = "shipped"
                $fileShareName = "shipped-file"
                $storageAccountName = "admin"
                $tableName = "products"
               
                $storageUri = New-Object -TypeName System.Uri -ArgumentList "http://something.filesharestorage"
                $cloudFileDirectory = New-Object -TypeName Microsoft.Azure.Storage.File.CloudFileDirectory -ArgumentList $null
                $fileShareDirectory = New-Object -TypeName icrosoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageFileDirectory -ArgumentList $cloudFileDirectory, $storageAccount

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable
                Mock Get-AzStorageFile { 
                    $ShareName | Should -Be $fileShareName
                    $Context | Should -Be $storageContext
                    return @($fileShareDirectory) }
                Mock Get-AzStorageShare { }
                Mock New-AzStorageDirectory { } 

                # Act
                Create-AzFileShareStorageFolder `
                    -ResourceGroupName $resourceGroup `
                    -StorageAccountName $storageAccountName `
                    -FileShareName $fileShareName `
                    -FolderName $folderName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageFile -Times 1
                Assert-MockCalled Get-AzStorageAccount -Times 1
                Assert-MockCalled Get-AzStorageShare -Times 0
                Assert-MockCalled New-AzStorageDirectory -Times 0
            }
            It "Copy files to Azure File Share" {
                # Arrange
                $resourceGroup = "stock"
                $storageAccountName = "admin"
                $fileShareName = "shipped-file"
                $sourceFolderPath = "shipped"
                $destinationFolderName = "shipped"
                $fileMask = "-suffix"

                $files = @( [pscustomobject]@{ Name = "Container 1$fileMask"; FullName = "Container 1-full" }, [pscustomobject]@{ Name = "Container 2"; FullName = "Container 2-full" })

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
                    return $files } -Verifiable
                Mock Set-AzStorageFileContent {
                    $Context | Should -Be $psStorageAccount
                    $ShareName | Should -Be $fileShareName
                    $Source | Should -BeIn ($files | % { $_.FullName })
                    $Path | Should -Be $destinationFolderName } -Verifiable

                # Act
                Copy-AzFileShareStorageFiles `
                    -ResourceGroupName $resourceGroup `
                    -StorageAccountName $storageAccountName `
                    -FileShareName $fileShareName `
                    -SourceFolderPath $sourceFolderPath `
                    -DestinationFolderName $destinationFolderName `
                    -FileMask $fileMask
                
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccount -Times 1
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
                $fileMask = "-suffix"

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable 
                Mock Get-AzStorageShare {
                    $Context | Should -Be $psStorageAccount
                    $Name | Should -Be $fileShareName
                    throw [Microsoft.Azure.Storage.StorageException] "Sabotage does not exist getting file share" }
                Mock Get-ChildItem { }
                Mock Set-AzStorageFileContent { }

                # Act
                { Copy-AzFileShareStorageFiles `
                    -ResourceGroupName $resourceGroup `
                    -StorageAccountName $storageAccountName `
                    -FileShareName $fileShareName `
                    -SourceFolderPath $sourceFolderPath `
                    -DestinationFolderName $destinationFolderName `
                    -FileMask $fileMask } |
                    Should -Throw
                
                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccount -Times 1
                Assert-MockCalled Get-ChildItem -Times 0
                Assert-MockCalled Set-AzStorageFileContent -Times 0
            }
        }
    }
}
