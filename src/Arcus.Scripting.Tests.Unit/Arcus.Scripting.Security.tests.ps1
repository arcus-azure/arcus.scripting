Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Security -ErrorAction Stop

InModuleScope Arcus.Scripting.Security {
    Describe "Arcus Azure security unit tests" {
        Context "ARM remove resource group locks" {
            It "Removes all resource group locks without providing lock name" {
                # Arrange
                $expectedLockId = "my-lock-id"
                $resourceGroup = "my-resource-group"
                Mock Get-AzResourceLock { 
                    $ResourceGroupName | Should -Be $resourceGroup
                    return @([pscustomobject]@{ LockId = "my-lock-id" }) } -Verifiable
                Mock Remove-AzResourceLock { 
                    $LockId | Should -Be $expectedLockId } -Verifiable

                # Act
                Remove-AzResourceGroupLocks -ResourceGroupName $resourceGroup

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzResourceLock -Times 1
                Assert-MockCalled Remove-AzResourceLock -Times 1
            }
            It "Can't remove all resource group locks without returning locks" {
                # Arrange
                $resourceGroup = "my-resource-group"
                Mock Get-AzResourceLock {
                    $ResourceGroupName | Should -Be $resourceGroup
                    return @() } -Verifiable
                Mock Remove-AzResourceLock { }

                # Act
                Remove-AzResourceGroupLocks -ResourceGroupName $resourceGroup

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzResourceLock -Times 1
                Assert-MockCalled Remove-AzResourceLock -Times 0
            }
            It "Remove resource group lock with a specific lock name" {
                # Arrange
                $expectedLockId = "my-lock-id"
                $expectedLockName = "my-lock-name"
                $resourceGroup = "my-resource-group"
                Mock Get-AzResourceLock {
                    $ResourceGroupName | Should -Be $resourceGroup
                    return @([pscustomobject]@{ LockId =$expectedLockId; Name = $expectedLockName }) } -Verifiable
                Mock Remove-AzResourceLock {
                    $LockId | Should -Be $expectedLockId } -Verifiable

                # Act
                Remove-AzResourceGroupLocks -ResourceGroupName $resourceGroup -LockName $expectedLockName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzResourceLock -Times 1
                Assert-MockCalled Remove-AzResourceLock -Times 1
            }
            It "Can't remove specific resource lock without returning locks" {
                # Arrange
                $expectedLockId = "my-lock-id"
                $expectedLockName = "my-lock-name"
                $resourceGroup = "my-resource-group"
                Mock Get-AzResourceLock {
                    $ResourceGroupName | Should -Be $resourceGroup
                    return @() } -Verifiable
                Mock Remove-AzResourceLock { }

                # Act
                Remove-AzResourceGroupLocks -ResourceGroupName $resourceGroup -LockName $expectedLockName

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
                $subscriptionId = "123456"
                $accessToken = "accessToken"

                Mock Get-AzCachedAccessToken -MockWith {
                    return new-object psobject -Property @{ SubscriptionId = $subscriptionId; AccessToken = $accessToken }
                } -Verifiable

                # Act
                $token = Get-AzCachedAccessToken

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Exactly 1
                $token.SubscriptionId | Should -Be $subscriptionId
                $token.AccessToken | Should -Be $accessToken
            }
            It "Retrieves the subscriptionId and accessToken with assigning global variables" {
                # Arrange
                $subscriptionId = "123456"
                $accessToken = "accessToken"

                Mock Get-AzCachedAccessToken -MockWith {
                    $Global:subscriptionId = $subscriptionId
                    $Global:accessToken = $accessToken
                    return new-object psobject -Property @{ SubscriptionId = $subscriptionId; AccessToken = $accessToken }
                } -Verifiable
                $Global:subscriptionId = ""
                $Global:accessToken = ""

                # Act
                $token = Get-AzCachedAccessToken -AssignGlobalVariables

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Exactly 1
                $token.SubscriptionId | Should -Be $subscriptionId
                $token.AccessToken | Should -Be $accessToken
                $Global:subscriptionId | Should -Be $token.SubscriptionId
                $Global:accessToken | Should -Be $token.AccessToken
            }
        }
    }
    Context "New Az resource group role assignment" {
        InModuleScope Arcus.Scripting.Security {
            It "Gets resource to grant specific access to the targetted resource group" {
                # Arrange
                $targetResourceGroup = "to-be-accessed-resources"
                $resourceGroup = "my-resources"
                $resource = "my-resource"
                $roleDefinitionName = "Contributer"
                $principalId = [System.Guid]::NewGuid()

                Mock Get-AzResource {
                    $ResourceGroupName | Should -Be $resourceGroup
                    $Name | Should -Be $resource
                    return [pscustomobject]@{ identity = [pscustomobject]@{ PrincipalId = $principalId } }
                } -Verifiable
                Mock New-AzRoleAssignment {
                    $ObjectId | Should -Be $principalId
                    $RoleDefinitionName | Should -Be $roleDefinitionName
                    $ResourceGroupName | Should -Be $targetResourceGroup
                } -Verifiable

                # Act
                New-AzResourceGroupRoleAssignment -TargetResourceGroupName $targetResourceGroup -ResourceGroupName $resourceGroup -ResourceName $resource -RoleDefinitionName $roleDefinitionName

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzResource -Times 1
                Assert-MockCalled New-AzRoleAssignment -Times 1
            }
        }
    }
}