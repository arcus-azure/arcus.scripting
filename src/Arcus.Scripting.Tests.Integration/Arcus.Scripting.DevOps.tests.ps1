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
                $part = $env:SYSTEM_ACCESSTOKEN.Substring(0, 2)
                Write-Host "Access Token is like $part"
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
    }
}