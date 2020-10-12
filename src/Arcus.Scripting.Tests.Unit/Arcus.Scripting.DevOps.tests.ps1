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
                $env:ArmOutputs = "{ ""PSObject"": { ""Properties"": [ { ""Name"": ""my-variable"", ""Value"": { ""value"": ""my-value"" } } ] } }"
                $env:SYSTEM_ACCESSTOKEN = "something to fill"
                $variableGroupName = "some-variable-group-name"
                $variableName = "some-id"

                Mock Invoke-RestMethod {
                    if ($Method -eq "Post" -or $Method -eq "Put") {
                        $Uri | Should -BeLike "*$variableGroupName*"
                        $Body | Should -BeLike "*$variableName*"
                        return $null
                    } else {
                        $Uri | Should -BeLike "*$variableGroupName*"
                        return [pscustomobject]@{ value = @( [pscustomobject]@{ id = $variableName; variables = [pscustomobject]@{} } ) }
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
