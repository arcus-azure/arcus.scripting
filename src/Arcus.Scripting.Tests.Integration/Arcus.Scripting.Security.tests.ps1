Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Security -ErrorAction Stop

InModuleScope Arcus.Scripting.Security {
    Describe "Arcus Azure security integration tests" {
        BeforeEach {
            $filePath = "$PSScriptRoot\appsettings.local.json"
            [string]$appsettings = Get-Content $filePath
            $config = ConvertFrom-Json $appsettings

            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
        }
        Context "Assigning new resource group role assignment on an Azure resource" {
            It "Assigning new 'Reader' resource group role assignment on an Azure resource" {
                # Arrange
                $targetResourceGroup = "codit-arcus"
                $sourceResourceGroup = $config.Arcus.ResourceGroupName
                $resource = $config.Arcus.LogicApp.Name
                $objectId = $config.Arcus.ServicePrincipal.ObjectId
                $role = "Reader"

                try {
                    # Act
                    New-AzResourceGroupRoleAssignment `
                        -TargetResourceGroupName $targetResourceGroup `
                        -ObjectId $objectId `
                        -RoleDefinitionName $role

                    # Assert
                    $assignemnt = Get-AzRoleAssignment -ObjectId $objectId -RoleDefinitionName $role
                    $assignemnt | Should -Not -Be $null
                } finally {
                    Remove-AzRoleAssignment -ResourceGroupName $targetResourceGroup -ObjectId $objectId -RoleDefinitionName $role 
                }
            }
        }
    }
}