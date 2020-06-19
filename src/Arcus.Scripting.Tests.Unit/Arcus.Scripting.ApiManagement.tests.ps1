Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.ApiManagement -ErrorAction Stop

Describe "Arcus" {
	Context "ApiManagement" {
		InModuleScope Arcus.Scripting.ApiMangement {
			It "Calls new operation on API Management operation w/o policy" {
				# Arrange
				$resourceGroup = "shopping"
				$serviceName = "shopping-API-management"
				$apiId = "shopping-API"
				$operationId = "orders"
				$method = "POST"
				$urlTemplate = "https://{host}.com/{path}{query}"
				$context = "API-management-context"

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
			It "Calls new operation on API management operation w/ policy" {
				# Arrange
				$resourceGroup = "shopping"
				$serviceName = "shopping-API-management"
				$apiId = "shopping-API"
				$operationId = "orders"
				$method = "POST"
				$urlTemplate = "https://{host}.com/{path}{query}"
				$context = "API-management-context"
				$operationName = "POSTing orders"
				$description = "API that can process posted orders"
				$policyFilePath = "/file-path/operation-policy"

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
					$Context | Should -Be $context
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
		}
	}
}