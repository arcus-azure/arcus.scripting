param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of the resource group is required"),
    [Parameter(Mandatory = $true)][string] $LogicAppName = $(throw "Name of the logic app is required"),
    [Parameter(Mandatory = $false)][string] $WorkflowName = "",
    [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud",
    [Parameter(Mandatory = $false)][int] $MaximumFollowNextPageLink = 10
)

try {
    if ($WorkflowName -eq "") {
        $runs = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $LogicAppName -FollowNextPageLink -MaximumFollowNextPageLink $MaximumFollowNextPageLink | 
        Where-Object { $_.Status -eq 'Running' }

        foreach ($run in $runs) {
            $runName = $run.name
            Stop-AzLogicAppRun -ResourceGroupName $ResourceGroupName -Name $LogicAppName -RunName $runName -Force
            Write-Verbose "Cancelled run '$runName' for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'"
        }

        Write-Host "Successfully cancelled all running instances for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'" -ForegroundColor Green
    } else {
        $token = Get-AzCachedAccessToken
        $accessToken = $token.AccessToken
        $subscriptionId = $token.SubscriptionId

        $listRunningUrl = . $PSScriptRoot\Get-AzLogicAppStandardResourceManagementUrl.ps1 -EnvironmentName $EnvironmentName -SubscriptionId $subscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -WorkflowName $WorkflowName -Action 'listRunning'
        $listRunningParams = @{
            Method  = 'Get'
            Headers = @{ 
                'authorization' = "Bearer $accessToken"
            }
            URI     = $listRunningUrl
        }

        $runs = Invoke-WebRequest @listRunningParams -ErrorAction Stop
        $runsContent = $runs.Content | ConvertFrom-Json
        $allRuns = $runsContent.value

        if ($null -ne $runsContent.nextLink) {
            $nextPageCounter = 1
            $nextPageUrl = $runsContent.nextLink
            while ($null -ne $nextPageUrl -and $nextPageCounter -le $MaximumFollowNextPageLink) {
                $nextPageCounter = $nextPageCounter + 1
                $listRunningParams = @{
                    Method  = 'Get'
                    Headers = @{ 
                        'authorization' = "Bearer $accessToken"
                    }
                    URI     = $nextPageUrl
                }

                $runsNextPage = Invoke-WebRequest @listRunningParams -ErrorAction Stop
                $runsNextPageContent = $runsNextPage.Content | ConvertFrom-Json
                $nextPageUrl = $runsNextPageContent.nextLink
                $allRuns = $allRuns + $runsNextPageContent.value
            }
        }

        foreach ($run in $allRuns) {
            $runName = $run.name

            $cancelUrl = . $PSScriptRoot\Get-AzLogicAppStandardResourceManagementUrl.ps1 -EnvironmentName $EnvironmentName -SubscriptionId $subscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -WorkflowName $WorkflowName -RunName $runName -Action 'cancel'
            $cancelParams = @{
                Method  = 'Post'
                Headers = @{ 
                    'authorization' = "Bearer $accessToken"
                }
                URI     = $cancelUrl
            }
            $cancel = Invoke-WebRequest @cancelParams -ErrorAction Stop
            Write-Verbose "Cancelled run '$runName' for the workflow '$WorkflowName' in Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'"
        }

        Write-Host "Successfully cancelled all running instances for the workflow '$WorkflowName' in Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'" -ForegroundColor Green
    }
} catch {
    if ($WorkflowName -eq "") {
        throw "Failed to cancel all running instances for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'. Details: $($_.Exception.Message)"
    } else {
        throw "Failed to cancel all running instances for the workflow '$WorkflowName' in Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'. Details: $($_.Exception.Message)"
    }
}