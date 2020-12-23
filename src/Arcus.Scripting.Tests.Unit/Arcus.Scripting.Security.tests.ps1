Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Security -ErrorAction Stop

Describe "Arcus" {
    Context "ARM remove resource group locks" {
        InModuleScope Arcus.Scripting.Security {
            It "Removes all resource group locks without providing lock name" {
                # Arrange
                $lockId = "my-lock-id"
                $resourceGroupName = "my-resource-group"
                Mock Get-AzResourceLock { 
                    $ResourceGroupName | Should -Be $resourceGroupName
                    return @([pscustomobject]@{ LockId = $lockId }) } -Verifiable
                Mock Remove-AzResourceLock { 
                    $LockId | Should -Be $lockId } -Verifiable

                # Act
                Remove-AzResourceGroupLocks -ResourceGroupName $resourceGroupName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzResourceLock -Times 1
                Assert-MockCalled Remove-AzResourceLock -Times 1
            }
            It "Can't remove all resource group locks without returning locks" {
                # Arrange
                $resourceGroupName = "my-resource-group"
                Mock Get-AzResourceLock {
                    $ResourceGroupName | Should -Be $resourceGroupName
                    return @() } -Verifiable
                Mock Remove-AzResourceLock { }

                # Act
                Remove-AzResourceGroupLocks -ResourceGroupName $resourceGroupName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzResourceLock -Times 1
                Assert-MockCalled Remove-AzResourceLock -Times 0
            }
            It "Remove resource group lock with a specific lock name" {
                # Arrange
                $lockId = "my-lock-id"
                $lockName = "my-lock-name"
                $resourceGroupName = "my-resource-group"
                Mock Get-AzResourceLock {
                    $ResourceGroupName | Should -Be $resourceGroupName
                    $LockName | Should -Be $LockName
                    return @([pscustomobject]@{ LockId = $lockId }) } -Verifiable
                Mock Remove-AzResourceLock {
                    $LockId | Should -Be $lockId } -Verifiable

                # Act
                Remove-AzResourceGroupLocks -ResourceGroupName $resourceGroupName -LockName $lockName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzResourceLock -Times 1
                Assert-MockCalled Remove-AzResourceLock -Times 1
            }
            It "Can't remove specific resource lock without returning locks" {
                # Arrange
                $lockId = "my-lock-id"
                $lockName = "my-lock-name"
                $resourceGroupName = "my-resource-group"
                Mock Get-AzResourceLock {
                    $ResourceGroupName | Should -Be $resourceGroupName
                    $LockName | Should -Be $lockName
                    return @() } -Verifiable
                Mock Remove-AzResourceLock { }

                # Act
                Remove-AzResourceGroupLocks -ResourceGroupName $resourceGroupName -LockName $lockName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzResourceLock -Times 1
                Assert-MockCalled Remove-AzResourceLock -Times 0
            }
        }
    }
}