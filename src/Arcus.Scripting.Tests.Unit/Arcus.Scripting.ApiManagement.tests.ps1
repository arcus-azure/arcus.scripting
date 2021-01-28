﻿using module Az
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.ApiManagement -DisableNameChecking

Describe "Arcus" {
    Context "ApiManagement" {
        InModuleScope Arcus.Scripting.ApiManagement {
            It "Creates storage context during API management backup" {
                # Arrange
                $resourceGroupName = "shopping"
                $storageAccountResourceGroup = "stock"
                $storageAccountName = "shopping-storage"
                $serviceName = "shopping-API-management"
                $targetContainerName = "backup-storage"
                $storageKeyValue = "my-storage-key"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)
                
                # Test values, not really pointing to anything
                $testSasToken = "?st=2013-09-03T04%3A12%3A15Z&se=2013-09-03T05%3A12%3A15Z&sr=c&sp=r&sig=fN2NPxLK99tR2%2BWnk48L3lMjutEj7nOwBo7MXs2hEV8%3D"
                $testEndpoint = "http://storageaccountname.blob.core.windows.net"
                $testConnection = [System.String]::Format("BlobEndpoint={0};QueueEndpoint={0};TableEndpoint={0};SharedAccessSignature={1}", $testEndpoint, $testSasToken)
                $storageAccount = [Microsoft.Azure.Storage.CloudStorageAccount]::Parse($testConnection)
                $storageContext = New-Object -TypeName Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext -ArgumentList $storageAccount

                Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $storageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $storageContext }
                Mock Backup-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroupName
                    $Name | Should -Be $serviceName
                    $StorageContext | Should -be $storageContext
                    $TargetContainerName | Should -Be $targetContainerName
                    $TargetBlobName | Should -BeNullOrEmpty 
                    $PassThru | Should -Be $false
                    $DefaultProfile | Should -Be $null }

                # Act
                Backup-AzApiManagementService -ResourceGroupName $resourceGroupName -StorageAccountResourceGroup $storageAccountResourceGroup -StorageAccountName $storageAccountName -ServiceName $serviceName -ContainerName $targetContainerName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Backup-AzApiManagement -Times 1
            }
            It "Backs up API management with target blob name" {
                # Arrange
                $resourceGroupName = "shopping"
                $storageAccountResourceGroup = "stock"
                $storageAccountName = "shopping-storage"
                $serviceName = "shopping-API-management"
                $targetContainerName = "backup-storage"
                $targetBlobName = "backup-storage-blob"
                $storageKeyValue = "my-storage-key"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)
                
                # Test values, not really pointing to anything
                $testSasToken = "?st=2013-09-03T04%3A12%3A15Z&se=2013-09-03T05%3A12%3A15Z&sr=c&sp=r&sig=fN2NPxLK99tR2%2BWnk48L3lMjutEj7nOwBo7MXs2hEV8%3D"
                $testEndpoint = "http://storageaccountname.blob.core.windows.net"
                $testConnection = [System.String]::Format("BlobEndpoint={0};QueueEndpoint={0};TableEndpoint={0};SharedAccessSignature={1}", $testEndpoint, $testSasToken)
                $storageAccount = [Microsoft.Azure.Storage.CloudStorageAccount]::Parse($testConnection)
                $storageContext = New-Object -TypeName Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext -ArgumentList $storageAccount

                Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $storageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $storageContext }
                Mock Backup-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroupName
                    $Name | Should -Be $serviceName
                    $StorageContext | Should -be $storageContext
                    $TargetContainerName | Should -Be $targetContainerName
                    $TargetBlobName | Should -Be $targetBlobName
                    $PassThru | Should -Be $false
                    $DefaultProfile | Should -Be $null }

                # Act
                Backup-AzApiManagementService -ResourceGroupName $resourceGroupName -StorageAccountResourceGroup $storageAccountResourceGroup -StorageAccountName $storageAccountName -ServiceName $serviceName -ContainerName $targetContainerName -BlobName $targetBlobName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Backup-AzApiManagement -Times 1
            }
            It "Backs up API management with pass thru" {
                # Arrange
                $resourceGroupName = "shopping"
                $storageAccountResourceGroup = "stock"
                $storageAccountName = "shopping-storage"
                $serviceName = "shopping-API-management"
                $targetContainerName = "backup-storage"
                $storageKeyValue = "my-storage-key"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)
                
                # Test values, not really pointing to anything
                $testSasToken = "?st=2013-09-03T04%3A12%3A15Z&se=2013-09-03T05%3A12%3A15Z&sr=c&sp=r&sig=fN2NPxLK99tR2%2BWnk48L3lMjutEj7nOwBo7MXs2hEV8%3D"
                $testEndpoint = "http://storageaccountname.blob.core.windows.net"
                $testConnection = [System.String]::Format("BlobEndpoint={0};QueueEndpoint={0};TableEndpoint={0};SharedAccessSignature={1}", $testEndpoint, $testSasToken)
                $storageAccount = [Microsoft.Azure.Storage.CloudStorageAccount]::Parse($testConnection)
                $storageContext = New-Object -TypeName Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext -ArgumentList $storageAccount

                Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $storageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $storageContext }
                Mock Backup-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroupName
                    $Name | Should -Be $serviceName
                    $StorageContext | Should -be $storageContext
                    $TargetContainerName | Should -Be $targetContainerName
                    $TargetBlobName | Should -BeNullOrEmpty 
                    $PassThru | Should -Be $true
                    $DefaultProfile | Should -Be $null }

                # Act
                Backup-AzApiManagementService -ResourceGroupName $resourceGroupName -StorageAccountResourceGroup $storageAccountResourceGroup -StorageAccountName $storageAccountName -ServiceName $serviceName -ContainerName $targetContainerName -PassThru

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Backup-AzApiManagement -Times 1
            }
            It "Backs up API management with default profile" {
                # Arrange
                $resourceGroupName = "shopping"
                $storageAccountResourceGroup = "stock"
                $storageAccountName = "shopping-storage"
                $serviceName = "shopping-API-management"
                $targetContainerName = "backup-storage"
                $storageKeyValue = "my-storage-key"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)
                $defaultProfile = New-Object -TypeName Microsoft.Azure.Commands.Common.Authentication.Models.AzureRmProfile

                # Test values, not really pointing to anything
                $testSasToken = "?st=2013-09-03T04%3A12%3A15Z&se=2013-09-03T05%3A12%3A15Z&sr=c&sp=r&sig=fN2NPxLK99tR2%2BWnk48L3lMjutEj7nOwBo7MXs2hEV8%3D"
                $testEndpoint = "http://storageaccountname.blob.core.windows.net"
                $testConnection = [System.String]::Format("BlobEndpoint={0};QueueEndpoint={0};TableEndpoint={0};SharedAccessSignature={1}", $testEndpoint, $testSasToken)
                $storageAccount = [Microsoft.Azure.Storage.CloudStorageAccount]::Parse($testConnection)
                $storageContext = New-Object -TypeName Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext -ArgumentList $storageAccount

                Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $storageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $storageContext }
                Mock Backup-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroupName
                    $Name | Should -Be $serviceName
                    $StorageContext | Should -be $storageContext
                    $TargetContainerName | Should -Be $targetContainerName
                    $TargetBlobName | Should -BeNullOrEmpty 
                    $PassThru | Should -Be $true
                    $DefaultProfile | Should -Be $defaultProfile }

                # Act
                Backup-AzApiManagementService -ResourceGroupName $resourceGroupName -StorageAccountResourceGroup $storageAccountResourceGroup -StorageAccountName $storageAccountName -ServiceName $serviceName -ContainerName $targetContainerName -PassThru -DefaultProfile $defaultProfile

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Backup-AzApiManagement -Times 1
            }
            It "Calls new operation on Azure API Management operation w/o policy" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $apiId = "shopping-API"
                $operationId = "orders"
                $method = "POST"
                $urlTemplate = "https://{host}.com/{path}{query}"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext

                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    return $context } -Verifiable
                Mock New-AzApiManagementOperation {
                    $Context | Should -Be $context
                    $ApiId | Should -Be $apiId
                    $OperationId | Should -Be $operationId
                    $Method | Should -Be $method
                    $UrlTemplate | Should -Be $urlTemplate } -Verifiable
                Mock Set-AzApiManagementPolicy { }

                # Act
                Create-AzApiManagementApiOperation -ResourceGroupName $resourceGroup -ServiceName $serviceName -ApiId $apiId -OperationId $operationId -Method $method -UrlTemplate $urlTemplate

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled New-AzApiManagementContext -Times 1
                Assert-MockCalled New-AzApiManagementOperation -Times 1
                Assert-MockCalled Set-AzApiManagementPolicy -Times 0
            }
            It "Calls new operation on Azure API management operation w/ policy" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $apiId = "shopping-API"
                $operationId = "orders"
                $method = "POST"
                $urlTemplate = "https://{host}.com/{path}{query}"
                $operationName = "POSTing orders"
                $description = "API that can process posted orders"
                $policyFilePath = "/file-path/operation-policy"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext

                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    return $context } -Verifiable
                Mock New-AzApiManagementOperation {
                    $Context | Should -Be $context
                    $ApiId | Should -Be $apiId
                    $OperationId | Should -Be $operationId
                    $Method | Should -Be $method
                    $UrlTemplate | Should -Be $urlTemplate
                    $Description | Should -Be $description } -Verifiable
                Mock Set-AzApiManagementPolicy {
                    $ApiId | Should -Be $apiId
                    $OperationId | Should -Be $operationId
                    $PolicyFilePath | Should -Be $policyFilePath } -Verifiable

                # Act
                Create-AzApiManagementApiOperation -ResourceGroupName $resourceGroup -ServiceName $serviceName -ApiId $apiId -OperationId $operationId -Method $method -UrlTemplate $urlTemplate -OperationName $operationName -Description $Description -PolicyFilePath $policyFilePath

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled New-AzApiManagementContext -Times 1
                Assert-MockCalled New-AzApiManagementOperation -Times 1
                Assert-MockCalled Set-AzApiManagementPolicy -Times 1
            }
            It "Importing policy product sets Azure API Management policy on operation" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $productId = "shopping-API"
                $policyFilePath = "/file-path/operation-policy"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext

                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    return $context } -Verifiable
                Mock Set-AzApiManagementPolicy {
                    $Context | Should -Be $context
                    $ProductId | Should -Be $productId
                    $OperationId | Should -Be $operationId
                    $PolicyFilePath | Should -Be $policyFilePath
                    return $true } -Verifiable

                # Act
                Import-AzApiManagementProductPolicy -ResourceGroupName $resourceGroup -ServiceName $serviceName -ProductId $productId -PolicyFilePath $policyFilePath

                # Assert
                Assert-VerifiableMock
            }
            It "Importing policy product fails sets Azure API Management policy on operation" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $productId = "shopping-API"
                $policyFilePath = "/file-path/operation-policy"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext

                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    return $context } -Verifiable
                Mock Set-AzApiManagementPolicy {
                    $Context | Should -Be $context
                    $ProductId | Should -Be $productId
                    $OperationId | Should -Be $operationId
                    $PolicyFilePath | Should -Be $policyFilePath
                    return $false } -Verifiable

                # Act
                { Import-AzApiManagementProductPolicy -ResourceGroupName $resourceGroup -ServiceName $serviceName -ProductId $productId -PolicyFilePath $policyFilePath } |
                    # Assert
                    Should -Throw
            }
            It "Remove API Management defaults succeed" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext

                Mock Remove-AzApiManagementApi {
                    $Context | Should -Be $context
                    $ApiId | Should -Be "echo-api"
                    return $true } -Verifiable
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $true } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $true } -Verifiable -ParameterFilter { $ProductId -eq "unlimited" }

                # Act
                Remove-AzApiManagementDefaults -ResourceGroupName $resourceGroup -ServiceName $serviceName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Remove-AzApiManagementApi -Times 1
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "unlimited" }
            }
            It "Remove API Management defaults when echo-api API failed to remove, throws" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext

                Mock Remove-AzApiManagementApi {
                    $Context | Should -Be $context
                    $ApiId | Should -Be "echo-api"
                    return $false } -Verifiable
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $true } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $true } -Verifiable -ParameterFilter { $ProductId -eq "unlimited" }

                # Act
                { Remove-AzApiManagementDefaults -ResourceGroupName $resourceGroup -ServiceName $serviceName } |
                    Should -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Remove-AzApiManagementApi -Times 1
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "unlimited" }
            }
            It "Remove API Management defaults when starter product failed to remove, throws" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext

                Mock Remove-AzApiManagementApi {
                    $Context | Should -Be $context
                    $ApiId | Should -Be "echo-api"
                    return $true } -Verifiable
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $false } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $true } -Verifiable -ParameterFilter { $ProductId -eq "unlimited" }

                # Act
                { Remove-AzApiManagementDefaults -ResourceGroupName $resourceGroup -ServiceName $serviceName } |
                    Should -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Remove-AzApiManagementApi -Times 1
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "unlimited" }
            }
            It "Remove API Management defaults when unlimited product failed to remove, throws" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext

                Mock Remove-AzApiManagementApi {
                    $Context | Should -Be $context
                    $ApiId | Should -Be "echo-api"
                    return $true } -Verifiable
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $true } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $false } -Verifiable -ParameterFilter { $ProductId -eq "unlimited" }

                # Act
                { Remove-AzApiManagementDefaults -ResourceGroupName $resourceGroup -ServiceName $serviceName } |
                    Should -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Remove-AzApiManagementApi -Times 1
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "unlimited" }
            }
            It "Importing policy API sets API Management policy on operation" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $apiId = "shopping-API"
                $policyFilePath = "/file-path/operation-policy"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext

                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    return $context } -Verifiable
                Mock Set-AzApiManagementPolicy {
                    $Context | Should -Be $context
                    $ApiId | Should -Be $apiId
                    $PolicyFilePath | Should -Be $policyFilePath
                    return $true } -Verifiable

                # Act
                Import-AzApiManagementApiPolicy -ResourceGroupName $resourceGroup -ServiceName $serviceName -ApiId $apiId -PolicyFilePath $policyFilePath

                # Assert
                Assert-VerifiableMock
            }
            It "Importing policy API fails Azure API Management policy on operation" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $apiId = "shopping-API"
                $policyFilePath = "/file-path/operation-policy"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext

                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    return $context } -Verifiable
                Mock Set-AzApiManagementPolicy {
                    $Context | Should -Be $context
                    $ApiId | Should -Be $apiId
                    $PolicyFilePath | Should -Be $policyFilePath
                    return $false } -Verifiable

                # Act
                { Import-AzApiManagementApiPolicy -ResourceGroupName $resourceGroup -ServiceName $serviceName -ApiId $apiId -PolicyFilePath $policyFilePath } |
                    Should -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled New-AzApiManagementContext -Times 1
                Assert-MockCalled Set-AzApiManagementPolicy -Times 1
            }
            It "Importing policy operation sets Azure API Management policy on operation" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $apiId = "shopping-API"
                $operationId = "orders"
                $policyFilePath = "/file-path/operation-policy"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext

                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    return $context } -Verifiable
                Mock Set-AzApiManagementPolicy {
                    $Context | Should -Be $context
                    $ApiId | Should -Be $apiId
                    $OperationId | Should -Be $operationId
                    $PolicyFilePath | Should -Be $policyFilePath
                    return $true } -Verifiable

                # Act
                Import-AzApiManagementOperationPolicy -ResourceGroupName $resourceGroup -ServiceName $serviceName -ApiId $apiId -OperationId $operationId -PolicyFilePath $policyFilePath
                
                # Assert
                Assert-VerifiableMock
            }
            It "Importing policy operation fails to set Azure API Management policy on operation" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $apiId = "shopping-API"
                $operationId = "orders"
                $policyFilePath = "/file-path/operation-policy"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext

                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    return $context } -Verifiable
                Mock Set-AzApiManagementPolicy {
                    $Context | Should -Be $context
                    $ApiId | Should -Be $apiId
                    $OperationId | Should -Be $operationId
                    $PolicyFilePath | Should -Be $policyFilePath
                    return $false } -Verifiable

                # Act
                { Import-AzApiManagementOperationPolicy -ResourceGroupName $resourceGroup -ServiceName $serviceName -ApiId $apiId -OperationId $operationId -PolicyFilePath $policyFilePath } |
                    Should -Throw

                # Assert
                Assert-VerifiableMock
            }
            It "Restores API management service w/o pass thru and profile" {
                # Arrange
                $resourceGroupName = "shopping"
                $storageAccountResourceGroup = "stock"
                $storageAccountName = "shopping-storage"
                $serviceName = "shopping-API-management"
                $containerName = "backup-storage"
                $blobName = "backup-storage-blob"
                $storageKeyValue = "my-storage-key"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)

                # Test values, not really pointing to anything
                $testSasToken = "?st=2013-09-03T04%3A12%3A15Z&se=2013-09-03T05%3A12%3A15Z&sr=c&sp=r&sig=fN2NPxLK99tR2%2BWnk48L3lMjutEj7nOwBo7MXs2hEV8%3D"
                $testEndpoint = "http://storageaccountname.blob.core.windows.net"
                $testConnection = [System.String]::Format("BlobEndpoint={0};QueueEndpoint={0};TableEndpoint={0};SharedAccessSignature={1}", $testEndpoint, $testSasToken)
                $storageAccount = [Microsoft.Azure.Storage.CloudStorageAccount]::Parse($testConnection)
                $storageContext = New-Object -TypeName Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext -ArgumentList $storageAccount

                 Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $storageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $storageContext }
                Mock Restore-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroupName
                    $Name | Should -Be $serviceName
                    $StorageContext | Should -be $storageContext
                    $SourceContainerName | Should -Be $containerName
                    $SourceBlobName | Should -Be $blobName
                    $PassThru | Should -Be $false
                    $DefaultProfile | Should -Be $null }

                # Act
                Restore-AzApiManagementService -ResourceGroupName $resourceGroupName -StorageAccountResourceGroupName $storageAccountResourceGroup -StorageAccountName $storageAccountName -ServiceName $serviceName -ContainerName $containerName -BlobName $blobName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Restore-AzApiManagement -Times 1
            }
            It "Restores API management service w/ pass thru and w/o profile" {
                # Arrange
                $resourceGroupName = "shopping"
                $storageAccountResourceGroup = "stock"
                $storageAccountName = "shopping-storage"
                $serviceName = "shopping-API-management"
                $containerName = "backup-storage"
                $blobName = "backup-storage-blob"
                $storageKeyValue = "my-storage-key"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)

                # Test values, not really pointing to anything
                $testSasToken = "?st=2013-09-03T04%3A12%3A15Z&se=2013-09-03T05%3A12%3A15Z&sr=c&sp=r&sig=fN2NPxLK99tR2%2BWnk48L3lMjutEj7nOwBo7MXs2hEV8%3D"
                $testEndpoint = "http://storageaccountname.blob.core.windows.net"
                $testConnection = [System.String]::Format("BlobEndpoint={0};QueueEndpoint={0};TableEndpoint={0};SharedAccessSignature={1}", $testEndpoint, $testSasToken)
                $storageAccount = [Microsoft.Azure.Storage.CloudStorageAccount]::Parse($testConnection)
                $storageContext = New-Object -TypeName Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext -ArgumentList $storageAccount

                 Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $storageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $storageContext }
                Mock Restore-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroupName
                    $Name | Should -Be $serviceName
                    $StorageContext | Should -be $storageContext
                    $SourceContainerName | Should -Be $containerName
                    $SourceBlobName | Should -Be $blobName 
                    $PassThru | Should -Be $true
                    $DefaultProfile | Should -Be $null }

                # Act
                Restore-AzApiManagementService -ResourceGroupName $resourceGroupName -StorageAccountResourceGroupName $storageAccountResourceGroup -StorageAccountName $storageAccountName -ServiceName $serviceName -ContainerName $containerName -BlobName $blobName -PassThru

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Restore-AzApiManagement -Times 1
            }
            It "Restores API management service w/o pass thru and w/ profile" {
                # Arrange
                $resourceGroupName = "shopping"
                $storageAccountResourceGroup = "stock"
                $storageAccountName = "shopping-storage"
                $serviceName = "shopping-API-management"
                $containerName = "backup-storage"
                $blobName = "backup-storage-blob"
                $storageKeyValue = "my-storage-key"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)
                $defaultProfile = New-Object -TypeName Microsoft.Azure.Commands.Common.Authentication.Models.AzureRmProfile

                # Test values, not really pointing to anything
                $testSasToken = "?st=2013-09-03T04%3A12%3A15Z&se=2013-09-03T05%3A12%3A15Z&sr=c&sp=r&sig=fN2NPxLK99tR2%2BWnk48L3lMjutEj7nOwBo7MXs2hEV8%3D"
                $testEndpoint = "http://storageaccountname.blob.core.windows.net"
                $testConnection = [System.String]::Format("BlobEndpoint={0};QueueEndpoint={0};TableEndpoint={0};SharedAccessSignature={1}", $testEndpoint, $testSasToken)
                $storageAccount = [Microsoft.Azure.Storage.CloudStorageAccount]::Parse($testConnection)
                $storageContext = New-Object -TypeName Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext -ArgumentList $storageAccount

                 Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $storageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $storageContext }
                Mock Restore-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroupName
                    $Name | Should -Be $serviceName
                    $StorageContext | Should -be $storageContext
                    $SourceContainerName | Should -Be $containerName
                    $SourceBlobName | Should -Be $blobName 
                    $PassThru | Should -Be $false
                    $DefaultProfile | Should -Be $defaultProfile }

                # Act
                Restore-AzApiManagementService -ResourceGroupName $resourceGroupName -StorageAccountResourceGroupName $storageAccountResourceGroup -StorageAccountName $storageAccountName -ServiceName $serviceName -ContainerName $containerName -BlobName $blobName -DefaultProfile $defaultProfile

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Restore-AzApiManagement -Times 1
            }
            It "Restores API management service w/ pass thru and profile" {
                # Arrange
                $resourceGroupName = "shopping"
                $storageAccountResourceGroup = "stock"
                $storageAccountName = "shopping-storage"
                $serviceName = "shopping-API-management"
                $containerName = "backup-storage"
                $blobName = "backup-storage-blob"
                $storageKeyValue = "my-storage-key"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)
                $defaultProfile = New-Object -TypeName Microsoft.Azure.Commands.Common.Authentication.Models.AzureRmProfile

                # Test values, not really pointing to anything
                $testSasToken = "?st=2013-09-03T04%3A12%3A15Z&se=2013-09-03T05%3A12%3A15Z&sr=c&sp=r&sig=fN2NPxLK99tR2%2BWnk48L3lMjutEj7nOwBo7MXs2hEV8%3D"
                $testEndpoint = "http://storageaccountname.blob.core.windows.net"
                $testConnection = [System.String]::Format("BlobEndpoint={0};QueueEndpoint={0};TableEndpoint={0};SharedAccessSignature={1}", $testEndpoint, $testSasToken)
                $storageAccount = [Microsoft.Azure.Storage.CloudStorageAccount]::Parse($testConnection)
                $storageContext = New-Object -TypeName Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext -ArgumentList $storageAccount

                 Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $storageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $storageContext }
                Mock Restore-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroupName
                    $Name | Should -Be $serviceName
                    $StorageContext | Should -be $storageContext
                    $SourceContainerName | Should -Be $containerName
                    $SourceBlobName | Should -Be $blobName 
                    $PassThru | Should -Be $true
                    $DefaultProfile | Should -Be $defaultProfile }

                # Act
                Restore-AzApiManagementService -ResourceGroupName $resourceGroupName -StorageAccountResourceGroupName $storageAccountResourceGroup -StorageAccountName $storageAccountName -ServiceName $serviceName -ContainerName $containerName -BlobName $blobName -PassThru -DefaultProfile $defaultProfile

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Restore-AzApiManagement -Times 1
            }
            It "Sets subscription keys on an API in Azure API Management" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $apiId = "shopping-API"
                $apiKeyHeaderName = "header-name"
                $apiKeyQueryParamName = "query-param-name"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext

                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    return $context } -Verifiable

                Mock Set-AzApiManagementApi {
                    $Context | Should -be $context
                    $ApiId | Should -Be $apiId
                    $SubscriptionKeyHeaderName | Should -Be $apiKeyHeaderName
                    $SubscriptionKeyQueryParamName | Should -Be $apiKeyQueryParamName } -Verifiable

                # Act
                Set-AzApiManagementApiSubscriptionKey -ResourceGroupName $resourceGroup -ServiceName $serviceName -ApiId $apiId -HeaderName $apiKeyHeaderName -QueryParamName $apiKeyQueryParamName

                # Assert
                Assert-VerifiableMock
            }
        }
    }
}
