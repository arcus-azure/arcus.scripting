param(
    [string][parameter(Mandatory = $false)] $VariableGroupName,
    [string][parameter(Mandatory = $false)] $ArmOutputsEnvironmentVariableName = "ArmOutputs",
    [switch][parameter(Mandatory = $false)] $UpdateVariableGroup = $false,
    [switch][parameter(Mandatory = $false)] $UpdateVariablesForCurrentJob = $false
)

function Add-VariableGroupVariable() {
    [CmdletBinding()]
    param(
        [string][parameter(Mandatory = $true)]$VariableGroupName,
        [string][parameter(Mandatory = $true)]$variableName,
        [string][parameter(Mandatory = $true)]$variableValue
    )
    BEGIN {
        Write-Verbose "Retrieving Azure DevOps project details for variable group '$VariableGroupName'..."
        [String]$project = "$env:SYSTEM_TEAMPROJECT"
        [String]$projectUri = "$env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI"
        [String]$apiVersion = "4.1-preview.1"
        Write-Debug "Using Azure DevOps project: $project, project URI: $projectUri"
        

        Write-Verbose "Setting authorization headers to retrieve potential existing Azure DevOps variable group '$VariableGroupName'..."
        if ([string]::IsNullOrEmpty($env:SYSTEM_ACCESSTOKEN)) {
            Write-Error "The SYSTEM_ACCESSTOKEN environment variable is empty. Remember to explicitly allow the build job to access the OAuth Token!"
        }
        $headers = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }


        Write-Verbose "Getting Azure DevOps variable group '$VariableGroupName'..."
        $getVariableGroupUrl = $projectUri + $project + "/_apis/distributedtask/variablegroups?api-version=" + $apiVersion + "&groupName=" + $VariableGroupName
        $variableGroup = (Invoke-RestMethod -Uri $getVariableGroupUrl -Headers $headers -Verbose)

        $releaseName = $env:RELEASE_RELEASENAME
        if ([string]::IsNullOrEmpty($releaseName)) {
            $releaseName = $env:BUILD_DEFINITIONNAME + " " + $env:BUILD_BUILDNUMBER
        }
        
        if ($variableGroup.value) {
            Write-Host "Set properties for update of existing Azure DevOps variable group '$variableGroupName'"
            $variableGroup = $variableGroup.value[0]
            $variableGroup | Add-Member -Name "description" -MemberType NoteProperty -Value "Variable group that got auto-updated by release '$releaseName'." -Force
            $method = "Put"
            $upsertVariableGroupUrl = $projectUri + $project + "/_apis/distributedtask/variablegroups/" + $variableGroup.id + "?api-version=" + $apiVersion    
        } else {
            Write-Host "Set properties for creation of new Azure DevOps variable group '$VariableGroupName'"
            $variableGroup = @{name = $VariableGroupName; type = "Vsts"; description = "Variable group that got auto-updated by release '$releaseName'."; variables = New-Object PSObject; }
            $method = "Post"
            $upsertVariableGroupUrl = $projectUri + $project + "/_apis/distributedtask/variablegroups?api-version=" + $apiVersion
        }

        $variableGroup.variables | Add-Member -Name $variableName -MemberType NoteProperty -Value @{value = $variableValue } -Force

        Write-Verbose "Upserting Azure DevOps variable group '$variableGroupName'..."
        $body = $variableGroup | ConvertTo-Json -Depth 10 -Compress
        Write-Debug $body
        Invoke-RestMethod $upsertVariableGroupUrl -Method $method -Body $body -Headers $headers -ContentType 'application/json; charset=utf-8' -Verbose
    }
}

Write-Verbose "Geting ARM outputs from '$ArmOutputsEnvironmentVariableName' environment variable..."
$json = [System.Environment]::GetEnvironmentVariable($ArmOutputsEnvironmentVariableName)
$armOutputs = ConvertFrom-Json $json

foreach ($output in $armOutputs.PSObject.Properties) {
    $variableName = ($output.Name.Substring(0, 1).ToUpper() + $output.Name.Substring(1)).Trim()
    $variableValue = $output.Value.value
  
    if ($UpdateVariableGroup) {
        Write-Host Adding variable $output.Name with value $variableValue to variable group $VariableGroupName
        Add-VariableGroupVariable -VariableGroupName $VariableGroupName -variableName $variableName -variableValue $variableValue
    }

    if ($UpdateVariablesForCurrentJob) {
        Write-Host "The pipeline variable $variableName will be updated to value $variableValue, so it can be used in subsequent tasks of the current job"
        Write-Host "##vso[task.setvariable variable=$variableName]$variableValue"
    }
}