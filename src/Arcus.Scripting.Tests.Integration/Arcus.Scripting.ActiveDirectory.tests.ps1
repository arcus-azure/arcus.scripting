Import-Module Microsoft.Graph.Applications
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.ActiveDirectory -ErrorAction Stop

InModuleScope Arcus.Scripting.ActiveDirectory {
    Describe "Arcus Azure Active Directory integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
            & $PSScriptRoot\Connect-MgGraphFromConfig.ps1 -config $config
        }
        Context "Add an Active Directory Application Role Assignment" {
            It "Creating a new role and assigning it should succeed" {
                # Arrange
                $MainAppClientId = $config.Arcus.ActiveDirectory.MainAppClientId
                $RoleName = 'SomeRole'
                $ClientAppClientId = $config.Arcus.ActiveDirectory.ClientAppClientId

                try {
                    # Act
                    {
                        Add-AzADAppRoleAssignment -ClientId $MainAppClientId -Role $RoleName -AssignRoleToClientId $ClientAppClientId
                    } | Should -Not -Throw

                    # Assert
                    $adApplication = Get-AzADApplication -Filter "AppId eq '$MainAppClientId'"
                    $RoleName | Should -BeIn $adApplication.AppRole.Value

                    $adServicePrincipal = Get-AzADServicePrincipal -Filter "AppId eq '$MainAppClientId'"
                    $appRoleAssignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $adServicePrincipal.Id
                    $appRoleAssignments.Count | Should -Be 1
                } finally {
                    Remove-AzADAppRoleAssignment -ClientId $MainAppClientId -Role $RoleName -RemoveRoleFromClientId $ClientAppClientId -RemoveRoleIfNoAssignmentsAreLeft
                }
            }
            It "Get the role and assignment should succeed" {
                # Arrange
                $MainAppClientId = $config.Arcus.ActiveDirectory.MainAppClientId
                $RoleName = 'SomeRole'
                $ClientAppClientId = $config.Arcus.ActiveDirectory.ClientAppClientId
                Add-AzADAppRoleAssignment -ClientId $MainAppClientId -Role $RoleName -AssignRoleToClientId $ClientAppClientId

                try {
                    # Act
                    {
                        List-AzADAppRoleAssignments -ClientId $MainAppClientId -RolesAssignedToClientId $ClientAppClientId
                    } | Should -Not -Throw
                } finally {
                    Remove-AzADAppRoleAssignment -ClientId $MainAppClientId -Role $RoleName -RemoveRoleFromClientId $ClientAppClientId -RemoveRoleIfNoAssignmentsAreLeft
                }
            }
            It "Removing a role assignment and role should succeed" {
                # Arrange
                $MainAppClientId = $config.Arcus.ActiveDirectory.MainAppClientId
                $RoleName = 'SomeRole'
                $ClientAppClientId = $config.Arcus.ActiveDirectory.ClientAppClientId
                Add-AzADAppRoleAssignment -ClientId $MainAppClientId -Role $RoleName -AssignRoleToClientId $ClientAppClientId

                # Act
                {
                    Remove-AzADAppRoleAssignment -ClientId $MainAppClientId -Role $RoleName -RemoveRoleFromClientId $ClientAppClientId -RemoveRoleIfNoAssignmentsAreLeft
                } | Should -Not -Throw

                # Assert
                $adApplication = Get-AzADApplication -Filter "AppId eq '$MainAppClientId'"
                $RoleName | Should -Not -BeIn $adApplication.AppRole.Value

                $adServicePrincipal = Get-AzADServicePrincipal -Filter "AppId eq '$MainAppClientId'"
                $appRoleAssignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $adServicePrincipal.Id
                $appRoleAssignments.Count | Should -Be 0
            }
        }
    }
}