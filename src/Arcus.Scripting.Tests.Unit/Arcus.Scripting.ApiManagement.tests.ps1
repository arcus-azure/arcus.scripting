Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.ApiManagement -ErrorAction Stop

InModuleScope Arcus.Scripting.ApiManagement {
    Describe "Arcus Azure API Management unit tests" {
        Context "Back up Azure API Management instance" {
            BeforeEach {
                # Test values, not really pointing to anything
                $expectedStorageAccountName = "shopping-storage"
                $storageKeyValue = "mystoragekey"
                $expectedStorageContext = New-AzStorageContext -StorageAccountName $expectedStorageAccountName -StorageAccountKey $storageKeyValue
            }
            It "Creates storage context during API management backup" {
                # Arrange
                $resourceGroup = "shopping"
                $storageAccountResourceGroup = "stock"                
                $serviceName = "shopping-API-management"
                $targetContainerName = "backup-storage"                
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)
                $accessType = 'SystemAssignedManagedIdentity'

                Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $expectedStorageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $expectedStorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $expectedStorageContext }
                Mock Backup-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    $AccessType | Should -Be $accessType
                    $StorageContext | Should -be $expectedStorageContext
                    $TargetContainerName | Should -Be $targetContainerName
                    $TargetBlobName | Should -BeNullOrEmpty 
                    $PassThru | Should -Be $false
                    $DefaultProfile | Should -Be $null }

                # Act
                Backup-AzApiManagementService -ResourceGroupName $resourceGroup -StorageAccountResourceGroup $storageAccountResourceGroup -StorageAccountName $expectedStorageAccountName -ServiceName $serviceName -ContainerName $targetContainerName -AccessType $accessType

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Backup-AzApiManagement -Times 1
            }
            It "Backs up API management with target blob name" {
                # Arrange
                $resourceGroup = "shopping"
                $storageAccountResourceGroup = "stock"
                $serviceName = "shopping-API-management"
                $targetContainerName = "backup-storage"
                $targetBlobName = "backup-storage-blob"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)
                $accessType = 'SystemAssignedManagedIdentity'

                Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $expectedStorageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $expectedStorageContext }
                Mock Backup-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    $AccessType | Should -Be $accessType
                    $StorageContext | Should -be $expectedStorageContext
                    $TargetContainerName | Should -Be $targetContainerName
                    $TargetBlobName | Should -Be $targetBlobName
                    $PassThru | Should -Be $false
                    $DefaultProfile | Should -Be $null }

                # Act
                Backup-AzApiManagementService -ResourceGroupName $resourceGroup -StorageAccountResourceGroup $storageAccountResourceGroup -StorageAccountName $expectedStorageAccountName -ServiceName $serviceName -ContainerName $targetContainerName -BlobName $targetBlobName -AccessType $accessType

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Backup-AzApiManagement -Times 1
            }
            It "Backs up API management with pass thru" {
                # Arrange
                $resourceGroup = "shopping"
                $storageAccountResourceGroup = "stock"
                $serviceName = "shopping-API-management"
                $targetContainerName = "backup-storage"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)
                $accessType = 'SystemAssignedManagedIdentity'

                Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $expectedStorageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $expectedStorageContext }
                Mock Backup-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    $AccessType | Should -Be $accessType
                    $StorageContext | Should -be $expectedStorageContext
                    $TargetContainerName | Should -Be $targetContainerName
                    $TargetBlobName | Should -BeNullOrEmpty 
                    $PassThru | Should -Be $true
                    $DefaultProfile | Should -Be $null }

                # Act
                Backup-AzApiManagementService -ResourceGroupName $resourceGroup -StorageAccountResourceGroup $storageAccountResourceGroup -StorageAccountName $expectedStorageAccountName -ServiceName $serviceName -ContainerName $targetContainerName -AccessType $accessType -PassThru

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Backup-AzApiManagement -Times 1
            }
            It "Backs up API management with default profile" {
                # Arrange
                $resourceGroup = "shopping"
                $storageAccountResourceGroup = "stock"
                $serviceName = "shopping-API-management"
                $targetContainerName = "backup-storage"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)
                $defaultProfile = New-Object -TypeName Microsoft.Azure.Commands.Common.Authentication.Models.AzureRmProfile
                $accessType = 'SystemAssignedManagedIdentity'

                Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $expectedStorageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $expectedStorageContext }
                Mock Backup-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    $AccessType | Should -Be $accessType
                    $StorageContext | Should -be $expectedStorageContext
                    $TargetContainerName | Should -Be $targetContainerName
                    $TargetBlobName | Should -BeNullOrEmpty 
                    $PassThru | Should -Be $true
                    $DefaultProfile | Should -Be $defaultProfile }

                # Act
                Backup-AzApiManagementService -ResourceGroupName $resourceGroup -StorageAccountResourceGroup $storageAccountResourceGroup -StorageAccountName $expectedStorageAccountName -ServiceName $serviceName -ContainerName $targetContainerName -AccessType $accessType -PassThru -DefaultProfile $defaultProfile

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Backup-AzApiManagement -Times 1
            }
            It "Backs up API management with User Assigned Managed Identity" {
                # Arrange
                $resourceGroup = "shopping"
                $storageAccountResourceGroup = "stock"
                $serviceName = "shopping-API-management"
                $targetContainerName = "backup-storage"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)
                $accessType = 'UserAssignedManagedIdentity'
                $identityClientId = 'someidentityid'

                Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $expectedStorageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $expectedStorageContext }
                Mock Backup-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    $AccessType | Should -Be $accessType
                    $IdentityClientId | Should -Be $identityClientId
                    $StorageContext | Should -be $expectedStorageContext
                    $TargetContainerName | Should -Be $targetContainerName
                    $TargetBlobName | Should -BeNullOrEmpty 
                    $PassThru | Should -Be $false
                    $DefaultProfile | Should -Be $null }

                # Act
                Backup-AzApiManagementService -ResourceGroupName $resourceGroup -StorageAccountResourceGroup $storageAccountResourceGroup -StorageAccountName $expectedStorageAccountName -ServiceName $serviceName -ContainerName $targetContainerName -AccessType $accessType -IdentityClientId $identityClientId

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Backup-AzApiManagement -Times 1
            }
        }
        Context "Import Azure API Management operation" {
            It "Calls new operation on Azure API Management operation w/o policy" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $apiId = "shopping-API"
                $operationId = "orders"
                $method = "POST"
                $urlTemplate = "https://{host}.com/{path}{query}"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
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
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Get-AzApiManagement -Times 1
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
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
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
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled New-AzApiManagementContext -Times 1
                Assert-MockCalled New-AzApiManagementOperation -Times 1
                Assert-MockCalled Set-AzApiManagementPolicy -Times 1
            }
        }
        Context "Import Azure API Management product policy" {
            It "Importing policy product sets Azure API Management policy on operation" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $productId = "shopping-API"
                $policyFilePath = "/file-path/operation-policy"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
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
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
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
        } 
        Context "Remove Azure API Management defaults" {
            It "Remove API Management defaults succeed" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Get-AzApiManagementApi {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ApiId -eq "echo-api" }
                Mock Remove-AzApiManagementApi {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ApiId -eq "echo-api" }
                Mock Get-AzApiManagementProduct {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
                Mock Get-AzApiManagementProduct {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "unlimited" }
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "unlimited" }

                # Act
                Remove-AzApiManagementDefaults -ResourceGroupName $resourceGroup -ServiceName $serviceName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Get-AzApiManagementApi -Times 1 -ParameterFilter { $ApiId -eq "echo-api" }
                Assert-MockCalled Remove-AzApiManagementApi -Times 1 -ParameterFilter { $ApiId -eq "echo-api" }
                Assert-MockCalled Get-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
                Assert-MockCalled Get-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "unlimited" }
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "unlimited" }
            }
            It "Remove API Management defaults when echo-api API failed to remove, throws" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Get-AzApiManagementApi {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ApiId -eq "echo-api" }
                Mock Remove-AzApiManagementApi {
                    $Context | Should -Be $context
                    throw } -Verifiable -ParameterFilter { $ApiId -eq "echo-api" }

                # Act
                { Remove-AzApiManagementDefaults -ResourceGroupName $resourceGroup -ServiceName $serviceName } |
                Should -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Get-AzApiManagementApi -Times 1 -ParameterFilter { $ApiId -eq "echo-api" }
                Assert-MockCalled Remove-AzApiManagementApi -Times 1 -ParameterFilter { $ApiId -eq "echo-api" }
            }
            It "Remove API Management defaults when starter product failed to remove, throws" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Get-AzApiManagementApi {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ApiId -eq "echo-api" }
                Mock Remove-AzApiManagementApi {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ApiId -eq "echo-api" }
                Mock Get-AzApiManagementProduct {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    throw } -Verifiable -ParameterFilter { $ProductId -eq "starter" }

                # Act
                { Remove-AzApiManagementDefaults -ResourceGroupName $resourceGroup -ServiceName $serviceName } |
                Should -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Get-AzApiManagementApi -Times 1 -ParameterFilter { $ApiId -eq "echo-api" }
                Assert-MockCalled Remove-AzApiManagementApi -Times 1 -ParameterFilter { $ApiId -eq "echo-api" }
                Assert-MockCalled Get-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
            }
            It "Remove API Management defaults when unlimited product failed to remove, throws" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Get-AzApiManagementApi {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ApiId -eq "echo-api" }
                Mock Remove-AzApiManagementApi {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ApiId -eq "echo-api" }
                Mock Get-AzApiManagementProduct {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
                Mock Get-AzApiManagementProduct {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "unlimited" }
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    throw } -Verifiable -ParameterFilter { $ProductId -eq "unlimited" }

                # Act
                { Remove-AzApiManagementDefaults -ResourceGroupName $resourceGroup -ServiceName $serviceName } |
                Should -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Get-AzApiManagementApi -Times 1 -ParameterFilter { $ApiId -eq "echo-api" }
                Assert-MockCalled Remove-AzApiManagementApi -Times 1 -ParameterFilter { $ApiId -eq "echo-api" }
                Assert-MockCalled Get-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
                Assert-MockCalled Get-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "unlimited" }
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "unlimited" }
            }
            It "Remove API Management defaults succeed when echo-api API has already been removed" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Get-AzApiManagementApi {
                    $Context | Should -Be $context
                    $errorDetails = '{"code": 1, "message": "NotFound", "more_info": "", "status": 404}'
                    $statusCode = 404
                    $response = New-Object System.Net.Http.HttpResponseMessage $statusCode
                    $exception = New-Object Microsoft.PowerShell.Commands.HttpResponseException "$statusCode ($($response.ReasonPhrase))", $response
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation
                    $errorID = 'WebCmdletWebResponseException,Microsoft.PowerShell.Commands.InvokeWebRequestCommand'
                    $targetObject = $null
                    $errorRecord = New-Object Management.Automation.ErrorRecord $exception, $errorID, $errorCategory, $targetObject
                    $errorRecord.ErrorDetails = $errorDetails
                    Throw $errorRecord } -Verifiable -ParameterFilter { $ApiId -eq "echo-api" }
                Mock Get-AzApiManagementProduct {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
                Mock Get-AzApiManagementProduct {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "unlimited" }
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "unlimited" }

                # Act
                Remove-AzApiManagementDefaults -ResourceGroupName $resourceGroup -ServiceName $serviceName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Get-AzApiManagementApi -Times 1 -ParameterFilter { $ApiId -eq "echo-api" }
                Assert-MockCalled Get-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
                Assert-MockCalled Get-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "unlimited" }
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "unlimited" }
            }
            It "Remove API Management defaults succeed when starter product has already been removed" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Get-AzApiManagementApi {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ApiId -eq "echo-api" }
                Mock Remove-AzApiManagementApi {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ApiId -eq "echo-api" }
                Mock Get-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $errorDetails = '{"code": 1, "message": "NotFound", "more_info": "", "status": 404}'
                    $statusCode = 404
                    $response = New-Object System.Net.Http.HttpResponseMessage $statusCode
                    $exception = New-Object Microsoft.PowerShell.Commands.HttpResponseException "$statusCode ($($response.ReasonPhrase))", $response
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation
                    $errorID = 'WebCmdletWebResponseException,Microsoft.PowerShell.Commands.InvokeWebRequestCommand'
                    $targetObject = $null
                    $errorRecord = New-Object Management.Automation.ErrorRecord $exception, $errorID, $errorCategory, $targetObject
                    $errorRecord.ErrorDetails = $errorDetails
                    Throw $errorRecord } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
                Mock Get-AzApiManagementProduct {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "unlimited" }
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "unlimited" }

                # Act
                Remove-AzApiManagementDefaults -ResourceGroupName $resourceGroup -ServiceName $serviceName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Get-AzApiManagementApi -Times 1 -ParameterFilter { $ApiId -eq "echo-api" }
                Assert-MockCalled Remove-AzApiManagementApi -Times 1 -ParameterFilter { $ApiId -eq "echo-api" }
                Assert-MockCalled Get-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
                Assert-MockCalled Get-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "unlimited" }
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "unlimited" }
            }
            It "Remove API Management defaults succeed when unlimited product has already been removed" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Get-AzApiManagementApi {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ApiId -eq "echo-api" }
                Mock Remove-AzApiManagementApi {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ApiId -eq "echo-api" }
                Mock Get-AzApiManagementProduct {
                    $Context | Should -Be $context
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
                Mock Remove-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $DeleteSubscriptions | Should -Be $true
                    return $null } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
                Mock Get-AzApiManagementProduct {
                    $Context | Should -Be $context
                    $errorDetails = '{"code": 1, "message": "NotFound", "more_info": "", "status": 404}'
                    $statusCode = 404
                    $response = New-Object System.Net.Http.HttpResponseMessage $statusCode
                    $exception = New-Object Microsoft.PowerShell.Commands.HttpResponseException "$statusCode ($($response.ReasonPhrase))", $response
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation
                    $errorID = 'WebCmdletWebResponseException,Microsoft.PowerShell.Commands.InvokeWebRequestCommand'
                    $targetObject = $null
                    $errorRecord = New-Object Management.Automation.ErrorRecord $exception, $errorID, $errorCategory, $targetObject
                    $errorRecord.ErrorDetails = $errorDetails
                    Throw $errorRecord } -Verifiable -ParameterFilter { $ProductId -eq "unlimited" }

                # Act
                Remove-AzApiManagementDefaults -ResourceGroupName $resourceGroup -ServiceName $serviceName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Get-AzApiManagementApi -Times 1 -ParameterFilter { $ApiId -eq "echo-api" }
                Assert-MockCalled Remove-AzApiManagementApi -Times 1 -ParameterFilter { $ApiId -eq "echo-api" }
                Assert-MockCalled Get-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
                Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
                Assert-MockCalled Get-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "unlimited" }
            }
        } 
        Context "Import Azure API Management API policy" {
            It "Importing policy API sets API Management policy on operation" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $apiId = "shopping-API"
                $policyFilePath = "/file-path/operation-policy"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
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
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
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
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled New-AzApiManagementContext -Times 1
                Assert-MockCalled Set-AzApiManagementPolicy -Times 1
            }
        } 
        Context "Import Azure API Management operation policy" {
            It "Importing policy operation sets Azure API Management policy on operation" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $apiId = "shopping-API"
                $operationId = "orders"
                $policyFilePath = "/file-path/operation-policy"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
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
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
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
        }
        Context "Restore Azure API Management instance" {
            BeforeEach {
                # Test values, not really pointing to anything
                $expectedStorageAccountName = "shopping-storage"
                $storageKeyValue = "mystoragekey"
                $expectedStorageContext = New-AzStorageContext -StorageAccountName $expectedStorageAccountName -StorageAccountKey $storageKeyValue
            }
            It "Restores API management service w/o pass thru and profile" {
                # Arrange
                $resourceGroup = "shopping"
                $storageAccountResourceGroup = "stock"
                $serviceName = "shopping-API-management"
                $containerName = "backup-storage"
                $blobName = "backup-storage-blob"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)

                Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $expectedStorageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $expectedStorageContext }
                Mock Restore-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    $StorageContext | Should -be $expectedStorageContext
                    $SourceContainerName | Should -Be $containerName
                    $SourceBlobName | Should -Be $blobName
                    $PassThru | Should -Be $false
                    $DefaultProfile | Should -Be $null }

                # Act
                Restore-AzApiManagementService -ResourceGroupName $resourceGroup -StorageAccountResourceGroupName $storageAccountResourceGroup -StorageAccountName $expectedStorageAccountName -ServiceName $serviceName -ContainerName $containerName -BlobName $blobName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Restore-AzApiManagement -Times 1
            }
            It "Restores API management service w/ pass thru and w/o profile" {
                # Arrange
                $resourceGroup = "shopping"
                $storageAccountResourceGroup = "stock"
                $serviceName = "shopping-API-management"
                $containerName = "backup-storage"
                $blobName = "backup-storage-blob"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)

                Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $expectedStorageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $expectedStorageContext }
                Mock Restore-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    $StorageContext | Should -be $expectedStorageContext
                    $SourceContainerName | Should -Be $containerName
                    $SourceBlobName | Should -Be $blobName 
                    $PassThru | Should -Be $true
                    $DefaultProfile | Should -Be $null }

                # Act
                Restore-AzApiManagementService -ResourceGroupName $resourceGroup -StorageAccountResourceGroupName $storageAccountResourceGroup -StorageAccountName $expectedStorageAccountName -ServiceName $serviceName -ContainerName $containerName -BlobName $blobName -PassThru

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Restore-AzApiManagement -Times 1
            }
            It "Restores API management service w/o pass thru and w/ profile" {
                # Arrange
                $resourceGroup = "shopping"
                $storageAccountResourceGroup = "stock"
                $serviceName = "shopping-API-management"
                $containerName = "backup-storage"
                $blobName = "backup-storage-blob"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)
                $defaultProfile = New-Object -TypeName Microsoft.Azure.Commands.Common.Authentication.Models.AzureRmProfile

                Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $expectedStorageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $expectedStorageContext }
                Mock Restore-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    $StorageContext | Should -be $expectedStorageContext
                    $SourceContainerName | Should -Be $containerName
                    $SourceBlobName | Should -Be $blobName 
                    $PassThru | Should -Be $false
                    $DefaultProfile | Should -Be $defaultProfile }

                # Act
                Restore-AzApiManagementService -ResourceGroupName $resourceGroup -StorageAccountResourceGroupName $storageAccountResourceGroup -StorageAccountName $expectedStorageAccountName -ServiceName $serviceName -ContainerName $containerName -BlobName $blobName -DefaultProfile $defaultProfile

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Restore-AzApiManagement -Times 1
            }
            It "Restores API management service w/ pass thru and profile" {
                # Arrange
                $resourceGroup = "shopping"
                $storageAccountResourceGroup = "stock"
                $serviceName = "shopping-API-management"
                $containerName = "backup-storage"
                $blobName = "backup-storage-blob"
                $storageKey = New-Object -TypeName Microsoft.Azure.Management.Storage.Models.StorageAccountKey -ArgumentList @($null, $storageKeyValue, $null)
                $defaultProfile = New-Object -TypeName Microsoft.Azure.Commands.Common.Authentication.Models.AzureRmProfile

                Mock Get-AzStorageAccountKey {
                    $ResourceGroupName | Should -Be $storageAccountResourceGroup
                    $StorageAccountName | Should -Be $expectedStorageAccountName
                    return $storageKey }
                Mock New-AzStorageContext { 
                    $StorageAccountName | Should -Be $StorageAccountName
                    $StorageAccountKey | Should -Be $storageKeyValue
                    return $expectedStorageContext }
                Mock Restore-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    $StorageContext | Should -be $expectedStorageContext
                    $SourceContainerName | Should -Be $containerName
                    $SourceBlobName | Should -Be $blobName 
                    $PassThru | Should -Be $true
                    $DefaultProfile | Should -Be $defaultProfile }

                # Act
                Restore-AzApiManagementService -ResourceGroupName $resourceGroup -StorageAccountResourceGroupName $storageAccountResourceGroup -StorageAccountName $expectedStorageAccountName -ServiceName $serviceName -ContainerName $containerName -BlobName $blobName -PassThru -DefaultProfile $defaultProfile

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzStorageAccountKey -Times 1
                Assert-MockCalled New-AzStorageContext -Times 1
                Assert-MockCalled Restore-AzApiManagement -Times 1
            }
        }
        Context "Set Azure API Management API subscription key" {
            It "Sets subscription keys on an API in Azure API Management" {
                # Arrange
                $resourceGroup = "shopping"
                $serviceName = "shopping-API-management"
                $apiId = "shopping-API"
                $apiKeyHeaderName = "header-name"
                $apiKeyQueryParamName = "query-param-name"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
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
        Context "Upload Azure API Management certificate" {
            It "Uploads private certificate to API Management" {
                # Arrange
                $resourceGroup = "customer"
                $name = "customer-name"
                $filePath = "c:\temp\certificate.pfx"
                $password = "P@ssw0rd"
                $stubContext = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable

                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $name
                    return $stubContext } -Verifiable

                Mock New-AzApiManagementCertificate {
                    $Context | Should -Be $stubContext
                    $PfxFilePath | Should -Be $filePath
                    $PfxPassword | Should -Be $password } -Verifiable

                # Act
                Upload-AzApiManagementCertificate -ResourceGroupName $resourceGroup -ServiceName $name -CertificateFilePath $filePath -CertificatePassword $password

                # Assert
                Assert-VerifiableMock
            }
        }
        Context "Upload Azure API Management system certificate" {
            It "Uploads public CA certificate to Azure API Management in-process" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $certificateFile = "c:\temp\certificate.cer"
                $stubCertificate = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagementSystemCertificate
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock New-AzApiManagementSystemCertificate {
                    $StoreName | Should -Be "Root"
                    $PfxPath | Should -Be $certificateFile
                    return $stubCertificate } -Verifiable
                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Set-AzApiManagement {
                    $InputObject | Should -Be $stubApiManagement
                    $AsJob | Should -Be $false } -Verifiable

                # Act
                Upload-AzApiManagementSystemCertificate `
                    -ResourceGroupName $resourceGroup `
                    -ServiceName $serviceName `
                    -CertificateFilePath $certificateFile

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled New-AzApiManagementSystemCertificate -Times 1
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Set-AzApiManagement -Times 1
            }
            It "Uploads public CA certificate to Azure API Management out-of-process" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $certificateFile = "c:\temp\certificate.cer"
                $stubCertificate = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagementSystemCertificate
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock New-AzApiManagementSystemCertificate {
                    $StoreName | Should -Be "Root"
                    $PfxPath | Should -Be $certificateFile
                    return $stubCertificate } -Verifiable
                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Set-AzApiManagement {
                    $InputObject | Should -Be $stubApiManagement
                    $AsJob | Should -Be $true } -Verifiable

                # Act
                Upload-AzApiManagementSystemCertificate `
                    -ResourceGroupName $resourceGroup `
                    -ServiceName $serviceName `
                    -CertificateFilePath $certificateFile `
                    -AsJob

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled New-AzApiManagementSystemCertificate -Times 1
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Set-AzApiManagement -Times 1
            }
            It "Uploads public CA certificate to non-existing Azure API Management in-porcess fails" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $certificateFile = "c:\temp\certificate.cer"
                $stubCertificate = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagementSystemCertificate

                Mock New-AzApiManagementSystemCertificate {
                    $StoreName | Should -Be "Root"
                    $PfxPath | Should -Be $certificateFile
                    return $stubCertificate } -Verifiable
                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $null } -Verifiable
                Mock Set-AzApiManagement { }

                # Act
                { Upload-AzApiManagementSystemCertificate `
                        -ResourceGroupName $resourceGroup `
                        -ServiceName $serviceName `
                        -CertificateFilePath $certificateFile } | Should -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled New-AzApiManagementSystemCertificate -Times 1
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Set-AzApiManagement -Times 0
            }
            It "Uploads public CA certificate to non-existing Azure API Management out-of-porcess fails" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $certificateFile = "c:\temp\certificate.cer"
                $stubCertificate = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagementSystemCertificate

                Mock New-AzApiManagementSystemCertificate {
                    $StoreName | Should -Be "Root"
                    $PfxPath | Should -Be $certificateFile
                    return $stubCertificate } -Verifiable
                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $null } -Verifiable
                Mock Set-AzApiManagement { }

                # Act
                { Upload-AzApiManagementSystemCertificate `
                        -ResourceGroupName $resourceGroup `
                        -ServiceName $serviceName `
                        -CertificateFilePath $certificateFile `
                        -AsJob } | Should -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled New-AzApiManagementSystemCertificate -Times 1
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Set-AzApiManagement -Times 0
            }
        }
        Context "Create Azure API Management User" {
            It "Inviting a user in Azure API Management is OK" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $firstName = "John"
                $lastName = "Doe"
                $mailAddress = "john.doe@contoso.com"
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Invoke-WebRequest -MockWith {
                    $status = [System.Net.WebExceptionStatus]::Success
                    $response = New-Object -type 'System.Net.HttpWebResponse'
                    $response | Add-Member -MemberType noteProperty -Name 'StatusCode' -Value 200 -force

                    return $response
                }
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken    = "accessToken"
                    }
                }

                # Act
                Create-AzApiManagementUserAccount `
                    -ResourceGroupName $resourceGroup `
                    -ServiceName $serviceName `
                    -FirstName $firstName `
                    -LastName $lastName `
                    -MailAddress $mailAddress

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Invoke-WebRequest -Times 1 -ParameterFilter { 
                    ($Body | ConvertFrom-Json).properties.firstName -eq $firstName -and
                    ($Body | ConvertFrom-Json).properties.lastName -eq $lastName -and
                    ($Body | ConvertFrom-Json).properties.email -eq $mailAddress -and
                    ($Body | ConvertFrom-Json).properties.confirmation -eq 'invite'
                }
            }
            It "Signup a user in Azure API Management without a password is OK" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $firstName = "John"
                $lastName = "Doe"
                $mailAddress = "john.doe@contoso.com"
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Invoke-WebRequest -MockWith {
                    $status = [System.Net.WebExceptionStatus]::Success
                    $response = New-Object -type 'System.Net.HttpWebResponse'
                    $response | Add-Member -MemberType noteProperty -Name 'StatusCode' -Value 200 -force

                    return $response
                } -Verifiable 
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken    = "accessToken"
                    }
                }

                # Act
                Create-AzApiManagementUserAccount `
                    -ResourceGroupName $resourceGroup `
                    -ServiceName $serviceName `
                    -FirstName $firstName `
                    -LastName $lastName `
                    -MailAddress $mailAddress `
                    -ConfirmationType 'signup'

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Invoke-WebRequest -Times 1 -ParameterFilter { 
                    ($Body | ConvertFrom-Json).properties.firstName -eq $firstName -and
                    ($Body | ConvertFrom-Json).properties.lastName -eq $lastName -and
                    ($Body | ConvertFrom-Json).properties.email -eq $mailAddress -and
                    ($Body | ConvertFrom-Json).properties.confirmation -eq 'signup'
                }
            }
            It "Signup a user in Azure API Management with a password is OK" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $firstName = "John"
                $lastName = "Doe"
                $mailAddress = "john.doe@contoso.com"
                $password = "testpassword"
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Invoke-WebRequest -MockWith {
                    $status = [System.Net.WebExceptionStatus]::Success
                    $response = New-Object -type 'System.Net.HttpWebResponse'
                    $response | Add-Member -MemberType noteProperty -Name 'StatusCode' -Value 200 -force

                    return $response
                }
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken    = "accessToken"
                    }
                }

                # Act
                Create-AzApiManagementUserAccount `
                    -ResourceGroupName $resourceGroup `
                    -ServiceName $serviceName `
                    -FirstName $firstName `
                    -LastName $lastName `
                    -MailAddress $mailAddress `
                    -ConfirmationType 'signup' `
                    -Password $password

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Invoke-WebRequest -Times 1 -ParameterFilter { 
                    ($Body | ConvertFrom-Json).properties.firstName -eq $firstName -and
                    ($Body | ConvertFrom-Json).properties.lastName -eq $lastName -and
                    ($Body | ConvertFrom-Json).properties.email -eq $mailAddress -and
                    ($Body | ConvertFrom-Json).properties.confirmation -eq 'signup' -and 
                    ($Body | ConvertFrom-Json).properties.password -eq $password
                }
            }
            It "Inviting a user in Azure API Management with a notification is OK" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $firstName = "John"
                $lastName = "Doe"
                $mailAddress = "john.doe@contoso.com"
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Invoke-WebRequest -MockWith {
                    $status = [System.Net.WebExceptionStatus]::Success
                    $response = New-Object -type 'System.Net.HttpWebResponse'
                    $response | Add-Member -MemberType noteProperty -Name 'StatusCode' -Value 200 -force

                    return $response
                }
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken    = "accessToken"
                    }
                }

                # Act
                Create-AzApiManagementUserAccount `
                    -ResourceGroupName $resourceGroup `
                    -ServiceName $serviceName `
                    -FirstName $firstName `
                    -LastName $lastName `
                    -MailAddress $mailAddress `
                    -SendNotification

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Invoke-WebRequest -Times 1 -ParameterFilter { 
                    ($Body | ConvertFrom-Json).properties.firstName -eq $firstName -and
                    ($Body | ConvertFrom-Json).properties.lastName -eq $lastName -and
                    ($Body | ConvertFrom-Json).properties.email -eq $mailAddress -and
                    ($Body | ConvertFrom-Json).properties.confirmation -eq 'invite' -and
                    $Uri -like '*notify=True*'
                }
            }
            It "Inviting a user in Azure API Management and include a note is OK" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $firstName = "John"
                $lastName = "Doe"
                $mailAddress = "john.doe@contoso.com"
                $note = 'this is a note'
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Invoke-WebRequest -MockWith {
                    $status = [System.Net.WebExceptionStatus]::Success
                    $response = New-Object -type 'System.Net.HttpWebResponse'
                    $response | Add-Member -MemberType noteProperty -Name 'StatusCode' -Value 200 -force

                    return $response
                }
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken    = "accessToken"
                    }
                }

                # Act
                Create-AzApiManagementUserAccount `
                    -ResourceGroupName $resourceGroup `
                    -ServiceName $serviceName `
                    -FirstName $firstName `
                    -LastName $lastName `
                    -MailAddress $mailAddress `
                    -Note $note

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Invoke-WebRequest -Times 1 -ParameterFilter { 
                    ($Body | ConvertFrom-Json).properties.firstName -eq $firstName -and
                    ($Body | ConvertFrom-Json).properties.lastName -eq $lastName -and
                    ($Body | ConvertFrom-Json).properties.email -eq $mailAddress -and
                    ($Body | ConvertFrom-Json).properties.confirmation -eq 'invite' -and
                    ($Body | ConvertFrom-Json).properties.note -eq $note
                }
            }
            It "Inviting a user in Azure API Management and specify a UserId is OK" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $firstName = "John"
                $lastName = "Doe"
                $mailAddress = "john.doe@contoso.com"
                $userId = '12345'
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock Invoke-WebRequest -MockWith {
                    $status = [System.Net.WebExceptionStatus]::Success
                    $response = New-Object -type 'System.Net.HttpWebResponse'
                    $response | Add-Member -MemberType noteProperty -Name 'StatusCode' -Value 200 -force

                    return $response
                }
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken    = "accessToken"
                    }
                }

                # Act
                Create-AzApiManagementUserAccount `
                    -ResourceGroupName $resourceGroup `
                    -ServiceName $serviceName `
                    -FirstName $firstName `
                    -LastName $lastName `
                    -MailAddress $mailAddress `
                    -UserId $userId

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Invoke-WebRequest -Times 1 -ParameterFilter { 
                    ($Body | ConvertFrom-Json).properties.firstName -eq $firstName -and
                    ($Body | ConvertFrom-Json).properties.lastName -eq $lastName -and
                    ($Body | ConvertFrom-Json).properties.email -eq $mailAddress -and
                    ($Body | ConvertFrom-Json).properties.confirmation -eq 'invite' -and
                    $Uri -like "*users/$userId*"
                }
            }
            It "Inviting a user in Azure API Management with wrong confirmation type fails" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $firstName = "John"
                $lastName = "Doe"
                $mailAddress = "john.doe@contoso.com"

                # Act
                { 
                    Create-AzApiManagementUserAccount `
                        -ResourceGroupName $resourceGroup `
                        -ServiceName $serviceName `
                        -FirstName $firstName `
                        -LastName $lastName `
                        -MailAddress $mailAddress `
                        -ConfirmationType 'wrongvalue'
                } | Should -Throw -ExpectedMessage 'Cannot validate argument on parameter ''ConfirmationType''. The argument "wrongvalue" does not belong to the set "invite,signup" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again.'


                # Assert
                Assert-VerifiableMock
            }
            It "Inviting a user in Azure API Management to non-existing Azure API Management fails" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $firstName = "John"
                $lastName = "Doe"
                $mailAddress = "john.doe@contoso.com"

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $null } -Verifiable

                # Act
                { 
                    Create-AzApiManagementUserAccount `
                        -ResourceGroupName $resourceGroup `
                        -ServiceName $serviceName `
                        -FirstName $firstName `
                        -LastName $lastName `
                        -MailAddress $mailAddress
                } | Should -Throw -ExpectedMessage "Unable to find the Azure API Management instance '$($serviceName)' in resource group '$($resourceGroup)'"


                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
            }
        }
        Context "Remove Azure API Management User" {
            It "Removing a user from Azure API Management is OK" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $mailAddress = "john.doe@contoso.com"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement
                $userId = 1
                $apiUser = [pscustomobject] @{
                    UserId = $userId;
                };

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    return $context } -Verifiable
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken    = "accessToken"
                    }
                } 
                Mock Get-AzApiManagementUser {
                    $Context | Should -Be $context
                    $Email | Should -Be $mailAddress
                    return $apiUser } -Verifiable
                Mock Remove-AzApiManagementUser {
                    $Context | Should -Be $context
                    $UserId | Should -Be $userId
                    return $null } -Verifiable

                # Act
                Remove-AzApiManagementUserAccount `
                    -ResourceGroupName $resourceGroup `
                    -ServiceName $serviceName `
                    -MailAddress $mailAddress

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled New-AzApiManagementContext -Times 1
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Get-AzApiManagementUser -Times 1 
                Assert-MockCalled Remove-AzApiManagementUser -Times 1 
            }
            It "Removing a user from Azure API Management that does not exist is OK" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $mailAddress = "john.doe@contoso.com"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    return $context } -Verifiable
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken    = "accessToken"
                    }
                } 
                Mock Get-AzApiManagementUser {
                    $Context | Should -Be $context
                    $Email | Should -Be $mailAddress
                    return $null } -Verifiable

                # Act
                Remove-AzApiManagementUserAccount `
                    -ResourceGroupName $resourceGroup `
                    -ServiceName $serviceName `
                    -MailAddress $mailAddress

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled New-AzApiManagementContext -Times 1
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Get-AzApiManagementUser -Times 1 
            }
            It "Removing a user from a non-existing Azure API Management fails" {
                # Arrange
                $resourceGroup = "contoso"
                $serviceName = "contosoApi"
                $mailAddress = "john.doe@contoso.com"

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $null } -Verifiable

                # Act
                { 
                    Remove-AzApiManagementUserAccount `
                        -ResourceGroupName $resourceGroup `
                        -ServiceName $serviceName `
                        -MailAddress $mailAddress
                } | Should -Throw -ExpectedMessage "Unable to find the Azure API Management instance '$serviceName' in resource group '$resourceGroup'"


                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
            }
        }
        Context "Create Azure API Management User From Config" {
            It "Applying user configuration to Azure API Management with a config file that does not exist fails" {
                # Arrange
                $resourceGroup = "SomeResourceGroup"
                $serviceName = "SomeServiceName"
                $configFile = ".\SomeFileThatDoesNotExist.json"

                # Act
                { Create-AzApiManagementUserAccountsFromConfig -ResourceGroupName $resourceGroup -ServiceName $serviceName -ConfigurationFile $configFile } |
                Should -Throw -ExpectedMessage "Cannot apply user configuration to Azure API Management instance '$serviceName' in resource group '$resourceGroup' based on JSON configuration file because no file was found at: '$configFile'"
            }
            It "Applying user configuration to Azure API Management with a config file that is empty fails" {
                # Arrange    
                $resourceGroup = "SomeResourceGroup"
                $serviceName = "SomeServiceName"
                $configFile = "$PSScriptRoot\Files\ApiManagement\create-azapimanagementuseraccountsfromconfig-config-empty.json"

                # Act
                { Create-AzApiManagementUserAccountsFromConfig -ResourceGroupName $resourceGroup -ServiceName $serviceName -ConfigurationFile $configFile } |
                Should -Throw -ExpectedMessage "Cannot apply user configuration to Azure API Management instance '$serviceName' in resource group '$resourceGroup' based on JSON configuration file because the file is empty."
            }
            It "Applying user configuration to Azure API Management with a config file that is not valid JSON fails" {
                # Arrange
                $resourceGroup = "SomeResourceGroup"
                $serviceName = "SomeServiceName"
                $configFile = "$PSScriptRoot\Files\ApiManagement\create-azapimanagementuseraccountsfromconfig-config-invalid.json"

                # Act
                { Create-AzApiManagementUserAccountsFromConfig -ResourceGroupName $resourceGroup -ServiceName $serviceName -ConfigurationFile $configFile } |
                Should -Throw -ExpectedMessage "Cannot apply user configuration to Azure API Management instance '$serviceName' in resource group '$resourceGroup' based on JSON configuration file because the file does not contain a valid JSON configuration file."
            }
            It "Applying user configuration to a non-existant Azure API Management fails" {
                # Arrange
                $resourceGroup = "SomeResourceGroup"
                $serviceName = "SomeServiceName"
                $configFile = "$PSScriptRoot\Files\ApiManagement\create-azapimanagementuseraccountsfromconfig-config-basic.json"

                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $null } -Verifiable

                # Act
                { Create-AzApiManagementUserAccountsFromConfig -ResourceGroupName $resourceGroup -ServiceName $serviceName -ConfigurationFile $configFile } |
                Should -Throw -ExpectedMessage "Unable to find the Azure API Management instance '$serviceName' in resource group '$resourceGroup'"
                
                #Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1

            }
            It "Applying user configuration to Azure API Management with a basic config file is OK" {
                # Arrange
                $resourceGroup = "SomeResourceGroup"
                $serviceName = "SomeServiceName"
                $configFile = "$PSScriptRoot\Files\ApiManagement\create-azapimanagementuseraccountsfromconfig-config-basic.json"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement

                $userIds = @()
                $firstNames = @()
                $lastNames = @()
                $mailAddressess = @()
                $notes = @()

                $configFileJson = Get-Content $configFile | Out-String | ConvertFrom-Json
                $configFileJson | ForEach-Object { 
                    $userIds += $_.userId
                    $firstNames += $_.firstName
                    $lastNames += $_.lastName
                    $mailAddressess += $_.mailAddress
                    $notes += $_.note
                }

                Mock Write-Host {}
                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    return $context } -Verifiable
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken    = "accessToken"
                    }
                } 
                Mock Create-AzApiManagementUserAccount -MockWith {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    $UserId | Should -BeIn $userIds
                    $FirstName | Should -BeIn $firstNames
                    $LastName | Should -BeIn $lastNames
                    $MailAddress | Should -BeIn $mailAddressess
                    $Note | Should -BeIn $notes
                    return 'some-id'
                } -Verifiable

                # Act
                Create-AzApiManagementUserAccountsFromConfig -ResourceGroupName $resourceGroup -ServiceName $serviceName -ConfigurationFile $configFile
                
                #Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled New-AzApiManagementContext -Times 1
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Create-AzApiManagementUserAccount -Times 1
                Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Object -like "User configuration has successfully been applied for user with id '*' to Azure API Management instance '$serviceName' in resource group '$resourceGroup'" }
            }
            It "Applying user configuration to Azure API Management with a complex config file is OK" {
                # Arrange
                $resourceGroup = "SomeResourceGroup"
                $serviceName = "SomeServiceName"
                $configFile = "$PSScriptRoot\Files\ApiManagement\create-azapimanagementuseraccountsfromconfig-config-complex.json"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement
                
                $userIds = @()
                $firstNames = @()
                $lastNames = @()
                $mailAddressess = @()
                $notes = @()
                $groupIds = @()
                $groupDisplayNames = @()
                $groupDescriptions = @()
                $subscriptionIds = @()
                $subscriptionDisplayNames = @()
                $subscriptionScopes = @()

                $configFileJson = Get-Content $configFile | Out-String | ConvertFrom-Json
                $configFileJson | ForEach-Object { 
                    $userIds += $_.userId
                    $firstNames += $_.firstName
                    $lastNames += $_.lastName
                    $mailAddressess += $_.mailAddress
                    $notes += $_.note

                    $_.groups  | ForEach-Object { 
                        $groupIds += $_.id
                        $groupDisplayNames += $_.displayName
                        $groupDescriptions += $_.description
                    }

                    $_.subscriptions  | ForEach-Object { 
                        $subscriptionIds += $_.id
                        $subscriptionDisplayNames += $_.displayName
                        $subscriptionScopes += $_.scope
                    }
                }

                Mock Write-Host {}
                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    return $context } -Verifiable
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken    = "accessToken"
                    }
                } -Verifiable
                Mock Create-AzApiManagementUserAccount -MockWith {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    $UserId | Should -BeIn $userIds
                    $FirstName | Should -BeIn $firstNames
                    $LastName | Should -BeIn $lastNames
                    $MailAddress | Should -BeIn $mailAddressess
                    $Note | Should -BeIn $notes
                    return 'some-userid'
                } -Verifiable
                Mock New-AzApiManagementGroup {
                    $GroupId | Should -BeIn $groupIds
                    $Name | Should -BeIn $groupDisplayNames
                    $Description | Should -BeIn $groupDescriptions
                } -Verifiable
                Mock Add-AzApiManagementUserToGroup {
                    $GroupId | Should -BeIn $groupIds
                    $UserId | Should -BeIn $userIds
                } -Verifiable
                Mock New-AzApiManagementSubscription {
                    $SubscriptionId | Should -BeIn $subscriptionIds
                    $Name | Should -BeIn $subscriptionDisplayNames
                    $Scope | Should -BeIn $subscriptionScopes
                    $UserId | Should -BeIn $userIds
                } -Verifiable

                # Act
                Create-AzApiManagementUserAccountsFromConfig -ResourceGroupName $resourceGroup -ServiceName $serviceName -ConfigurationFile $configFile
                
                #Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled New-AzApiManagementContext -Times 1
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Create-AzApiManagementUserAccount -Times 1
                Assert-MockCalled New-AzApiManagementGroup -Exactly 4
                Assert-MockCalled Add-AzApiManagementUserToGroup -Exactly 4
                Assert-MockCalled New-AzApiManagementSubscription -Exactly 4
                Assert-MockCalled Write-Host -Exactly 2 -ParameterFilter { $Object -like "User configuration has successfully been applied for user with id '*' to Azure API Management instance '$serviceName' in resource group '$resourceGroup'" }
            }
            It "Applying user configuration to Azure API Management with a complex config file and StrictlyFollowConfigurationFile is OK" {
                # Arrange
                $resourceGroup = "SomeResourceGroup"
                $serviceName = "SomeServiceName"
                $configFile = "$PSScriptRoot\Files\ApiManagement\create-azapimanagementuseraccountsfromconfig-config-complex.json"
                $context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
                $stubApiManagement = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.Models.PsApiManagement
                
                $userIds = @()
                $firstNames = @()
                $lastNames = @()
                $mailAddressess = @()
                $notes = @()
                $groupIds = @()
                $groupDisplayNames = @()
                $groupDescriptions = @()
                $subscriptionIds = @()
                $subscriptionDisplayNames = @()
                $subscriptionScopes = @()

                $configFileJson = Get-Content $configFile | Out-String | ConvertFrom-Json
                $configFileJson | ForEach-Object { 
                    $userIds += $_.userId
                    $firstNames += $_.firstName
                    $lastNames += $_.lastName
                    $mailAddressess += $_.mailAddress
                    $notes += $_.note

                    $_.groups  | ForEach-Object { 
                        $groupIds += $_.id
                        $groupDisplayNames += $_.displayName
                        $groupDescriptions += $_.description
                    }

                    $_.subscriptions  | ForEach-Object { 
                        $subscriptionIds += $_.id
                        $subscriptionDisplayNames += $_.displayName
                        $subscriptionScopes += $_.scope
                    }
                }

                Mock Write-Host {}
                Mock Get-AzApiManagement {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $serviceName
                    return $stubApiManagement } -Verifiable
                Mock New-AzApiManagementContext {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    return $context } -Verifiable
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken    = "accessToken"
                    }
                } -Verifiable
                Mock Create-AzApiManagementUserAccount -MockWith {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $ServiceName | Should -Be $serviceName
                    $UserId | Should -BeIn $userIds
                    $FirstName | Should -BeIn $firstNames
                    $LastName | Should -BeIn $lastNames
                    $MailAddress | Should -BeIn $mailAddressess
                    $Note | Should -BeIn $notes
                    return 'some-userid'
                } -Verifiable
                Mock New-AzApiManagementGroup {
                    $GroupId | Should -BeIn $groupIds
                    $Name | Should -BeIn $groupDisplayNames
                    $Description | Should -BeIn $groupDescriptions
                } -Verifiable
                Mock Add-AzApiManagementUserToGroup {
                    $GroupId | Should -BeIn $groupIds
                    $UserId | Should -BeIn $userIds
                } -Verifiable
                Mock New-AzApiManagementSubscription {
                    $SubscriptionId | Should -BeIn $subscriptionIds
                    $Name | Should -BeIn $subscriptionDisplayNames
                    $Scope | Should -BeIn $subscriptionScopes
                    $UserId | Should -BeIn $userIds
                } -Verifiable
                Mock Get-AzApiManagementGroup {
                    $UserId | Should -BeIn $userIds
                } -Verifiable
                Mock Get-AzApiManagementSubscription {
                    $UserId | Should -BeIn $userIds
                } -Verifiable

                # Act
                Create-AzApiManagementUserAccountsFromConfig -ResourceGroupName $resourceGroup -ServiceName $serviceName -ConfigurationFile $configFile -StrictlyFollowConfigurationFile
                
                #Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzApiManagement -Times 1
                Assert-MockCalled New-AzApiManagementContext -Times 1
                Assert-MockCalled Get-AzCachedAccessToken -Times 1
                Assert-MockCalled Create-AzApiManagementUserAccount -Times 1
                Assert-MockCalled New-AzApiManagementGroup -Exactly 4
                Assert-MockCalled Add-AzApiManagementUserToGroup -Exactly 4
                Assert-MockCalled New-AzApiManagementSubscription -Exactly 4
                Assert-MockCalled Get-AzApiManagementGroup -Exactly 2
                Assert-MockCalled Get-AzApiManagementSubscription -Exactly 2
                Assert-MockCalled Write-Host -Exactly 2 -ParameterFilter { $Object -like "User configuration has successfully been applied for user with id '*' to Azure API Management instance '$serviceName' in resource group '$resourceGroup'" }
            }
        }
    }
}
