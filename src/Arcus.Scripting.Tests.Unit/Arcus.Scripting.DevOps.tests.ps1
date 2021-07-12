Describe "Arcus" {
    Context "Azure DevOps" {
        InModuleScope Arcus.Scripting.DevOps {
            It "Setting DevOps variable should write to host" {
                # Arrange
                Mock Write-Host { $Object | Should -Be "#vso[task.setvariable variable=test] value" } -Verifiable
                
                # Act
                Set-AzDevOpsVariable "test" "value"
                
                # Assert
                Assert-VerifiableMock
            }
            It "Setting DevOps variable group from ARM outputs should send info to DevOps project" {
                # Arrange
                $variableGroupName = "some-variable-group-name"
                $env:ArmOutputs = "{ ""$variableGroupName"": [ { ""Name"": ""my-variable"", ""Value"": { ""value"": ""my-value"" } } ] }"
                $env:SYSTEM_ACCESSTOKEN = "something to fill"
                
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
            It "Setting DevOps variable group from ARM outputs should send info to DevOps project and update current job pipeline variables" {
                # Arrange
                $variableGroupName = "some-variable-group-name"
                $env:ArmOutputs = "{ ""$variableGroupName"": [ { ""Name"": ""my-variable"", ""Value"": { ""value"": ""my-value"" } } ] }"
                $env:SYSTEM_ACCESSTOKEN = "something to fill"

                $variableName = "some-id"
                $setCurrentJobVariable = $false

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
                Mock Write-Host { } -ParameterFilter { $Object -like "*task.setvariable*" } -Verifiable

                # Act
                Set-AzDevOpsArmOutputsToVariableGroup -VariableGroupName $variableGroupName -UpdateVariablesForCurrentJob

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Write-Host
            }
            It "Setting DevOps variable group from custom ARM outputs variable should send info to DevOps project and update current job pipeline variables" {
                # Arrange
                $variableGroupName = "some-variable-group-name"
                $env:MyArmOutputs = "{ ""$variableGroupName"": [ { ""Name"": ""my-variable"", ""Value"": { ""value"": ""my-value"" } } ] }"
                $env:SYSTEM_ACCESSTOKEN = "something to fill"

                $variableName = "some-id"
                $setCurrentJobVariable = $false

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
                Mock Write-Host { } -ParameterFilter { $Object -like "*task.setvariable*" } -Verifiable

                # Act
                Set-AzDevOpsArmOutputsToVariableGroup -VariableGroupName $variableGroupName -ArmOutputsEnvironmentVariableName "MyArmOutputs" -UpdateVariablesForCurrentJob

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Write-Host
            }
            It "Setting pipeline variables from default ARM outputs variable writes to output" {
                # Arrange
                $variableGroupName = "some-variable-group-name"
                $env:ArmOutputs = "{ ""$variableGroupName"": [ { ""Name"": ""my-variable"", ""Value"": { ""value"": ""my-value"" } } ] }"

                Mock Write-Host { } -ParameterFilter { $Object -like "*task.setvariable*" } -Verifiable

                # Act
                Set-AzDevOpsArmOutputsToPipelineVariables

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Write-Host
            }
            It "Setting pipeline variables from custom ARM outputs variable writes to output" {
                # Arrange
                $variableGroupName = "some-variable-group-name"
                $env:MyArmOutputs = "{ ""$variableGroupName"": [ { ""Name"": ""my-variable"", ""Value"": { ""value"": ""my-value"" } } ] }"

                Mock Write-Host { } -ParameterFilter { $Object -like "*task.setvariable*" } -Verifiable

                # Act
                Set-AzDevOpsArmOutputsToPipelineVariables -ArmOutputsEnvironmentVariableName "MyArmOutputs"

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Write-Host
            }
            It "Save-AzDevOpsBuild fails when API call does not return success-code" {
                # Arrange
                $env:SYSTEM_COLLECTIONURI = "https://dev.azure.com/myorganization/"
                $env:ACCESS_TOKEN = "mocking accesstoken"
                $projectId = "abc123"
                $buildId = 128                

                Mock Invoke-WebRequest {
                    $statusCode = 400                   
                    $response = New-Object System.Net.Http.HttpResponseMessage $statusCode
                    return $response
                } -ModuleName Arcus.Scripting.DevOps

                # Act and Assert
                { Save-AzDevOpsBuild -ProjectId $projectId -BuildId $buildId  } | Should -Throw
            }
            It "Save-AzDevOpsBuild succeeds when API call does return success-code" {
                # Arrange
                $env:SYSTEM_COLLECTIONURI = "https://dev.azure.com/myorganization/"
                $env:ACCESS_TOKEN = "mocking accesstoken"
                $projectId = "abc123"
                $buildId = 128  

                Mock Invoke-WebRequest {  
                    $statusCode = 200                    
                    $response = New-Object System.Net.Http.HttpResponseMessage $statusCode
                    return $response
                 } -ModuleName Arcus.Scripting.DevOps               

                # Act and Assert
                { Save-AzDevOpsBuild -ProjectId $projectId -BuildId $buildId } | Should -Not -Throw
            }
            It "Save-AzDevOpsBuild correctly builds API endpoint when CollectionUri has trailing slash" {
                # Arrange
                $env:SYSTEM_COLLECTIONURI = "https://dev.azure.com/myorganization/"
                $env:ACCESS_TOKEN = "mocking accesstoken"
                $projectId = "abc123"
                $buildId = 128  

                Mock Invoke-WebRequest {  
                    $statusCode = 200                    
                    $response = New-Object System.Net.Http.HttpResponseMessage $statusCode
                    return $response
                 } -ModuleName Arcus.Scripting.DevOps               

                # Act
                Save-AzDevOpsBuild  -ProjectId $projectId -BuildId $buildId 

                # Assert
                Should -Invoke -CommandName Invoke-WebRequest -Times 1 -ParameterFilter { Uri -Like "https://dev.azure.com/myorganization/$projectId/*" }                
            }
            It "Save-AzDevOpsBuild correctly builds API endpoint when CollectionUri does not have trailing slash" {
                # Arrange
                $env:SYSTEM_COLLECTIONURI = "https://dev.azure.com/myorganization"
                $env:ACCESS_TOKEN = "mocking accesstoken"
                $projectId = "abc123"
                $buildId = 128  

                Mock Invoke-WebRequest {  
                    $statusCode = 200                    
                    $response = New-Object System.Net.Http.HttpResponseMessage $statusCode
                    return $response
                 } -ModuleName Arcus.Scripting.DevOps               

                # Act
                Save-AzDevOpsBuild  -ProjectId $projectId -BuildId $buildId 

                # Assert
                Should -Invoke -CommandName Invoke-WebRequest -Times 1 -ParameterFilter { Uri -Like "https://dev.azure.com/myorganization/$projectId/*" }                
            }
        }        
    }
}
