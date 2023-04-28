Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.DevOps -ErrorAction Stop

InModuleScope Arcus.Scripting.DevOps {
    Describe "Arcus Azure DevOps integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
        }
        Context "Save Azure DevOps build" {
            It "Saves the Azure DevOps build indefinitely" {
                # Arrange
                $projectId = $env:SYSTEM_TEAMPROJECTID
                $buildId = $env:BUILD_BUILDID
                $collectionUri = $env:SYSTEM_COLLECTIONURI
                $requestUri = "$collectionUri" + "$projectId/_apis/build/builds/" + $buildId + "/leases?api-version=7.0"
                $headers = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }
                try {
                    # Act
                    Save-AzDevOpsBuild -ProjectId $projectId -BuildId $buildId

                    # Assert
                    $getResponse = Invoke-WebRequest -Uri $requestUri -Method Get -Headers $headers
                    $json = ConvertFrom-Json $getResponse.Content
                    foreach ($lease in $json.value) {
                        $lease.protectPipeline | Should -Be $true
                        $date = Get-Date -Year 2200 -Month 1 -Day 1
                        $lease.validUntil | Should -BeGreaterThan $date
                    }
                } finally {
                    $getResponse = Invoke-WebRequest -Uri $requestUri -Method Get -Headers $headers
                    $json = ConvertFrom-Json $getResponse.Content
                    foreach ($lease in $json.value) {
                        $deleteUri = "$collectionUri" + "$projectId/_apis/build/retention/leases?ids=" + $lease.leaseId + "&api-version=7.0"
                        $deleteResponse = Invoke-WebRequest -Uri $deleteUri -Method Delete -Headers $headers
                        $deleteResponse.StatusCode | Should -Be 204
                    }
                }
            }
            It "Saves the Azure DevOps build for 10 days" {
                # Arrange
                $projectId = $env:SYSTEM_TEAMPROJECTID
                $buildId = $env:BUILD_BUILDID
                $collectionUri = $env:SYSTEM_COLLECTIONURI
                $requestUri = "$collectionUri" + "$projectId/_apis/build/builds/" + $buildId + "/leases?api-version=7.0"
                $headers = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }
                try {
                    # Act
                    Save-AzDevOpsBuild -ProjectId $projectId -BuildId $buildId -DaysToKeep 10

                    # Assert
                    $getResponse = Invoke-WebRequest -Uri $requestUri -Method Get -Headers $headers
                    $json = ConvertFrom-Json $getResponse.Content
                    foreach ($lease in $json.value) {
                        $lease.protectPipeline | Should -Be $true
                        $dateGreaterThan = (Get-Date).AddDays(9)
                        $dateLessThan = (Get-Date).AddDays(11)
                        $lease.validUntil | Should -BeGreaterThan $dateGreaterThan
                        $lease.validUntil | Should -BeLessThan $dateLessThan
                    }
                } finally {
                    $getResponse = Invoke-WebRequest -Uri $requestUri -Method Get -Headers $headers
                    $json = ConvertFrom-Json $getResponse.Content
                    foreach ($lease in $json.value) {
                        $deleteUri = "$collectionUri" + "$projectId/_apis/build/retention/leases?ids=" + $lease.leaseId + "&api-version=7.0"
                        $deleteResponse = Invoke-WebRequest -Uri $deleteUri -Method Delete -Headers $headers
                        $deleteResponse.StatusCode | Should -Be 204
                    }
                }
            }
            It "Sets the DevOps variable group description with the release name" -Skip {
                # Arrange
                $variableGroupName = $config.Arcus.DevOps.VariableGroup.Name
                $env:ArmOutputs = "{ ""my-variable"": { ""type"": ""string"", ""value"": ""my-value"" } }"
                $projectId = $env:SYSTEM_TEAMPROJECTID                
                $collectionUri = $env:SYSTEM_COLLECTIONURI
                $requestUri = "$collectionUri" + "$projectId/_apis/distributedtask/variablegroups?groupName=/" + $variableGroupName + "?api-version=6.0"
                $headers = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }

                # Act
                Set-AzDevOpsArmOutputsToVariableGroup -VariableGroupName $variableGroupName

                # Assert
                $getResponse = Invoke-WebRequest -Uri $requestUri -Method Get -Headers $headers
                $json = ConvertFrom-Json $getResponse.Content
                $json.description | Should -BeLike "*$env:Build_DefinitionName*$env:Build_BuildNumber*"
            }
        }
    }
}
