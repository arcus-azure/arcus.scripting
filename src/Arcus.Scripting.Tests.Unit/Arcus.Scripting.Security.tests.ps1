Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Security\Arcus.Scripting.Security.psm1
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
                    return @([pscustomobject]@{ LockId = "my-lock-id" }) } -Verifiable
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
                    return @([pscustomobject]@{ LockId = "my-lock-id" }) } -Verifiable
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
    Context "Get Az Cached Access Token" {
        InModuleScope Arcus.Scripting.Security {
            It "Retrieves the subscriptionId and accessToken without assigning global variables" {
                # Arrange
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                } -Verifiable

                # Act
                $token = Get-AzCachedAccessToken

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Exactly 1
                $token.SubscriptionId | Should -Be "123456"
                $token.AccessToken | Should -Be "accessToken"
            }
            It "Retrieves the subscriptionId and accessToken with assigning global variables" {
                # Arrange
                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                } -Verifiable

                # Act
                $token = Get-AzCachedAccessToken -AssignGlobalVariables

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Exactly 1
                $token.SubscriptionId | Should -Be "123456"
                $token.AccessToken | Should -Be "accessToken"
                $Global:subscriptionId | Should -Be $token.SubscriptionId
                $Global:accessToken | Should -Be $token.AccessToken
            }
        }
    }
}