Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Storage.FileShare -ErrorAction Stop

InModuleScope Arcus.Scripting.Storage.FileShare {
    Describe "Arcus Azure File Share unit tests" {
        BeforeEach {
            # Test values, not really pointing to anything
            $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
            $testSasToken = "?st=2013-09-03T04%3A12%3A15Z&se=2013-09-03T05%3A12%3A15Z&sr=c&sp=r&sig=fN2NPxLK99tR2%2BWnk48L3lMjutEj7nOwBo7MXs2hEV8%3D"
            $testEndpoint = "http://storageaccountname.blob.core.windows.net"
            $testConnection = [System.String]::Format("BlobEndpoint={0};QueueEndpoint={0};TableEndpoint={0};SharedAccessSignature={1}", $testEndpoint, $testSasToken)
            $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
            $psStorageAccount = New-Object -TypeName Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount -ArgumentList $storageAccount
        }
        Context "Creating Azure File Share folder" {
            It "Create new folder on Azure File Share succeeds" {
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
                Mock New-AzStorageDirectory {
                    $ShareName | Should -Be $fileShareName
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
                Assert-MockCalled New-AzStorageDirectory -Times 1
            }
            It "Creates duplicate folder on Azure FileShare" {
                # Arrange
                $resourceGroup = "stock"
                $folderName = "shipped"
                $fileShareName = "shipped-file"
                $storageAccountName = "admin"
                $tableName = "products"
                $fileAddress = "http://test.file.core.windows.net/$fileShareName/$folderName"
                Write-Host $fileAddress


                $storageUri = New-Object -TypeName System.Uri -ArgumentList $fileAddress
                $shareClientOptions = New-Object -TypeName Azure.Storage.Files.Shares.ShareClientOptions('V2023_08_03')
                $shareDirectoryClient = New-Object -TypeName Azure.Storage.Files.Shares.ShareDirectoryClient($storageUri, $shareClientOptions)
                $fileShareDirectory = New-Object -TypeName Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageFileDirectory -ArgumentList $shareDirectoryClient, $psStorageAccount.Context 
                Write-Host "Name: " $fileShareDirectory.Name

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable
                Mock Get-AzStorageFile { 
                    $ShareName | Should -Be $fileShareName
                    $Context | Should -Be $psStorageAccount.Context
                    return @($fileShareDirectory) }
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
                Assert-MockCalled New-AzStorageDirectory -Times 0
            }
        }
        Context "Uploading files to Azure File Share" {
            It "Upload files to existing Azure File Share" {
                # Arrange
                $resourceGroup = "stock"
                $storageAccountName = "admin"
                $fileShareName = "shipped-file"
                $sourceFolderPath = "/shipped"
                $destinationFolderName = "/shipped"
                $fileMask = "-suffix"

                $files = @( 
                    [pscustomobject]@{ Name = "Container 1$fileMask"; FullName = "Container 1-full" }, 
                    [pscustomobject]@{ Name = "Container 2"; FullName = "Container 2-full" }
                )

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable
                Mock Get-AzStorageShare {
                    $Context | Should -Be $psStorageAccount.Context
                    $Name | Should -Be $fileShareName
                    return $fileShare } -Verifiable
                Mock Get-ChildItem {
                    $Path | Should -Be $sourceFolderPath
                    return $files } -Verifiable
                Mock Set-AzStorageFileContent {
                    $Context | Should -Be $psStorageAccount.Context
                    $ShareName | Should -Be $fileShareName
                    $Source | Should -BeIn ($files | ForEach-Object { $_.FullName })
                    $Path | Should -Be $destinationFolderName } -Verifiable

                # Act
                Upload-AzFileShareStorageFiles `
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
            It "Upload files to Azure File Share fails when no File Share is found" {
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
                    $Context | Should -Be $psStorageAccount.Context
                    $Name | Should -Be $fileShareName
                    throw [Microsoft.Azure.Storage.StorageException] "Sabotage does not exist getting file share" }
                Mock Get-ChildItem { }
                Mock Set-AzStorageFileContent { }

                # Act
                { Upload-AzFileShareStorageFiles `
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
        Context "Copying files to Azure File Share" {
            It "Copy files to existing Azure File Share" {
                # Arrange
                $resourceGroup = "stock"
                $storageAccountName = "admin"
                $fileShareName = "shipped-file"
                $sourceFolderPath = "/shipped"
                $destinationFolderName = "/shipped"
                $fileMask = "-suffix"

                $files = @( 
                    [pscustomobject]@{ Name = "Container 1$fileMask"; FullName = "Container 1-full" }, 
                    [pscustomobject]@{ Name = "Container 2"; FullName = "Container 2-full" }
                )

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable
                Mock Get-AzStorageShare {
                    $Context | Should -Be $psStorageAccount.Context
                    $Name | Should -Be $fileShareName
                    return $fileShare } -Verifiable
                Mock Get-ChildItem {
                    $Path | Should -Be $sourceFolderPath
                    return $files } -Verifiable
                Mock Set-AzStorageFileContent {
                    $Context | Should -Be $psStorageAccount.Context
                    $ShareName | Should -Be $fileShareName
                    $Source | Should -BeIn ($files | ForEach-Object { $_.FullName })
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
                    $Context | Should -Be $psStorageAccount.Context
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
