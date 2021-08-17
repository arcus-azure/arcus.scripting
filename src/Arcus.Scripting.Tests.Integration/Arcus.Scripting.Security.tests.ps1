Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Security -ErrorAction Stop

InModuleScope Arcus.Scripting.Security {
    Describe "Arcus Azure security integration tests" {
        BeforeEach {
            $filePath = "$PSScriptRoot\appsettings.json"
            [string]$appsettings = Get-Content $filePath
            $config = ConvertFrom-Json $appsettings
            
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
        }
        Context "Removing resource locks on Azure resources" {
            It "Newly added resource lock gets removed by removing all resource locks with a given lock name" {
                # Arrange
                $lockName = "NewTestingLockWithName"
                $targetResourceName = $config.Arcus.KeyVault.VaultName
                $targetResourceGroupName = $config.Arcus.ResourceGroupName
                New-AzResourceLock `
                    -ResourceGroupName $targetResourceGroupName `
                    -ResourceName $targetResourceName `
                    -ResourceType "Microsoft.KeyVault/vaults" `
                    -LockName $lockName `
                    -LockLevel CanNotDelete `
                    -Force

                try {
                    # Act
                    Remove-AzResourceGroupLocks -ResourceGroupName $targetResourceGroupName -LockName $lockName
                
                    # Assert
                    $locks = Get-AzResourceLock -ResourceGroupName $targetResourceGroupName
                    $locks.Name | Should -Not -BeIn $lockName
                } finally {
                    $locks = Get-AzResourceLock -ResourceGroupName $targetResourceGroupName
                    if ($lockName -in $locks.Name) {
                        Remove-AzResourceLock `
                            -ResourceGroupName $targetResourceGroupName `
                            -LockName $lockName `
                            -ResourceName $targetResourceName `
                            -ResourceType "Microsoft.KeyVault/vaults" `
                            -Force
                    }
                }
            }
            It "Newly added resource lock gets removed by removing all resource locks without giving any lock name" {
                # Arrange
                $lockName = "NewTestingLockWithoutName"
                $targetResourceName = $config.Arcus.KeyVault.VaultName
                $targetResourceGroupName = $config.Arcus.ResourceGroupName
                New-AzResourceLock `
                    -ResourceGroupName $targetResourceGroupName `
                    -ResourceName $targetResourceName `
                    -ResourceType "Microsoft.KeyVault/vaults" `
                    -LockName $lockName `
                    -LockLevel CanNotDelete `
                    -Force

                try {
                    # Act
                    Remove-AzResourceGroupLocks -ResourceGroupName $targetResourceGroupName
                
                    # Assert
                    $locks = Get-AzResourceLock -ResourceGroupName $targetResourceGroupName
                    $locks.Name | Should -Not -BeIn $lockName
                } finally {
                    $locks = Get-AzResourceLock -ResourceGroupName $targetResourceGroupName
                    if ($lockName -in $locks.Name) {
                        Remove-AzResourceLock `
                            -ResourceGroupName $targetResourceGroupName `
                            -LockName $lockName `
                            -ResourceName $targetResourceName `
                            -ResourceType "Microsoft.KeyVault/vaults" `
                            -Force
                    }
                }
            }
        }
    }
}