param(
    [string][Parameter(Mandatory = $true)] $EnvironmentName,
    [string][parameter(Mandatory = $true)] $SubscriptionId,
    [string][Parameter(Mandatory = $true)] $ApiVersion
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
    
    $fullUrl = "$resourceManagerUrl" + "subscriptions/$SubscriptionId/Microsoft.ApiManagement/deletedservices" + "?api-version=$ApiVersion"

    return $fullUrl
}
catch {
    Write-Warning "Failed to define the resource management endpoint."
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
} 

