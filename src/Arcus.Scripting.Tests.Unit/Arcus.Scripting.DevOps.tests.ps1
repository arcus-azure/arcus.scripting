Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.DevOps -ErrorAction Stop

Describe "Arcus" {
    Context "Azure DevOps" {
        InModuleScope Arcus.Scripting.DevOps {
            It "Seting DevOps variable should write to host" {
                # Arrange
                Mock Write-Host { $Object | Should -Be "#vso[task.setvariable variable=test] value" } -Verifiable
                
                # Act
                Set-AzDevOpsVariable "test" "value"
                
                # Assert
                Assert-VerifiableMock
            }
            It "Setting DevOps variable group from ARM outputs should send info to DevOps project" {
                # Arrange
                $env:ArmOutputs = "{ ""Properties"": [ { ""Name"": ""my-variable"", ""Value"": ""my-value"" } ] }"
                $env:SYSTEM_ACCESSTOKEN = "something to fill"
                $variableGroupName = "some-variable-group-name"

                Mock Invoke-RestMethod {
                    $Uri | Should -BeLike "*$variableGroupName*"
                    if ($Method -eq "Get") {
                        [pscustomobject]@{ value = @{ id = "some-id" } }
                    } else {
                        $Uri | Should -BeLike "*some-id*"
                        return $null
                    }
                } -Verifiable

                # Act
                Set-AzDevOpsArmOutputsToVariableGroup -VariableGroupName $variableGroupName

                # Assert
                Assert-VerifiableMock
            }
        }
    }
}
