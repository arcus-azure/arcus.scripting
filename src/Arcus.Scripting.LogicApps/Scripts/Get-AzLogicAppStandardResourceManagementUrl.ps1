param(
    [string][Parameter(Mandatory = $true)] $EnvironmentName,
    [string][parameter(Mandatory = $true)] $SubscriptionId,
    [string][parameter(Mandatory = $true)] $ResourceGroupName,
    [string][parameter(Mandatory = $true)] $LogicAppName,
    [string][parameter(Mandatory = $true)] $WorkflowName,
    [string][parameter(Mandatory = $false)] $RunName,
    [string][parameter(Mandatory = $false)] $TriggerName,
    [string][Parameter(Mandatory = $true)][ValidateSet('listWaiting', 'listRunning', 'listFailed', 'cancel', 'resubmit')] $Action
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
    
    if ($Action -eq 'listWaiting') {
        $fullUrl = "$resourceManagerUrl" + "subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$LogicAppName/hostruntime/runtime/webhooks/workflow/api/management/workflows/$WorkflowName/runs?api-version=2022-03-01&%24filter=Status%20eq%20'Waiting'"
    } elseIf ($Action -eq 'listRunning') {
        $fullUrl = "$resourceManagerUrl" + "subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$LogicAppName/hostruntime/runtime/webhooks/workflow/api/management/workflows/$WorkflowName/runs?api-version=2022-03-01&%24filter=Status%20eq%20'Running'"
    } elseIf ($Action -eq 'listFailed') {
        $fullUrl = "$resourceManagerUrl" + "subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$LogicAppName/hostruntime/runtime/webhooks/workflow/api/management/workflows/$WorkflowName/runs?api-version=2022-03-01&%24filter=Status%20eq%20'Failed'"
    } elseIf ($Action -eq 'cancel') {
        $fullUrl = "$resourceManagerUrl" + "subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$LogicAppName/hostruntime/runtime/webhooks/workflow/api/management/workflows/$WorkflowName/runs/$RunName/cancel?api-version=2022-03-01"
    } elseIf ($Action -eq 'resubmit') {
        $fullUrl = "$resourceManagerUrl" + "subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$LogicAppName/hostruntime/runtime/webhooks/workflow/api/management/workflows/$WorkflowName/triggers/$TriggerName/histories/$RunName/resubmit?api-version=2022-03-01"
    }

    return $fullUrl
} catch {
    Write-Warning "Failed to define the resource management endpoint (Environment: '$EnvironmentName', SubscriptionId: '$SubscriptionId', ResourceGroup: '$ResourceGroupName', LogicApp: '$LogicAppName', WorkflowName: '$WorkflowName')"
    $ErrorMessage = $_.Exception.Message
    Write-Debug "Error: $ErrorMessage"
}