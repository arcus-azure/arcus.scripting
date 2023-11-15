param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of the resource group is required"),
    [Parameter(Mandatory = $true)][string] $LogicAppName = $(throw "Name of the logic app is required"),
    [Parameter(Mandatory = $false)][string] $WorkflowName = "",
    [Parameter(Mandatory = $true)][datetime] $StartTime = $(throw "Start time is required"),
    [Parameter(Mandatory = $false)][datetime] $EndTime,
    [Parameter(Mandatory = $false)][int] $MaximumFollowNextPageLink = 10,
    [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud"
)

$Global:accessToken = "";
$Global:subscriptionId = "";

try{
    $token = Get-AzCachedAccessToken  -AssignGlobalVariables

    if ($WorkflowName -eq "") {
        if ($EndTime) {
            $runs = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $LogicAppName -FollowNextPageLink -MaximumFollowNextPageLink $MaximumFollowNextPageLink | 
                Where-Object {$_.Status -eq 'Failed' -and $_.StartTime -ge $StartTime -and $_.EndTime -le $EndTime}
        } else {
            $runs = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $LogicAppName -FollowNextPageLink -MaximumFollowNextPageLink $MaximumFollowNextPageLink | 
                Where-Object {$_.Status -eq 'Failed' -and $_.StartTime -ge $StartTime}
        }
        
        foreach ($run in $runs) {
            $triggerName = $run.Trigger.Name
            $runId = $run.Name
            $resubmitUrl = "https://management.azure.com/subscriptions/$Global:subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows/$LogicAppName/triggers/$triggerName/histories/$runId/resubmit?api-version=2016-06-01"
        
            $params = @{
                Method = 'Post'
                Headers = @{ 
	                'authorization'="Bearer $Global:accessToken"
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
    } else {
        $listFailedUrl = . $PSScriptRoot\Get-AzLogicAppStandardResourceManagementUrl.ps1 -EnvironmentName $EnvironmentName -SubscriptionId $Global:subscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -WorkflowName $WorkflowName -StartTime $StartTime -Action 'listFailed'
        $listFailedParams = @{
            Method = 'Get'
            Headers = @{ 
                'authorization'="Bearer $Global:accessToken"
            }
            URI = $listFailedUrl
        }

        $failedRuns = Invoke-WebRequest @listFailedParams -ErrorAction Stop
        $failedRunsContent = $failedRuns.Content | ConvertFrom-Json
        $allFailedRuns = $failedRunsContent.value        

        if ($failedRunsContent.nextLink -ne $null) {
            $nextPageCounter = 1
            $nextPageUrl = $failedRunsContent.nextLink
            while ($nextPageUrl -ne $null -and $nextPageCounter -le $MaximumFollowNextPageLink) {
                $nextPageCounter = $nextPageCounter + 1
                $listFailedParams = @{
                    Method = 'Get'
                    Headers = @{ 
                        'authorization'="Bearer $Global:accessToken"
                    }
                    URI = $nextPageUrl
                }

                $failedRunsNextPage = Invoke-WebRequest @listFailedParams -ErrorAction Stop
                $failedRunsNextPageContent = $failedRunsNextPage.Content | ConvertFrom-Json
                $nextPageUrl = $failedRunsNextPageContent.nextLink
                $allFailedRuns = $allFailedRuns + $failedRunsNextPageContent.value
            }
        }

        foreach ($failedRun in $allFailedRuns) {
            $runName = $failedRun.name
            $triggerName = $failedRun.properties.trigger.name

            $resubmitUrl = . $PSScriptRoot\Get-AzLogicAppStandardResourceManagementUrl.ps1 -EnvironmentName $EnvironmentName -SubscriptionId $Global:subscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -WorkflowName $WorkflowName -TriggerName $triggerName -RunName $runName -Action 'resubmit'
            $resubmitParams = @{
                Method = 'Post'
                Headers = @{ 
                    'authorization'="Bearer $Global:accessToken"
                }
                URI = $resubmitUrl
            }
            $resubmit = Invoke-WebRequest @resubmitParams -ErrorAction Stop
            Write-Verbose "Resubmit run '$runName' for the workflow '$WorkflowName' in Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'"
        }

        Write-Host "Successfully resubmitted all failed instances for the workflow '$WorkflowName' in the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName' from '$StartTime'" -ForegroundColor Green
    }
} catch {
    if ($WorkflowName -eq "") {
        if ($EndTime) {
            Write-Warning "Failed to resubmit all failed instances for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName' from '$StartTime' and until '$EndTime'. Details: $($_.Exception.Message)"
        } else {
            Write-Warning "Failed to resubmit all failed instances for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName' from '$StartTime'. Details: $($_.Exception.Message)"
        }
    } else {
        Write-Warning "Failed to resubmit all failed instances for the workflow '$WorkflowName' in Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName' from '$StartTime'. Details: $($_.Exception.Message)"
    }
    $ErrorMessage = $_.Exception.Message
    Write-Debug "Error: $ErrorMessage"
}