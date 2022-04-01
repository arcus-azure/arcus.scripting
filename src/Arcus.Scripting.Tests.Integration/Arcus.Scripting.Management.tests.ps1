Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Management -ErrorAction Stop
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Security -ErrorAction Stop

InModuleScope Arcus.Scripting.Management {
    Describe "Arcus Azure Management integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1 -fileName "appsettings.json"
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
        }
        Context "Remove soft deleted Azure API Management service" {
            It "Providing an API Management name that does not exist as a soft deleted service should fail" {
                # Arrange
                $Name = 'unexisting-apim-instance'

                # Act
                { 
                   Remove-AzApiManagementSoftDeletedService -Name $Name
                } | Should -Throw -ExpectedMessage "API Management instance with name '$Name' is not listed as a soft deleted service and therefore it cannot be removed or restored"
            }
        }
        Context "Restore soft deleted Azure API Management service" {
            It "Providing an API Management name that does not exist as a soft deleted service should fail" {
                # Arrange
                $Name = 'unexisting-apim-instance'

                # Act
                { 
                   Restore-AzApiManagementSoftDeletedService -Name $Name
                } | Should -Throw -ExpectedMessage "API Management instance with name '$Name' is not listed as a soft deleted service and therefore it cannot be removed or restored"
            }
        }
    }
}