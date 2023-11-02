param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
    [Parameter(Mandatory = $true)][string] $DeployFileName = $(throw "Name of deployment file is required"),
    [Parameter(Mandatory = $false)][string] $ResourcePrefix = "",
    [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud",
    [Parameter(Mandatory = $false)][string] $ApiVersion = "2016-06-01"
)

$Global:accessToken = "";
$Global:subscriptionId = "";

function ExecuteStopType() {
    [CmdletBinding()]
    param
    (
        [string][parameter(Mandatory = $true)]$ResourceGroupName,
        [string][parameter(Mandatory = $false)]$LogicAppType,
        [string][parameter(Mandatory = $true)]$LogicAppName,
        [string][parameter(Mandatory = $false)]$WorkflowName,
        [string][parameter(Mandatory = $true)]$stopType
    )
    BEGIN {
        Write-Verbose "Executing stopType '$($stopType)' for Logic App $($LogicAppType) '$($LogicAppName)' in resource group '$ResourceGroupName'"
        if ($stopType -Match "Immediate") {
            try {
                Disable-AzLogicApp -EnvironmentName $EnvironmentName -SubscriptionId $Global:subscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -WorkflowName $WorkflowName -ApiVersion $ApiVersion -AccessToken $Global:accessToken
            } catch {
                if ($LogicAppType -match "Standard") {
                    Write-Warning "Failed to disable workflow '$WorkflowName' in Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'"
                } else {
                    Write-Warning "Failed to disable Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'"
                }
                $ErrorMessage = $_.Exception.Message
                Write-Debug "Error: $ErrorMessage"
            }                    
        }
        elseIf ($stopType -Match "None") {
            Write-Host "Executing Stop 'None' => performing no stop"
        }
        else {
            Write-Warning "StopType '$stopType' has no known implementation, doing nothing.." 
        }        
    }
}

function ExecuteCheckType() {
    [CmdletBinding()]
    param
    (
        [string][parameter(Mandatory = $true)]$ResourceGroupName,
        [System.Array][parameter(Mandatory = $true)]$batch
    )
    BEGIN {
        Write-Verbose "Executing CheckType '$($batch.checkType)' for batch '$($batch.description)' in resource group '$ResourceGroupName'..."
        $maximumFollowNextPageLink = $batch.maximumFollowNextPageLink
        if (!$maximumFollowNextPageLink) {
            $maximumFollowNextPageLink = 10
        }
        if ($batch.checkType -Match "NoWaitingOrRunningRuns") {
            Write-Host "Executing Check 'NoWaitingOrRunningRuns'"
            if ($batch.logicAppType -match "Standard") {
                if ($batch.logicApps.Length -gt 0 ) {
                    $batch.logicApps | ForEach-Object {
                        $LogicAppName = $_.name;

                        if ($_.workflows.Length -gt 0 ) {
                            $_.workflows | ForEach-Object {
                                $WorkflowName = $_;
                                $fullUrl = . $PSScriptRoot\Get-AzLogicAppStandardResourceManagementUrl.ps1 -EnvironmentName $EnvironmentName -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -WorkflowName $WorkflowName
                                $params = @{
                                    Method = 'Get'
                                    Headers = @{ 
                                        'authorization'="Bearer $Global:accessToken"
                                    }
                                    URI = $fullUrl
                                }

                                $runHistory = Invoke-WebRequest @params -ErrorAction Stop
                                $runHistoryContent = $runHistory.Content | ConvertFrom-Json
                                $runningRunsCount = ($runHistoryContent.value | Where-Object { $_.properties.status -eq "Running" }).Count
                                $waitingRunsCount = ($runHistoryContent.value | Where-Object { $_.properties.status -eq "Waiting" }).Count

                                if ($runningRunsCount -ne 0 -or $waitingRunsCount -ne 0) {
                                    while ($runningRunsCount -ne 0 -or $waitingRunsCount -ne 0) {
                                        Write-Verbose "Workflow '$WorkflowName' in Azure Logic App '$LogicAppName' has Running and/or Waiting Runs, waiting 10 seconds and checking again..."
                                        Write-Debug "Number of running runs: $runningRunsCount"
                                        Write-Debug "Number of waiting runs: $waitingRunsCount"
                                        Start-Sleep -Second 10
                                        $runHistory = Invoke-WebRequest @params -ErrorAction Stop
                                        $runHistoryContent = $runHistory.Content | ConvertFrom-Json
                                        $runningRunsCount = ($runHistoryContent.value | Where-Object { $_.properties.status -eq "Running" }).Count
                                        $waitingRunsCount = ($runHistoryContent.value | Where-Object { $_.properties.status -eq "Waiting" }).Count

                                        if ($runningRunsCount -eq 0 -and $waitingRunsCount -eq 0) {
                                            Write-Verbose "Found no more waiting or running runs for Workflow '$WorkflowName' in Azure Logic App '$LogicAppName', executing stopType for Logic App Workflow"
                                            ExecuteStopType -resourceGroupName $ResourceGroupName -LogicAppType $batch.logicAppType -LogicAppName $LogicAppName -WorkflowName $WorkflowName -stopType $batch.stopType
                                        }
                                    }
                                } else {
                                    Write-Verbose "Found no more waiting or running runs for Workflow '$WorkflowName' in Azure Logic App '$LogicAppName', executing stopType for Logic App Workflow"
                                    ExecuteStopType -resourceGroupName $ResourceGroupName -LogicAppType $batch.logicAppType -LogicAppName $LogicAppName -WorkflowName $WorkflowName -stopType $batch.stopType
                                }                    
                                Write-Host "Check 'NoWaitingOrRunningRuns' executed successfully onWorkflow '$WorkflowName' in Azure Logic App '$LogicAppName'" -ForegroundColor Green
                            }
                        } else {
                            Write-Warning "No workflows specified to disable"
                        }                        
                    }
                } else {
                    Write-Warning "No Azure Logic Apps specified to disable"
                }
            } else {
                if ($batch.logicApps.Length -gt 0 ) {
                    $batch.logicApps | ForEach-Object {
                        $logicApp = $_;
                        if ($ResourcePrefix.Length -gt 0){
                            $logicApp = "$ResourcePrefix$_"
                        }

                        try {
                            $runHistory = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $logicApp -FollowNextPageLink -MaximumFollowNextPageLink $maximumFollowNextPageLink -ErrorAction Stop
                            $runningRunsCount = ($runHistory | Where-Object { $_.Status -eq "Running" }).Count
                            $waitingRunsCount = ($runHistory | Where-Object { $_.Status -eq "Waiting" }).Count

                            if ($runningRunsCount -ne 0 -or $waitingRunsCount -ne 0) {
                                while ($runningRunsCount -ne 0 -or $waitingRunsCount -ne 0) {
                                    Write-Verbose "Azure Logic App '$logicApp' has Running and/or Waiting Runs, waiting 10 seconds and checking again..."
                                    Write-Debug "Number of running runs: $runningRunsCount"
                                    Write-Debug "Number of waiting runs: $waitingRunsCount"
                                    Start-Sleep -Second 10
                                    $runHistory = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $logicApp -FollowNextPageLink -MaximumFollowNextPageLink $maximumFollowNextPageLink -ErrorAction Stop
                                    $runningRunsCount = ($runHistory | Where-Object { $_.Status -eq "Running" }).Count
                                    $waitingRunsCount = ($runHistory | Where-Object { $_.Status -eq "Waiting" }).Count
                                    if ($runningRunsCount -eq 0 -and $waitingRunsCount -eq 0) {
                                        Write-Verbose "Found no more waiting or running runs for Azure Logic App '$logicApp', executing stopType for Logic App"
                                        ExecuteStopType -resourceGroupName $ResourceGroupName -LogicAppType $batch.logicAppType -LogicAppName $logicApp -stopType $batch.stopType
                                    }
                                }
                            } else {
                                Write-Verbose "Found no more waiting or running runs for Azure Logic App '$logicApp', executing stopType for Logic App"
                                ExecuteStopType -resourceGroupName $ResourceGroupName -LogicAppType $batch.logicAppType -LogicAppName $logicApp -stopType $batch.stopType
                            }                    
                            Write-Host "Check 'NoWaitingOrRunningRuns' executed successfully on Azure Logic App '$logicApp'" -ForegroundColor Green
                        } catch {
                            Write-Warning "Failed to perform check 'NoWaitingOrRunningRuns' for Azure Logic App '$logicApp'"
                            $ErrorMessage = $_.Exception.Message
                            Write-Debug "Error: $ErrorMessage"
                        }
                    }
                } else {
                    Write-Warning "No Azure Logic Apps specified to disable"
                }
            }
        } elseIf ($batch.checkType -Match "None") {
            Write-Host "Executing Check 'None' => performing no check and executing stopType"
            if ($batch.logicAppType -match "Standard") {
                if ($batch.logicApps.Length -gt 0 ) {
                    $batch.logicApps | ForEach-Object {
                        $LogicAppName = $_.name;
                        
                        $_.workflows | ForEach-Object {
                            $WorkflowName = $_;

                            ExecuteStopType -resourceGroupName $ResourceGroupName -LogicAppType $batch.logicAppType -LogicAppName $LogicAppName -WorkflowName $WorkflowName -stopType $batch.stopType
                        }
                    }
                }
            } else {
                $batch.logicApps | ForEach-Object {
                    $LogicAppName = $_;
                    if($ResourcePrefix.Length -gt 0){
                        $LogicAppName = "$ResourcePrefix$_"
                    }
                    ExecuteStopType -resourceGroupName $ResourceGroupName -LogicAppType $batch.logicAppType -LogicAppName $LogicAppName -stopType $batch.stopType
                }
            }            
        } else {
            Write-Warning "CheckType '$batch.checkType' has no known implementation, performing no check or stop on the Azure Logic App '$logicApp' in resource group '$ResourceGroupName'..." 
        }
    }
}

$json = Get-Content $DeployFileName | Out-String | ConvertFrom-Json

if ($json -is [array]) {
    [array]::Reverse($json)
}

if($json.Length -gt 0){
    # Request accessToken in case the script contains records
    $token = Get-AzCachedAccessToken -AssignGlobalVariables
}

$json | ForEach-Object { 
    $batch = $_;    
    $batchDescription = $batch.description
    Write-Verbose "Executing batch: '$batchDescription'"
    #Call the ExecuteCheckType function which will call the ExecuteStopType function after a check for a Logic App has completed
    ExecuteCheckType -resourceGroupName $ResourceGroupName -batch $batch

    Write-Host "Batch: '$batchDescription' has been executed" -ForegroundColor Green
}
