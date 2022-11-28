Import-Module Microsoft.Graph.Applications
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.ActiveDirectory -ErrorAction Stop

InModuleScope Arcus.Scripting.ActiveDirectory {
    Describe "Arcus Azure Active Directory integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
        }
        Context "Add an Active Directory Application Role Assignment" {
            It "Creating a new role and assigning it should succeed" {
                # Arrange
                $ClientId = $config.Arcus.ActiveDirectory.MainAppClientId
                $RoleName = 'SomeRole'
                $AssignRoleToClientId = $config.Arcus.ActiveDirectory.ClientAppClientId

                # Act
                {
                   Add-AzADAppRoleAssignment -ClientId $ClientId -Role $RoleName -AssignRoleToClientId $AssignRoleToClientId
                } | Should -Not -Throw

                # Assert
                $adApplication = Get-AzADApplication -Filter "AppId eq '$ClientId'"
                $RoleName | Should -BeIn $adApplication.AppRole.Value

                $adServicePrincipal = Get-AzADServicePrincipal -Filter "AppId eq '$ClientId'"
                $appRoleAssignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $adServicePrincipal.Id
                $appRoleAssignments.Count | Should -Be 1
            }
            It "Get the role and assignment should succeed" {
                # Arrange
                $ClientId = $config.Arcus.ActiveDirectory.MainAppClientId
                $RolesAssignedToClientId = $config.Arcus.ActiveDirectory.ClientAppClientId

                # Act
                {
                   Get-AzADAppRoleAssignments -ClientId $ClientId -RolesAssignedToClientId $RolesAssignedToClientId
                } | Should -Not -Throw
            }
            It "Removing a role assignment and role should succeed" {
                # Arrange
                $ClientId = $config.Arcus.ActiveDirectory.MainAppClientId
                $RoleName = 'SomeRole'
                $RemoveRoleFromClientId = $config.Arcus.ActiveDirectory.ClientAppClientId

                # Act
                {
                   Remove-AzADAppRoleAssignment -ClientId $ClientId -Role $RoleName -RemoveRoleFromClientId $RemoveRoleFromClientId -RemoveRoleIfNoAssignmentsAreLeft
                } | Should -Not -Throw

                # Assert
                $adApplication = Get-AzADApplication -Filter "AppId eq '$ClientId'"
                $RoleName | Should -Not -BeIn $adApplication.AppRole.Value

                $adServicePrincipal = Get-AzADServicePrincipal -Filter "AppId eq '$ClientId'"
                $appRoleAssignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $adServicePrincipal.Id
                $appRoleAssignments.Count | Should -Be 0
            }
        }
    }
}