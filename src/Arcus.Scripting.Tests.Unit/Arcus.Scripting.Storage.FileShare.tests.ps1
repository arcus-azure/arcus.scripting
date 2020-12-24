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
                $storageAccount = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccount
                $psStorageAccount = New-Object -TypeName Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount -ArgumentList $storageAccount
                $cloudShare = New-Object -TypeName Microsoft.Azure.Storage.File.CloudFileShare -ArgumentList (New-Object -TypeName System.Uri "https://something")
                $fileShare = New-Object -TypeName Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageFileShare -ArgumentList $cloudShare, $psStorageAccount

                Mock Get-AzStorageAccount {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $storageAccountName
                    return $psStorageAccount } -Verifiable
                Mock Get-AzStorageShare {
                    $Context | Should -Be $psStorageAccount
                    $Name | Should -Be $fileShareName
                    return $fileShare } -Verifiable
                Mock New-AzStorageDirectory {
                    $Directory | Should -Be $fileShare
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
    }
}
