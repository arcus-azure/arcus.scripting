Import-Module Microsoft.Graph.Applications
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.ActiveDirectory -ErrorAction Stop

InModuleScope Arcus.Scripting.ActiveDirectory {
    Describe "Arcus Azure Active Directory unit tests" {
        Context "Get Active Directory Application Role Assignments" {
            It "Providing a ClientId that does not have an Active Directory Application should fail" {
                # Arrange
                $ClientId = '1234'

                Mock Get-AzADApplication {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return $null }

                # Act
                { 
                   List-AzADAppRoleAssignments -ClientId $ClientId
                } | Should -Throw -ExpectedMessage "Active Directory Application for the ClientId '$ClientId' could not be found"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 1
            }
            It "Providing a ClientId that does not have an Active Directory Service Principal should fail" {
                # Arrange
                $ClientId = '1234'

                Mock Get-AzADApplication {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return [pscustomobject]@{ AppId = $ClientId; }}

                Mock Get-AzADServicePrincipal {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return $null }

                # Act
                { 
                   List-AzADAppRoleAssignments -ClientId $ClientId
                } | Should -Throw -ExpectedMessage "Active Directory Service Principal for the ClientId '$ClientId' could not be found"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 1
                Assert-MockCalled Get-AzADServicePrincipal -Times 1
            }
            It "Providing a RolesAssignedToClientId that does not have an Active Directory Application should fail" {
                # Arrange
                $ClientId = '1234'
                $RolesAssignedToClientId = '9876'

                Mock Get-AzADApplication {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ AppId = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$RolesAssignedToClientId'") {
                        return $null
                    }
                }

                Mock Get-AzADServicePrincipal {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return [pscustomobject]@{ AppId = $ClientId; }}

                # Act
                { 
                   List-AzADAppRoleAssignments -ClientId $ClientId -RolesAssignedToClientId $RolesAssignedToClientId
                } | Should -Throw -ExpectedMessage "Active Directory Application for the ClientId '$RolesAssignedToClientId' could not be found"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 2
                Assert-MockCalled Get-AzADServicePrincipal -Times 1
            }
            It "Providing a RolesAssignedToClientId that does not have an Active Directory Service Principal should fail" {
                # Arrange
                $ClientId = '1234'
                $RolesAssignedToClientId = '9876'

                Mock Get-AzADApplication {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ AppId = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$RolesAssignedToClientId'") {
                        return [pscustomobject]@{ AppId = $RolesAssignedToClientId; }
                    }
                }

                Mock Get-AzADServicePrincipal {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ AppId = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$RolesAssignedToClientId'") {
                        return $null
                    }
                }

                # Act
                { 
                   List-AzADAppRoleAssignments -ClientId $ClientId -RolesAssignedToClientId $RolesAssignedToClientId
                } | Should -Throw -ExpectedMessage "Active Directory Service Principal for the ClientId '$RolesAssignedToClientId' could not be found"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 2
                Assert-MockCalled Get-AzADServicePrincipal -Times 2
            }
            It "Providing a ClientId that has roles but not assignments should succeed" {
                # Arrange
                $ClientId = '1234'
                $AppName = 'SomeApp'
                $RoleName = 'SomeRole'

                Mock Write-Host {}

                Mock Write-Warning {}

                Mock Get-AzADApplication {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return [pscustomobject] @{
                        AppId = $ClientId;
                        DisplayName = $AppName
                        AppRole = @([pscustomobject] @{
                            Id = '1';
                            Value = $RoleName
                        })
                    };
                }

                Mock Get-AzADServicePrincipal {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return [pscustomobject]@{ AppId = $ClientId; Id = '1' }}

                Mock Get-MgServicePrincipalAppRoleAssignedTo {
                    $ServicePrincipalId | Should -Be '1'
                    return $null}

                # Act
                List-AzADAppRoleAssignments -ClientId $ClientId

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 1
                Assert-MockCalled Get-AzADServicePrincipal -Times 1
                Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Object -eq "Found role '$RoleName' on Active Directory Application '$AppName'" }
                Assert-MockCalled Get-MgServicePrincipalAppRoleAssignedTo -Times 1
                Assert-MockCalled Write-Warning -Exactly 1 -ParameterFilter { $Message -eq "No role assignments found in Active Directory Application '$AppName'" }
            }
            It "Providing a ClientId that has roles and also assignments should succeed" {
                # Arrange
                $ClientId = '1234'
                $AppRoleId = '1'
                $PrincipalId = '999'
                $AppName = 'SomeApp'
                $RoleName = 'SomeRole'
                $AssignmentName = 'SomeAssignment'

                Mock Write-Host {}

                Mock Get-AzADApplication {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return [pscustomobject] @{
                        AppId = $ClientId;
                        DisplayName = $AppName
                        AppRole = @([pscustomobject] @{
                            Id = $AppRoleId;
                            Value = $RoleName
                        })
                    };
                }

                Mock Get-AzADServicePrincipal {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ Id = $ClientId; }
                    } elseif ($ObjectId -eq "$PrincipalId") {
                        return [pscustomobject]@{ AppId = $PrincipalId; }
                    }
                }

                Mock Get-MgServicePrincipalAppRoleAssignedTo {
                    $ServicePrincipalId | Should -Be $ClientId
                    return @([pscustomobject] @{
                        AppRoleId = $AppRoleId;
                        PrincipalId = $PrincipalId;
                        PrincipalDisplayName = $AssignmentName
                    })
                };

                # Act
                List-AzADAppRoleAssignments -ClientId $ClientId

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 1
                Assert-MockCalled Get-AzADServicePrincipal -Times 2
                Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Object -eq "Found role '$RoleName' on Active Directory Application '$AppName'" }
                Assert-MockCalled Get-MgServicePrincipalAppRoleAssignedTo -Times 1
                Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Object -eq "Role '$RoleName' is assigned to the Active Directory Application '$AssignmentName' with id '$PrincipalId'" }
            }
        }
        Context "Add an Active Directory Application Role Assignment" {
            It "Providing a ClientId that does not have an Active Directory Application should fail" {
                # Arrange
                $ClientId = '1234'
                $Role = 'SomeRole'
                $AssignRoleToClientId = '9876'

                Mock Get-AzADApplication {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return $null }

                # Act
                { 
                   Add-AzADAppRoleAssignment -ClientId $ClientId -Role $Role -AssignRoleToClientId $AssignRoleToClientId
                } | Should -Throw -ExpectedMessage "Active Directory Application for the ClientId '$ClientId' could not be found"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 1
            }
            It "Providing a ClientId that does not have an Active Directory Service Principal should fail" {
                # Arrange
                $ClientId = '1234'
                $Role = 'SomeRole'
                $AssignRoleToClientId = '9876'

                Mock Get-AzADApplication {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return [pscustomobject]@{ AppId = $ClientId; }}

                Mock Get-AzADServicePrincipal {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return $null }

                # Act
                { 
                   Add-AzADAppRoleAssignment -ClientId $ClientId -Role $Role -AssignRoleToClientId $AssignRoleToClientId
                } | Should -Throw -ExpectedMessage "Active Directory Service Principal for the ClientId '$ClientId' could not be found"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 1
                Assert-MockCalled Get-AzADServicePrincipal -Times 1
            }
            It "Providing a ClientId that the role should be assigned to that does not have an Active Directory Application should fail" {
                # Arrange
                $ClientId = '1234'
                $Role = 'SomeRole'
                $AssignRoleToClientId = '9876'

                Mock Get-AzADApplication {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ AppId = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$AssignRoleToClientId'") {
                        return $null
                    }
                }

                Mock Get-AzADServicePrincipal {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return [pscustomobject]@{ AppId = $ClientId; }}

                # Act
                { 
                   Add-AzADAppRoleAssignment -ClientId $ClientId -Role $Role -AssignRoleToClientId $AssignRoleToClientId
                } | Should -Throw -ExpectedMessage "Active Directory Application for the ClientId '$AssignRoleToClientId' could not be found"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 2
                Assert-MockCalled Get-AzADServicePrincipal -Times 1
            }
            It "Providing a ClientId that the role should be assigned to that does not have an Active Directory Service Principal should fail" {
                # Arrange
                $ClientId = '1234'
                $Role = 'SomeRole'
                $AssignRoleToClientId = '9876'

                Mock Get-AzADApplication {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ AppId = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$AssignRoleToClientId'") {
                        return [pscustomobject]@{ AppId = $AssignRoleToClientId; }
                    }
                }

                Mock Get-AzADServicePrincipal {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ AppId = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$RolesAssignedToClientId'") {
                        return $null
                    }
                }

                # Act
                { 
                   Add-AzADAppRoleAssignment -ClientId $ClientId -Role $Role -AssignRoleToClientId $AssignRoleToClientId
                } | Should -Throw -ExpectedMessage "Active Directory Service Principal for the ClientId '$AssignRoleToClientId' could not be found"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 2
                Assert-MockCalled Get-AzADServicePrincipal -Times 2
            }
            It "Providing a role that already exists and already has a role assignment should succeed" {
                # Arrange
                $ClientId = '1234'
                $AppRoleId = '1'
                $RoleName = 'SomeRole'
                $AssignRoleToClientId = '9876'
                $AppName = 'SomeApp'
                $AssignRoleToAppName = 'SomeAppToAssignRoleTo'

                Mock Write-Warning {}

                Mock Get-AzADApplication {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject] @{
                            AppId = $ClientId;
                            DisplayName = $AppName
                            AppRole = @([pscustomobject] @{
                                Id = $AppRoleId;
                                Value = $RoleName
                            })
                        };
                    } elseif ($Filter -eq "AppId eq '$AssignRoleToClientId'") {
                        return [pscustomobject]@{ AppId = $AssignRoleToClientId; DisplayName = $AssignRoleToAppName}
                    }
                }

                Mock Get-AzADServicePrincipal {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ Id = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$AssignRoleToClientId'") {
                        return [pscustomobject]@{ AppId = $AssignRoleToClientId; }
                    }
                }

                Mock Get-MgServicePrincipalAppRoleAssignedTo {
                    $ServicePrincipalId | Should -Be $ClientId
                    return @([pscustomobject] @{
                        AppRoleId = $AppRoleId;
                        PrincipalId = $PrincipalId;
                        PrincipalDisplayName = $AssignmentName
                    })
                };

                # Act
                Add-AzADAppRoleAssignment -ClientId $ClientId -Role $RoleName -AssignRoleToClientId $AssignRoleToClientId

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 2
                Assert-MockCalled Get-AzADServicePrincipal -Times 2
                Assert-MockCalled Write-Warning -Exactly 1 -ParameterFilter { $Message -eq "Active Directory Application '$AppName' already contains the role '$RoleName'" }
                Assert-MockCalled Get-MgServicePrincipalAppRoleAssignedTo -Times 1
                Assert-MockCalled Write-Warning -Exactly 1 -ParameterFilter { $Message -eq "Active Directory Application '$AssignRoleToAppName' already contains a role assignment for the role '$RoleName'" }
            }
            It "Providing a role that already exists and does not have a role assignment should succeed" {
                # Arrange
                $ClientId = '1234'
                $AppRoleId = '1'
                $RoleName = 'SomeRole'
                $AssignRoleToClientId = '9876'
                $AppName = 'SomeApp'
                $AssignRoleToAppName = 'SomeAppToAssignRoleTo'

                Mock Write-Host {}

                Mock Write-Warning {}

                Mock Get-AzADApplication {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject] @{
                            AppId = $ClientId;
                            DisplayName = $AppName
                            AppRole = @([pscustomobject] @{
                                Id = $AppRoleId;
                                Value = $RoleName
                            })
                        };
                    } elseif ($Filter -eq "AppId eq '$AssignRoleToClientId'") {
                        return [pscustomobject]@{ AppId = $AssignRoleToClientId; DisplayName = $AssignRoleToAppName}
                    }
                }

                Mock Get-AzADServicePrincipal {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ Id = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$AssignRoleToClientId'") {
                        return [pscustomobject]@{ AppId = $AssignRoleToClientId; Id = $AssignRoleToClientId; }
                    }
                }

                Mock Get-MgServicePrincipalAppRoleAssignedTo {
                    $ServicePrincipalId | Should -Be $ClientId
                    return $null
                };

                Mock Get-MgServicePrincipal {
                    $ServicePrincipalId | Should -Be $ClientId
                    return @([pscustomobject] @{
                        AppRoles = @([pscustomobject] @{
                            Value = $RoleName
                        })
                    })
                };

                Mock New-MgServicePrincipalAppRoleAssignment {
                    $ServicePrincipalId | Should -Be $AssignRoleToClientId
                    $PrincipalId | Should -Be $AssignRoleToClientId
                    $ResourceId | Should -Be $ClientId
                    $AppRoleId | Should -Be $AppRoleId
                    return $null
                };

                # Act
                Add-AzADAppRoleAssignment -ClientId $ClientId -Role $RoleName -AssignRoleToClientId $AssignRoleToClientId

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 2
                Assert-MockCalled Get-AzADServicePrincipal -Times 2
                Assert-MockCalled Write-Warning -Exactly 1 -ParameterFilter { $Message -eq "Active Directory Application '$AppName' already contains the role '$RoleName'" }
                Assert-MockCalled Get-MgServicePrincipalAppRoleAssignedTo -Times 1
                Assert-MockCalled Get-MgServicePrincipal -Times 1
                Assert-MockCalled New-MgServicePrincipalAppRoleAssignment -Times 1
                Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Object -eq "Role Assignment for the role '$RoleName' added to the Active Directory Application '$AssignRoleToAppName'" }
            }
            It "Providing a role that does not exist should succeed" {
                # Arrange
                $ClientId = '1234'
                $AppRoleId = '1'
                $RoleName = 'SomeRole'
                $AssignRoleToClientId = '9876'
                $AppName = 'SomeApp'
                $AssignRoleToAppName = 'SomeAppToAssignRoleTo'

                Mock Write-Host {}

                Mock Get-AzADApplication {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject] @{
                            Id = $ClientId;
                            AppId = $ClientId;
                            DisplayName = $AppName
                            AppRole = $null
                        };
                    } elseif ($Filter -eq "AppId eq '$AssignRoleToClientId'") {
                        return [pscustomobject]@{ AppId = $AssignRoleToClientId; DisplayName = $AssignRoleToAppName}
                    }
                }

                Mock Get-AzADServicePrincipal {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ Id = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$AssignRoleToClientId'") {
                        return [pscustomobject]@{ AppId = $AssignRoleToClientId; Id = $AssignRoleToClientId; }
                    }
                }

                Mock Update-AzADApplication {
                    $ObjectId | Should -Be $ClientId
                    return $null
                };

                Mock Get-MgServicePrincipalAppRoleAssignedTo {
                    $ServicePrincipalId | Should -Be $ClientId
                    return $null
                };

                Mock Get-MgServicePrincipal {
                    $ServicePrincipalId | Should -Be $ClientId
                    return @([pscustomobject] @{
                        AppRoles = @([pscustomobject] @{
                            Value = $RoleName
                        })
                    })
                };

                Mock New-MgServicePrincipalAppRoleAssignment {
                    $ServicePrincipalId | Should -Be $AssignRoleToClientId
                    $PrincipalId | Should -Be $AssignRoleToClientId
                    $ResourceId | Should -Be $ClientId
                    $AppRoleId | Should -Be $AppRoleId
                    return $null
                };

                # Act
                Add-AzADAppRoleAssignment -ClientId $ClientId -Role $RoleName -AssignRoleToClientId $AssignRoleToClientId

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 2
                Assert-MockCalled Get-AzADServicePrincipal -Times 2
                Assert-MockCalled Update-AzADApplication -Times 1
                Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Object -eq "Added Role '$RoleName' to Active Directory Application '$AppName'" }
                Assert-MockCalled Get-MgServicePrincipalAppRoleAssignedTo -Times 1
                Assert-MockCalled Get-MgServicePrincipal -Times 1
                Assert-MockCalled New-MgServicePrincipalAppRoleAssignment -Times 1
                Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Object -eq "Role Assignment for the role '$RoleName' added to the Active Directory Application '$AssignRoleToAppName'" }
            }
        }
        Context "Remove an Active Directory Application Role Assignment" {
            It "Providing a ClientId that does not have an Active Directory Application should fail" {
                # Arrange
                $ClientId = '1234'
                $Role = 'SomeRole'
                $RemoveRoleFromClientId = '9876'

                Mock Get-AzADApplication {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return $null }

                # Act
                { 
                   Remove-AzADAppRoleAssignment -ClientId $ClientId -Role $Role -RemoveRoleFromClientId $RemoveRoleFromClientId
                } | Should -Throw -ExpectedMessage "Active Directory Application for the ClientId '$ClientId' could not be found"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 1
            }
            It "Providing a ClientId that does not have an Active Directory Service Principal should fail" {
                # Arrange
                $ClientId = '1234'
                $Role = 'SomeRole'
                $RemoveRoleFromClientId = '9876'

                Mock Get-AzADApplication {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return [pscustomobject]@{ AppId = $ClientId; }}

                Mock Get-AzADServicePrincipal {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return $null }

                # Act
                { 
                   Remove-AzADAppRoleAssignment -ClientId $ClientId -Role $Role -RemoveRoleFromClientId $RemoveRoleFromClientId
                } | Should -Throw -ExpectedMessage "Active Directory Service Principal for the ClientId '$ClientId' could not be found"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 1
                Assert-MockCalled Get-AzADServicePrincipal -Times 1
            }
            It "Providing a ClientId where the role should be removed from that does not have an Active Directory Application should fail" {
                # Arrange
                $ClientId = '1234'
                $Role = 'SomeRole'
                $RemoveRoleFromClientId = '9876'

                Mock Get-AzADApplication {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ AppId = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$RemoveRoleFromClientId'") {
                        return $null
                    }
                }

                Mock Get-AzADServicePrincipal {
                    $Filter | Should -Be "AppId eq '$ClientId'"
                    return [pscustomobject]@{ AppId = $ClientId; }}

                # Act
                { 
                   Remove-AzADAppRoleAssignment -ClientId $ClientId -Role $Role -RemoveRoleFromClientId $RemoveRoleFromClientId
                } | Should -Throw -ExpectedMessage "Active Directory Application for the ClientId '$RemoveRoleFromClientId' could not be found"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 2
                Assert-MockCalled Get-AzADServicePrincipal -Times 1
            }
            It "Providing a ClientId where the role should be removed from that does not have an Active Directory Service Principal should fail" {
                # Arrange
                $ClientId = '1234'
                $Role = 'SomeRole'
                $RemoveRoleFromClientId = '9876'

                Mock Get-AzADApplication {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ AppId = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$RemoveRoleFromClientId'") {
                        return [pscustomobject]@{ AppId = $RemoveRoleFromClientId; }
                    }
                }

                Mock Get-AzADServicePrincipal {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ AppId = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$RemoveRoleFromClientId'") {
                        return $null
                    }
                }

                # Act
                { 
                   Remove-AzADAppRoleAssignment -ClientId $ClientId -Role $Role -RemoveRoleFromClientId $RemoveRoleFromClientId
                } | Should -Throw -ExpectedMessage "Active Directory Service Principal for the ClientId '$RemoveRoleFromClientId' could not be found"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 2
                Assert-MockCalled Get-AzADServicePrincipal -Times 2
            }
            It "Providing a role that does not exist on the Active Directory Application should succeed" {
                # Arrange
                $ClientId = '1234'
                $RoleName = 'SomeRole'
                $RemoveRoleFromClientId = '9876'
                $AppName = 'SomeApp'

                Mock Write-Warning {}

                Mock Get-AzADApplication {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ AppId = $ClientId; DisplayName = $AppName; }
                    } elseif ($Filter -eq "AppId eq '$RemoveRoleFromClientId'") {
                        return [pscustomobject]@{ AppId = $RemoveRoleFromClientId; }
                    }
                }

                Mock Get-AzADServicePrincipal {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ AppId = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$RemoveRoleFromClientId'") {
                        return [pscustomobject]@{ AppId = $RemoveRoleFromClientId; }
                    }
                }

                # Act
                Remove-AzADAppRoleAssignment -ClientId $ClientId -Role $RoleName -RemoveRoleFromClientId $RemoveRoleFromClientId

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 2
                Assert-MockCalled Get-AzADServicePrincipal -Times 2
                Assert-MockCalled Write-Warning -Exactly 1 -ParameterFilter { $Message -eq "Active Directory Application '$AppName' does not contain the role '$RoleName', skipping removal" }
            }
            It "Providing a role that has no role assignment on the Active Directory Application it should be removed from should succeed" {
                # Arrange
                $ClientId = '1234'
                $AppRoleId = '1'
                $RoleName = 'SomeRole'
                $RemoveRoleFromClientId = '9876'
                $AppName = 'SomeApp'
                $RemoveRoleFromAppName = 'SomeAppToRemoveRoleFrom'

                Mock Write-Warning {}

                Mock Get-AzADApplication {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject] @{
                            Id = $ClientId;
                            AppId = $ClientId;
                            DisplayName = $AppName
                            AppRole = @([pscustomobject] @{
                                Id = $AppRoleId;
                                Value = $RoleName
                            })
                        };
                    } elseif ($Filter -eq "AppId eq '$RemoveRoleFromClientId'") {
                        return [pscustomobject]@{ AppId = $RemoveRoleFromClientId; DisplayName = $RemoveRoleFromAppName }
                    }
                }

                Mock Get-AzADServicePrincipal {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ AppId = $ClientId; Id = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$RemoveRoleFromClientId'") {
                        return [pscustomobject]@{ AppId = $RemoveRoleFromClientId; }
                    }
                }

                Mock Get-MgServicePrincipalAppRoleAssignedTo {
                    $ServicePrincipalId | Should -Be $ClientId
                    return $null
                };

                # Act
                Remove-AzADAppRoleAssignment -ClientId $ClientId -Role $RoleName -RemoveRoleFromClientId $RemoveRoleFromClientId

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 2
                Assert-MockCalled Get-AzADServicePrincipal -Times 2
                Assert-MockCalled Get-MgServicePrincipalAppRoleAssignedTo -Times 1
                Assert-MockCalled Write-Warning -Exactly 1 -ParameterFilter { $Message -eq "Role '$RoleName' is not assigned to Active Directory Application '$RemoveRoleFromAppName', skipping role assignment removal" }
            }
            It "Providing a role that has a role assignment on the Active Directory Application it should be removed from should succeed" {
                # Arrange
                $ClientId = '1234'
                $AppRoleId = '1'
                $RoleName = 'SomeRole'
                $RemoveRoleFromClientId = '9876'
                $AppName = 'SomeApp'
                $RemoveRoleFromAppName = 'SomeAppToRemoveRoleFrom'
                $AssignmentName = 'SomeAssignment'

                Mock Write-Host {}

                Mock Get-AzADApplication {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject] @{
                            Id = $ClientId;
                            AppId = $ClientId;
                            DisplayName = $AppName
                            AppRole = @([pscustomobject] @{
                                Id = $AppRoleId;
                                Value = $RoleName;
                                DisplayName = $RoleName;
                            })
                        };
                    } elseif ($Filter -eq "AppId eq '$RemoveRoleFromClientId'") {
                        return [pscustomobject]@{ AppId = $RemoveRoleFromClientId; DisplayName = $RemoveRoleFromAppName }
                    }
                }

                Mock Get-AzADServicePrincipal {
                    if ($Filter -eq "AppId eq '$ClientId'") {
                        return [pscustomobject]@{ AppId = $ClientId; Id = $ClientId; }
                    } elseif ($Filter -eq "AppId eq '$RemoveRoleFromClientId'") {
                        return [pscustomobject]@{ AppId = $RemoveRoleFromClientId; Id = $RemoveRoleFromClientId; }
                    }
                }

                Mock Get-MgServicePrincipalAppRoleAssignedTo {
                    $ServicePrincipalId | Should -Be $ClientId
                    return @([pscustomobject] @{
                        Id = $AppRoleId;
                        AppRoleId = $AppRoleId;
                        PrincipalId = $RemoveRoleFromClientId;
                        PrincipalDisplayName = $AssignmentName
                    })
                };

                Mock Remove-MgServicePrincipalAppRoleAssignment {
                    $ServicePrincipalId | Should -Be $RemoveRoleFromClientId
                    $AppRoleAssignmentId | Should -Be $AppRoleId
                    return $null
                };

                # Act
                Remove-AzADAppRoleAssignment -ClientId $ClientId -Role $RoleName -RemoveRoleFromClientId $RemoveRoleFromClientId

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Get-AzADApplication -Times 2
                Assert-MockCalled Get-AzADServicePrincipal -Times 2
                Assert-MockCalled Get-MgServicePrincipalAppRoleAssignedTo -Times 1
                Assert-MockCalled Remove-MgServicePrincipalAppRoleAssignment -Times 1
                Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Object -eq "Role assignment for '$RoleName' has been removed from Active Directory Application '$RemoveRoleFromAppName'" }
            }
        }
    }
}
