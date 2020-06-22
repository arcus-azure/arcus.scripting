using module Az
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.ApiManagement -DisableNameChecking

Describe "Arcus" {
	Context "ApiManagement" {
		InModuleScope Arcus.Scripting.ApiManagement {
			It "Calls new operation on API Management operation w/o policy" {
				# Arrange
				$resourceGroup = "shopping"
				$serviceName = "shopping-API-management"
				$apiId = "shopping-API"
				$operationId = "orders"
				$method = "POST"
				$urlTemplate = "https://{host}.com/{path}{query}"
				$context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext

				Mock New-AzApiManagementContext {
					$ResourceGroup | Should -Be $resourceGroup
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
				Create-AzApiManagementApiOperation -ResourceGroup $resourceGroup -ServiceName $serviceName -ApiId $apiId -OperationId $operationId -Method $method -UrlTemplate $urlTemplate

				# Assert
				Assert-VerifiableMock
				Assert-MockCalled New-AzApiManagementContext -Times 1
				Assert-MockCalled New-AzApiManagementOperation -Times 1
				Assert-MockCalled Set-AzApiManagementPolicy -Times 0
			}
			It "Calls new operation on API Management operation w/ policy" {
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
					$ResourceGroup | Should -Be $resourceGroup
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
				Create-AzApiManagementApiOperation -ResourceGroup $resourceGroup -ServiceName $serviceName -ApiId $apiId -OperationId $operationId -Method $method -UrlTemplate $urlTemplate -OperationName $operationName -Description $Description -PolicyFilePath $policyFilePath

				# Assert
				Assert-VerifiableMock
				Assert-MockCalled New-AzApiManagementContext -Times 1
				Assert-MockCalled New-AzApiManagementOperation -Times 1
				Assert-MockCalled Set-AzApiManagementPolicy -Times 1
			}
			It "Calls removing API Management commands for default products" {
				# Arrange
				$resourceGroup = "shopping"
				$serviceName = "shopping-API-management"
				$context = New-Object -TypeName Microsoft.Azure.Commands.ApiManagement.ServiceManagement.Models.PsApiManagementContext
				Mock New-AzApiManagementContext {
					$ResourceGroup | Should -Be $resourceGroup
					$ServiceName | Should -Be $serviceName
					return $context } -Verifiable
				Mock Remove-AzApiManagementApi {
					$Context | Should -Be $context
					$ApiId | Should -Be "echo-api" } -Verifiable
				Mock Remove-AzApiManagementProduct {
					$Context | Should -Be $context
					$DeleteSubscriptions | Should -Be $true } -Verifiable -ParameterFilter { $ProductId -eq "starter" }
				Mock Remove-AzApiManagementProduct {
					$Context | Should -Be $context
					$DeleteSubscriptions | Should -Be $true } -Verifiable -ParameterFilter { $ProductId -eq "unlimited" }

				# Act
				Remove-AzApiManagementDefaults -ResourceGroup $resourceGroup -ServiceName $serviceName

				# Assert
				Assert-VerifiableMock
				Assert-MockCalled Remove-AzApiManagementApi -Times 1
				Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "starter" }
				Assert-MockCalled Remove-AzApiManagementProduct -Times 1 -ParameterFilter { $ProductId -eq "unlimited" }
			}
		}
	}
}
