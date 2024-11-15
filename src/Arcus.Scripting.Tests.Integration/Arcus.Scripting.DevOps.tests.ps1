Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.DevOps -ErrorAction Stop

function global:Get-AzDevOpsGroup {
    params($VariableGroupName)

    $VariableGroupName = $VariableGroupName -replace ' ', '%20'
    $projectId = $env:SYSTEM_TEAMPROJECTID
    $collectionUri = $env:SYSTEM_COLLECTIONURI
    $getUri = "$collectionUri" + "$projectId/_apis/distributedtask/variablegroups?groupName=" + $VariableGroupName + "&api-version=7.1"
    $headers = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }

    Write-Host "GET -> $getUri"
    $getResponse = Invoke-WebRequest -Uri $getUri -Method Get -Headers $headers
    Write-Host "$($getResponse.StatusCode) <- $getUri"
    $json = ConvertFrom-Json $getResponse.Content
    
    return $json.value[0]
}

function global:Remove-AzDevOpsGroup {
    params($VariableGroupName)

    $variableGroup = Get-AzDevOpsGroup -VariableGroupName $VariableGroupName

    $VariableGroupName = $VariableGroupName -replace ' ', '%20'
    $projectId = $env:SYSTEM_TEAMPROJECTID
    $collectionUri = $env:SYSTEM_COLLECTIONURI
    $deleteUri = "$collectionUri" + "/_apis/distributedtask/variablegroups/" + $variableGroup.id + "?projectIds=$projectId&api-version=7.1"
    $headers = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }

    Write-Host "DELETE -> $deleteUri"
    $deleteResponse = Invoke-WebRequest -Uri $deleteUri -Method Delete -Headers $headers
    Write-Host "$($deleteResponse.StatusCode) <- $deleteUri"
}

function global:Get-AzDevOpsGroupVariable {
    params($VariableGroupName, $VariableName)

    $json = Get-AzDevOpsGroup -VariableGroupName $VariableGroupName
    $variable = $json.variables.PSObject.Properties | where { $_.Name -eq $VariableName }
    
    return $variable
}

function global:Remove-AzDevOpsGroupVariable {
    params($VariableGroupName, $VariableName)

    $json = Get-AzDevOpsGroup -VariableGroupName $VariableGroupName
    $json.variables.PSObject.Properties.Remove($VariableName)

    $upsertVariableGroupUrl = $projectUri + $project + "/_apis/distributedtask/variablegroups/$($json.id)?api-version=7.1"
    $headers = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }
    
    Write-Host "PUT -> $upsertVariableGroupUrl"
    $putResponse = Invoke-WebRequest -Uri $upsertVariableGroupUrl -Method Put -Headers $headers
    Write-Host "$($putResponse.StatusCode) <- $upsertVariableGroupUrl"
}

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
                        $expectedDate = (Get-Date).AddDays(10)
                        $actualDate = [DateTime]$lease.validUntil
                        $actualDate.ToUniversalTime().ToString("yyyy-MM-dd") |  Should -Be $expectedDate.ToUniversalTime().ToString("yyyy-MM-dd")
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
        }
        Context "Azure DevOps variable group" {
            It "Sets the DevOps variable group description with the release name" {
                # Arrange
                $variableGroupName = $config.Arcus.DevOps.VariableGroup.Name
                $variableGroupNameUrlEncoded = $config.Arcus.DevOps.VariableGroup.NameUrlEncoded
                $env:ArmOutputs = "{ ""my-variable"": { ""type"": ""string"", ""value"": ""my-value"" } }"
                #$variableGroupAuthorization contains a PAT with read access to variable groups, create a new one when it expires
                $variableGroupAuthorization = $config.Arcus.DevOps.VariableGroup.Authorization
                $projectId = $env:SYSTEM_TEAMPROJECTID                
                $collectionUri = $env:SYSTEM_COLLECTIONURI
                $requestUri = "$collectionUri" + "$projectId/_apis/distributedtask/variablegroups?groupName=" + $variableGroupNameUrlEncoded + "&api-version=6.1-preview.2"
                $headers = @{ Authorization = "Basic $variableGroupAuthorization" }

                # Act
                Set-AzDevOpsArmOutputsToVariableGroup -VariableGroupName $variableGroupName

                # Assert
                $getResponse = Invoke-WebRequest -Uri $requestUri -Method Get -Headers $headers
                $json = ConvertFrom-Json $getResponse.Content
                $json.value[0].description | Should -BeLike "*$env:Build_DefinitionName*$env:Build_BuildNumber*"
            }
            It "Sets a new variable to an existing DevOps variable group" {
                # Arrange
                $variableGroupName = $config.Arcus.DevOps.VariableGroup.Name
                $variableName = [System.Guid]::NewGuid().ToString()
                $expectedValue = [System.Guid]::NewGuid().ToString()
                try { 
                    # Act
                    Set-AzDevOpsGroupVariable -VariableGroupName $variableGroupName -VariableName $variableName -VariableValue $expectedValue
                    
                    # Assert
                    $actualValue = Get-AzDevOpsGroupVariable -VariableGroupName $variableGroupName -VariableName $variableName
                    $actualValue | Should -Be $variableValue

                } finally {
                    Remove-AzDevOpsGroupVariable -VariableGroupName $variableGroupName -VariableName $variableName
                }
            }
            It "Sets a new variable to a new DevOps variable group" {
                # Arrange
                $variableGroupName = [System.Guid]::NewGuid()
                $variableName = [System.Guid]::NewGuid()
                $variableValue = [System.Guid]::NewGuid()
                try {
                    # Act
                    Set-AzDevOpsVariable -VariableGroupName $variableGroupName -VariableName $variableName -VariableValue $variableValue

                    # Assert
                    $actualValue = Get-AzDevOpsGroupVariable -VariableGroupName $variableGroupName -VariableName $variableName
                    $actualValue | Should -Be $variableValue

                } finally {
                    Remove-AzDevOpsVariableGroup -VariableGroupName $variableGroupName
                }
            }
        }
    }
}
