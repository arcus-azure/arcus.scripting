param(
    [string][Parameter(Mandatory = $true)] $EnvironmentName,
    [string][parameter(Mandatory = $true)] $SubscriptionId,
    [string][parameter(Mandatory = $true)] $ResourceGroupName,
    [string][parameter(Mandatory = $true)] $LogicAppName,
    [string][parameter(Mandatory = $true)] $WorkflowName
)

try {
    $resourceManagerUrl = ""

    $environments = (Get-AzEnvironment).Name
    if ($EnvironmentName -notin $environments) {
        $supportedEnvironments = ""

        foreach ($env in $environments) {
            if ($supportedEnvironments.Length -eq 0) {
                $supportedEnvironments += $env
            }
            else {
                $supportedEnvironments += ", " + $env
            }
        }

        Write-Error "Unrecognized environment specified. Supported values are: $supportedEnvironments"
    }

    $resourceManagerUrl = (Get-AzEnvironment -Name $EnvironmentName).ResourceManagerUrl
    
    $fullUrl = "$resourceManagerUrl" + "subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$LogicAppName/hostruntime/runtime/webhooks/workflow/api/management/workflows/$WorkflowName/runs?api-version=2022-03-01"
    return $fullUrl
} catch {
    Write-Warning "Failed to define the resource management endpoint (Environment: '$EnvironmentName', SubscriptionId: '$SubscriptionId', ResourceGroup: '$ResourceGroupName', LogicApp: '$LogicAppName', WorkflowName: '$WorkflowName')"
    $ErrorMessage = $_.Exception.Message
    Write-Debug "Error: $ErrorMessage"
}