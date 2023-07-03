param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of the resource group is required"),
    [Parameter(Mandatory = $true)][string] $LogicAppName = $(throw "Name of the logic app is required"),
    [Parameter(Mandatory = $true)][datetime] $StartTime = $(throw "Start time is required"),
    [Parameter(Mandatory = $false)][datetime] $EndTime,
    [Parameter(Mandatory = $false)][int] $MaximumFollowNextPageLink
)

try{
    if (!$maximumFollowNextPageLink) {
        $maximumFollowNextPageLink = 10
    }

    if ($EndTime) {
        $runs = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $LogicAppName -FollowNextPageLink -MaximumFollowNextPageLink $maximumFollowNextPageLink | 
            Where-Object {$_.Status -eq 'Failed' -and $_.StartTime -ge $StartTime -and $_.EndTime -le $EndTime}
    } else {
        $runs = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $LogicAppName -FollowNextPageLink -MaximumFollowNextPageLink $maximumFollowNextPageLink | 
            Where-Object {$_.Status -eq 'Failed' -and $_.StartTime -ge $StartTime}
    }

    $token = Get-AzCachedAccessToken
    $accessToken = $token.AccessToken
    $subscriptionId = $token.SubscriptionId

    foreach ($run in $runs) {
        $triggerName = $run.Trigger.Name
        $runId = $run.Name
        $resubmitUrl = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows/$LogicAppName/triggers/$triggerName/histories/$runId/resubmit?api-version=2016-06-01"
        
        $params = @{
            Method = 'Post'
            Headers = @{ 
	            'authorization'="Bearer $accessToken"
            }
            URI = $resubmitUrl
        }

        $web = Invoke-WebRequest @params -ErrorAction Stop
        
        Write-Verbose "Resubmitted run $runId for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'"
    }

    if ($EndTime) {
        Write-Host "Successfully resubmitted all failed instances for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName' from '$StartTime' and until '$EndTime'" -ForegroundColor Green
    } else {
        Write-Host "Successfully resubmitted all failed instances for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName' from '$StartTime'" -ForegroundColor Green
    }
} catch {
    if ($EndTime) {
        throw "Failed to resubmit all failed instances for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName' from '$StartTime' and until '$EndTime'. Details: $($_.Exception.Message)"
    } else {
        throw "Failed to resubmit all failed instances for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName' from '$StartTime'. Details: $($_.Exception.Message)"
    }
}