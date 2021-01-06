param(
    [string][Parameter(Mandatory = $true)] $EnvironmentName,
    [string][parameter(Mandatory = $true)] $SubscriptionId,
    [string][parameter(Mandatory = $true)] $ResourceGroupName,
    [string][parameter(Mandatory = $true)] $LogicAppName,
    [string][Parameter(Mandatory = $true)] $ApiVersion,
    [string][Parameter(Mandatory = $true)][ValidateSet('enable','disable')] $Action
)


try{
    $resourceManagerUrl = ""   
    
    $environments = (Get-AzEnvironment).Name
    if($EnvironmentName -notin $environments){
        $supportedEnvironments = ""

        foreach($env in $environments){
            if($supportedEnvironments.Length -eq 0) {
                $supportedEnvironments += $env
            }
            else{
                $supportedEnvironments += ", " + $env
            }
        }

        Write-Error "Unrecognized environment specified. Supported values are: $supportedEnvironments"
    }

    $resourceManagerUrl = (Get-AzEnvironment -Name $EnvironmentName).ResourceManagerUrl
    
    $fullUrl = "$resourceManagerUrl" + "subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows/$LogicAppName/$Action" + "?api-version=$ApiVersion"
   
    return $fullUrl
}
catch {
    Write-Warning "Failed to define the resource management endpoint."
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
} 

