param(
    [Parameter(Mandatory = $true)][string] $EnvironmentName
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

    return $resourceManagerUrl
}
catch {
    Write-Warning "Failed to retrieve the resource management endpoint."
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
} 

