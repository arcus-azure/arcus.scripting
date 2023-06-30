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
        [string][parameter(Mandatory = $true)]$LogicAppName,
        [string][parameter(Mandatory = $true)]$stopType
    )
    BEGIN {
        Write-Verbose "Executing StopType '$stopType' for Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'..."
        If ($stopType -Match "Immediate") {
            try {
                Disable-AzLogicApp -EnvironmentName $EnvironmentName -SubscriptionId $Global:subscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -ApiVersion $ApiVersion -AccessToken $Global:accessToken
            }
            catch {
                Write-Warning "Failed to disable Azure Logic App '$LogicAppName'"
                $ErrorMessage = $_.Exception.Message
                Write-Debug "Error: $ErrorMessage"
            }            
        }
        ElseIf ($stopType -Match "None") {
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
        if ($batch.checkType -Match "NoWaitingOrRunningRuns") {
            Write-Host "Executing Check 'NoWaitingOrRunningRuns'"
            if ($batch.logicApps.Length -gt 0 ) {
                $batch.logicApps | ForEach-Object {
                    $logicApp = $_;
                    if($ResourcePrefix.Length -gt 0){
                        $logicApp = "$ResourcePrefix$_"
                    }

                    try {
                        $runHistory = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $logicApp -FollowNextPageLink -ErrorAction Stop
                        $RunningRunsCount = ($runHistory | Where-Object { $_.Status -eq "Running" }).Count
                        $WaitingRunsCount = ($runHistory | Where-Object { $_.Status -eq "Waiting" }).Count
                        if ($RunningRunsCount -ne 0 -and $WaitingRunsCount -ne 0) {
                            while ($RunningRunsCount -ne 0 -and $WaitingRunsCount -ne 0) {
                                Write-Verbose "Azure Logic App '$logicApp' has Running and/or Waiting Runs, waiting 10 seconds and checking again..."
                                Write-Debug "Number of running runs: $RunningRunsCount"
                                Write-Debug "Number of waiting runs: $WaitingRunsCount"
                                Start-Sleep -Second 10                               
                                $RunningRunsCount = ($runHistory | Where-Object { $_.Status -eq "Running" }).Count
                                $WaitingRunsCount = ($runHistory | Where-Object { $_.Status -eq "Waiting" }).Count
                                if ($RunningRunsCount -eq 0 -and $WaitingRunsCount -eq 0) {
                                    Write-Verbose "Found no more waiting or running runs for Azure Logic App '$logicApp', executing stopType for Logic App"
                                    ExecuteStopType -resourceGroupName $ResourceGroupName -LogicAppName $logicApp -stopType $batch.stopType
                                }
                            }
                        } else{
                            Write-Verbose "Found no more waiting or running runs for Azure Logic App '$logicApp', executing stopType for Logic App"
                            ExecuteStopType -resourceGroupName $ResourceGroupName -LogicAppName $logicApp -stopType $batch.stopType
                        }                    
                        Write-Host "Check 'NoWaitingOrRunningRuns' executed successfully on Azure Logic App '$logicApp'" -ForegroundColor Green
                    }
                    catch {
                        Write-Warning "Failed to perform check 'NoWaitingOrRunningRuns' for Azure Logic App '$logicApp'"
                        $ErrorMessage = $_.Exception.Message
                        Write-Debug "Error: $ErrorMessage"
                    }
                }
            }
            else {
                Write-Warning "No Azure Logic Apps specified to disable"
            }
        }
        elseIf ($batch.checkType -Match "None") {
            Write-Host "Executing Check 'None' => peforming no check and executing stopType"
            $batch.logicApps | ForEach-Object {
                $logicApp = $_;
                if($ResourcePrefix.Length -gt 0){
                    $logicApp = "$ResourcePrefix$_"
                }
                ExecuteStopType -resourceGroupName $ResourceGroupName -LogicAppName $logicApp -stopType $batch.stopType
            }
        }
        else {
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
