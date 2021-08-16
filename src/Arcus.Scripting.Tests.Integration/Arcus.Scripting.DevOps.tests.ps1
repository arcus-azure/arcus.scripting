Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.DevOps -ErrorAction Stop

InModuleScope Arcus.Scripting.DevOps {
    Describe "Arcus Azure DevOps integration tests" {
        BeforeEach {
            $filePath = "$PSScriptRoot\appsettings.json"
            [string]$appsettings = Get-Content $filePath
            $config = ConvertFrom-Json $appsettings
            
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
        }
        Context "Save Azure DevOps build" {
            It "Saves the Azure DevOps build indefinetely" {
                # Arrange
                $projectId = $env:SYSTEM_TEAMPROJECTID
                $buildId = $env:BUILD_BUILDID
                $collectionUri = $env:SYSTEM_COLLECTIONURI
                $requestUri = "$collectionUri" + "$projectId/_apis/build/builds/" + $buildId + "?api-version=6.0"
                $headers = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }
                try {
                    # Act
                    Save-AzDevOpsBuild -ProjectId $projectId -BuildId $buildId
        
                    # Assert
                    $getResponse = Invoke-WebRequest -Uri $requestUri -Method Get -Headers $headers
                    $json = ConvertFrom-Json $getResponse.Content
                    $json.keepForever | Should -Be $true
                } finally {
                    $retentionPayload = @{ keepforever='false' }
                    $requestBody = $retentionPayload | ConvertTo-Json -Compress
                    $patchResponse = Invoke-WebRequest -Uri $requestUri -Method Patch -Headers $headers -Body $requestBody -ContentType "application/json"
                    $patchResponse.StatusCode | Should -Be 200
                }
            }
        }
        Context "Set ARM outputs as DevOps variable" {
            It "Adds ARM outputs as a new default DevOps variable to an existing variable group" {
                # Arrange
                $existingVariableGroup = $config.Arcus.DevOps.VariableGroup.Name
                $variableName = "MyVariable"
                $variableValue = [System.Guid]::NewGuid()
                $env:ArmOutputs = "{ ""$variableName"": [ { ""Name"": ""$variableName"", ""Value"": { ""value"": ""$variableValue"" } } ] }"

                $project = "$env:SYSTEM_TEAMPROJECT"
                $projectUri = "$env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI"
                $apiVersion = "4.1-preview.1"
                
                $headers = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }
                $variableGroup = $null

                #try {
                    # Act
                    Set-AzDevOpsArmOutputsToVariableGroup -VariableGroupName $existingVariableGroup

                    # Assert
                    $getVariableGroupUrl= $projectUri + $project + "/_apis/distributedtask/variablegroups?api-version=" + $apiVersion + "&groupName=" + $existingVariableGroup
                    $variableGroup = Invoke-RestMethod -Uri $getVariableGroupUrl -Headers $headers -Verbose
                    $variableGroup = $variableGroup.value[0]
                    $variableGroup.variables.$variableName | Should -Not -Be $null
                    $variableGroup.variables.$variableName.value | Should -Be "@{value=$variableValue}"
                #} finally {
                    $variableGroup | Add-Member -Name "description" -MemberType NoteProperty -Value "Variable group reverted" -Force
                    $variableGroup.variables.PSObject.Members.Remove($variableName)

                    $upsertVariableGroupUrl = $projectUri + $project + "/_apis/distributedtask/variablegroups/" + $variableGroup.id + "?api-version=" + $apiVersion 
                    $body = $variableGroup | ConvertTo-Json -Depth 10 -Compress
                    Invoke-RestMethod $upsertVariableGroupUrl -Method "Put" -Body $body -Headers $headers -ContentType 'application/json; charset=utf-8' -Verbose
                #}
            }
        }
    }
}
