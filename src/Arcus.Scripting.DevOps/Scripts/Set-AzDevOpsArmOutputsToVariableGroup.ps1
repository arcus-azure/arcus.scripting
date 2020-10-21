param(
   [string][parameter(Mandatory = $true)] $VariableGroupName,
   [string][parameter(Mandatory = $false)] $ArmOutputsEnvironmentVariableName = "ArmOutputs",
   [switch][parameter()] $UpdateVariablesForCurrentJob = $false
)

function Add-VariableGroupVariable()
{
    [CmdletBinding()]
    param
    (
        [string][parameter(Mandatory = $true)]$VariableGroupName,
        [string][parameter(Mandatory = $true)]$variableName,
        [string][parameter(Mandatory = $true)]$variableValue
    )
    BEGIN
    {
        #Retrieve project details
        Write-Host Retrieving project details
        
        [String]$project = "$env:SYSTEM_TEAMPROJECT"
        [String]$projectUri = "$env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI"
        [String]$apiVersion = "4.1-preview.1"
        
        Write-Host Project: $project
        Write-Host ProjectUri: $projectUri
        

        #Set authorization headers 
        Write-Host Set authorization headers
        if ([string]::IsNullOrEmpty($env:SYSTEM_ACCESSTOKEN))
        {
            Write-Error "The SYSTEM_ACCESSTOKEN environment variable is empty. Remember to explicitly allow the build job to access the OAuth Token!"
        }
        $headers = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }


        #Get variable group
        Write-Host Get variable group
        $getVariableGroupUrl= $projectUri + $project + "/_apis/distributedtask/variablegroups?api-version=" + $apiVersion + "&groupName=" + $VariableGroupName
        $variableGroup = (Invoke-RestMethod -Uri $getVariableGroupUrl -Headers $headers -Verbose) 
        
        if($variableGroup.value)
        {
            #Set properties for update of existing variable group
            Write-Host Set properties for update of existing variable group
            $variableGroup = $variableGroup.value[0]
			$variableGroup | Add-Member -Name "description" -MemberType NoteProperty -Value "Variable group that got auto-updated by release '$env:Release_ReleaseName'." -Force
            $method = "Put"
            $upsertVariableGroupUrl = $projectUri + $project + "/_apis/distributedtask/variablegroups/" + $variableGroup.id + "?api-version=" + $apiVersion    
        }
        else
        {
            #Set properties for creation of new variable group
            Write-Host Set properties for creation of new variable group
            $variableGroup = @{name=$VariableGroupName;type="Vsts";description="Variable group that got auto-updated by release '$env:Release_ReleaseName'.";variables=New-Object PSObject;}
            $method = "Post"
            $upsertVariableGroupUrl = $projectUri + $project + "/_apis/distributedtask/variablegroups?api-version=" + $apiVersion
        }

        #Add variable
        $variableGroup.variables | Add-Member -Name $variableName -MemberType NoteProperty -Value @{value=$variableValue} -Force

        #Upsert variable group
        Write-Host Upsert variable group
        $body = $variableGroup | ConvertTo-Json -Depth 10 -Compress
        Write-Host $body
        Invoke-RestMethod $upsertVariableGroupUrl -Method $method -Body $body -Headers $headers -ContentType 'application/json; charset=utf-8' -Verbose
    }
}

Write-Host "Get ARM outputs from '$ArmOutputsEnvironmentVariableName' environment variable"
$json = [System.Environment]::GetEnvironmentVariable($ArmOutputsEnvironmentVariableName)
$armOutputs = ConvertFrom-Json $json

foreach ($output in $armOutputs.PSObject.Properties) {
  $variableName = ($output.Name.Substring(0,1).ToUpper() + $output.Name.Substring(1)).Trim()
  $variableValue = $output.Value.value
  
  Write-Host Adding variable $output.Name with value $variableValue to variable group $VariableGroupName
  Add-VariableGroupVariable -VariableGroupName $VariableGroupName -variableName $variableName -variableValue $variableValue
  
  if ($UpdateVariablesForCurrentJob) {
	Write-Host The pipeline variable $variableName will be updated to value $variableValue as well, so it can be used in subsequent tasks of the current job. 
	Write-Host "##vso[task.setvariable variable=$variableName]$variableValue"
  }
}