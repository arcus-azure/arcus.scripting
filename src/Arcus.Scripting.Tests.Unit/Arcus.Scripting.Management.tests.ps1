Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Management -ErrorAction Stop
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Security -ErrorAction Stop
Import-Module -Name Az.Accounts -ErrorAction Stop

InModuleScope Arcus.Scripting.Management {
    Describe "Arcus Azure Management unit tests" {
        Context "Remove soft deleted Azure API Management service" {
            It "Providing an API Management name that does not exist as a soft deleted service should fail" {
                # Arrange
                $Name = 'unexisting-apim-instance'

                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                Mock Invoke-RestMethod {
                    return $null
                } -Verifiable

                # Act
                { 
                   Remove-AzApiManagementSoftDeletedService -Name $Name
                } | Should -Throw -ExpectedMessage "API Management instance with name '$Name' is not listed as a soft deleted service and therefore it cannot be removed"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
            }
            It "Removing a soft deleted API Management should fail" {
                # Arrange
                $Name = 'existing-apim-instance'

                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                Mock Invoke-RestMethod {
                    if ($Method -eq "Get") {
                       return [pscustomobject] @{
                        value = @([ordered] @{
                                id = "subscriptions/########-####-####-####-############/providers/Microsoft.ApiManagement/locations/westeurope/deletedservices/$Name";
                                name = $Name;
                                location = "West Europe";
                            })
                        };
                    } else {
                        throw 'some error'
                    }
                } -Verifiable

                # Act
                { 
                   Remove-AzApiManagementSoftDeletedService -Name $Name
                } | Should -Throw -ExpectedMessage "The soft deleted API Management instance '$Name' could not be removed. Details: some error"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Invoke-RestMethod -Times 2
            }
            It "Removing a soft deleted API Management should succeed" {
                # Arrange
                $Name = 'existing-apim-instance'

                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                Mock Invoke-RestMethod {
                    if ($Method -eq "Get") {
                       return [pscustomobject] @{
                        value = @([ordered] @{
                                id = "subscriptions/########-####-####-####-############/providers/Microsoft.ApiManagement/locations/westeurope/deletedservices/$Name";
                                name = $Name;
                                location = "West Europe";
                            })
                        };
                    } else {
                        return $null
                    }
                } -Verifiable

                # Act
                { 
                   Remove-AzApiManagementSoftDeletedService -Name $Name
                } | Should -Not -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Invoke-RestMethod -Times 2
            }
        }
        Context "Restore soft deleted Azure API Management service" {
            It "Providing an API Management name that does not exist as a soft deleted service should fail" {
                # Arrange
                $Name = 'unexisting-apim-instance'

                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                Mock Invoke-RestMethod {
                    return $null
                } -Verifiable

                # Act
                { 
                   Restore-AzApiManagementSoftDeletedService -Name $Name
                } | Should -Throw -ExpectedMessage "API Management instance with name '$Name' is not listed as a soft deleted service and therefore it cannot be restored"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
            }
            It "Restoring a soft deleted API Management should fail" {
                # Arrange
                $Name = 'existing-apim-instance'

                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                Mock Invoke-RestMethod {
                    if ($Method -eq "Get") {
                       return [pscustomobject] @{
                        value = @([ordered] @{
                                id = "subscriptions/########-####-####-####-############/providers/Microsoft.ApiManagement/locations/westeurope/deletedservices/$Name";
                                name = $Name;
                                location = "West Europe";
                            })
                        };
                    } else {
                        throw 'some error'
                    }
                } -Verifiable

                # Act
                { 
                   Restore-AzApiManagementSoftDeletedService -Name $Name
                } | Should -Throw -ExpectedMessage "The soft deleted API Management instance '$Name' could not be restored. Details: some error"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Invoke-RestMethod -Times 2
            }
            It "Restoring a soft deleted API Management should succeed" {
                # Arrange
                $Name = 'existing-apim-instance'

                Mock Get-AzCachedAccessToken -MockWith {
                    return @{
                        SubscriptionId = "123456"
                        AccessToken = "accessToken"
                    }
                }

                Mock Invoke-RestMethod {
                    if ($Method -eq "Get") {
                       return [pscustomobject] @{
                        value = @([ordered] @{
                                id = "subscriptions/########-####-####-####-############/providers/Microsoft.ApiManagement/locations/westeurope/deletedservices/$Name";
                                name = $Name;
                                location = "West Europe";
                            })
                        };
                    } else {
                        return $null
                    }
                } -Verifiable

                # Act
                { 
                   Restore-AzApiManagementSoftDeletedService -Name $Name
                } | Should -Not -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzCachedAccessToken -Scope It -Times 1
                Assert-MockCalled Invoke-RestMethod -Times 2
            }            
        }
    }
}
