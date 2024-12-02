param(
    [string][parameter(Mandatory = $false)] $VariableGroupName,
    [string][parameter(Mandatory = $false)] $ArmOutputsEnvironmentVariableName = "ArmOutputs",
    [switch][parameter(Mandatory = $false)] $UpdateVariableGroup = $false,
    [switch][parameter(Mandatory = $false)] $UpdateVariablesForCurrentJob = $false
)

Write-Verbose "Geting ARM outputs from '$ArmOutputsEnvironmentVariableName' environment variable..."
$json = [System.Environment]::GetEnvironmentVariable($ArmOutputsEnvironmentVariableName)
$armOutputs = ConvertFrom-Json $json

foreach ($output in $armOutputs.PSObject.Properties) {
    $variableName = ($output.Name.Substring(0, 1).ToUpper() + $output.Name.Substring(1)).Trim()
    $variableValue = $output.Value.value
  
    if ($UpdateVariableGroup) {
        Write-Host Adding variable $output.Name with value $variableValue to variable group $VariableGroupName
        . $PSScriptRoot\Set-AzDevOpsGroupVariable.ps1 -VariableGroupName $VariableGroupName -VariableName $variableName -VariableValue $variableValue
    }

    if ($UpdateVariablesForCurrentJob) {
        Write-Host "The pipeline variable $variableName will be updated to value $variableValue, so it can be used in subsequent tasks of the current job"
        Write-Host "##vso[task.setvariable variable=$variableName]$variableValue"
    }
}