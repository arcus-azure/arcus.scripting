Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Security -ErrorAction Stop

InModuleScope Arcus.Scripting.Security {
    Describe "Arcus Azure security integration tests" {
        Context "Get cached access token" {
            It "Get cached access token from current active authenticated Azure session succeeds" {
                # Arrange
                $config = & $PSScriptRoot\Load-JsonAppsettings.ps1 -fileName "appsettings.json"
                & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config

                # Act
                $token = Get-AzCachedAccessToken

                # Assert
                $token | Should -Not -Be $null
                $token.SubscriptionId | Should -Be $config.Arcus.SubscriptionId
                $token.AccessToken | Should -Not -BeNullOrEmpty
            }
            It "Get cached access token from current unative authenticated Azure session fails" {
                # Arrange
                $config = & $PSScriptRoot\Load-JsonAppsettings.ps1 -fileName "appsettings.json"
                Disconnect-AzAccount -TenantId $config.Arcus.TenantId -ApplicationId $config.Arcus.ServicePrincipal.ClientId

                # Act
                { Get-AzCachedAccessToken } | Should -Throw
            }
        }
        Context "Removing resource locks on Azure resources" {
            BeforeEach {
                $config = & $PSScriptRoot\Load-JsonAppsettings.ps1 -fileName "appsettings.json"
                & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
            }
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