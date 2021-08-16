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
            It "Newly added resource lock gets removed by removing all resource locks" {
                # Arrange
                $lockName = "NewTestingLock"
                $targetResourceName = $config.Arcus.KeyVault.VaultName
                $targetResourceGroupName = $config.Arcus.ResourceGroupName
                NewAzResourceLock -LockName $lockName -ResouceGroupName $targetResourceGroupName -ResourceName $targetResourceName

                try {
                    # Act
                    Remove-AzResourceGroupLocks -ResourceGroupName $targetResourceGroupName -LockName $lockName
                
                    # Assert
                    $locks = Get-AzResourceLock -LockName $lockName -ResourceGroupName $targetResourceGroupName
                    $locks.Count | Should -Be 0
                } finally {
                    Remove-AzResourceLock -LockName $lockName -ResourceName $targetResourceName -ResourceGroupName $targetResourceGroupName
                }
            }
        }
    }
}