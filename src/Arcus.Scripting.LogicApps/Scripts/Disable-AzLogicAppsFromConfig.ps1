param(
    [string][Parameter(Mandatory = $true)]$ResourceGroupName,
    [string][Parameter(Mandatory = $true)]$DeployFileName,
    [string][Parameter(Mandatory = $false)]$ResourcePrefix = ""
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
        Write-Host("> Executing StopType '$stopType' for Logic App '$LogicAppName' in resource group '$ResourceGroupName'")
        If ($stopType -Match "Immediate") {
            try {
                Disable-AzLogicApp -SubscriptionId $Global:subscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -AccessToken $Global:accessToken
            }
            catch {
                Write-Warning "Failed to disable $LogicAppName"
                $ErrorMessage = $_.Exception.Message
                Write-Warning "Error: $ErrorMessage"
            }            
        }
        ElseIf ($stopType -Match "None") {
            Write-Host "Executing Stop 'None' => peforming no stop"
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
        Write-Host("> Executing CheckType '$($batch.checkType)' for batch '$($batch.description)' in resource group '$ResourceGroupName'")
        If ($batch.checkType -Match "NoWaitingOrRunningRuns") {
            Write-Host "Executing Check 'NoWaitingOrRunningRuns'"
            If ($batch.logicApps.Length -gt 0 ) {
                $batch.logicApps | ForEach-Object {
                    $logicApp = $_;
                    if($ResourcePrefix.Length -gt 0){
                        $logicApp = "$ResourcePrefix$_"
                    }

                    try {
                        $RunningRunsCount = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $logicApp -ErrorAction Stop | Where-Object Status -eq "Running" | Measure-Object | ForEach-Object { $_.Count }
                        $WaitingRunsCount = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $logicApp -ErrorAction Stop | Where-Object Status -eq "Waiting" | Measure-Object | ForEach-Object { $_.Count }
                        if ($RunningRunsCount -ne 0 -and $WaitingRunsCount -ne 0) {
                            while ($RunningRunsCount -ne 0 -and $WaitingRunsCount -ne 0) {
                                Write-Host "Logic App '$logicApp' has Running and/or Waiting Runs, waiting 10 seconds and checking again.."
                                Write-Host "Number of running runs: $RunningRunsCount"
                                Write-Host "Number of waiting runs: $WaitingRunsCount"
                                Start-Sleep -Second 10                               
                                $RunningRunsCount = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $logicApp -ErrorAction Stop | Where-Object Status -eq "Running" | Measure-Object | ForEach-Object { $_.Count }
                                $WaitingRunsCount = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $logicApp -ErrorAction Stop | Where-Object Status -eq "Waiting" | Measure-Object | ForEach-Object { $_.Count }
                                if ($RunningRunsCount -eq 0 -and $WaitingRunsCount -eq 0) {
                                    Write-Host("Found no more waiting or running runs for '$logicApp', executing stopType for Logic App")
                                    ExecuteStopType -resourceGroupName $ResourceGroupName -LogicAppName $logicApp -stopType $batch.stopType
                                }
                            }
                        }else{
                            Write-Host("Found no more waiting or running runs for '$logicApp', executing stopType for Logic App")
                            ExecuteStopType -resourceGroupName $ResourceGroupName -LogicAppName $logicApp -stopType $batch.stopType
                        }                    
                        Write-Host("> Check 'NoWaitingOrRunningRuns' executed successfully on '$logicApp'")   
                    }
                    catch {
                        Write-Warning "Failed to perform check 'NoWaitingOrRunningRuns' for $logicApp"
                        $ErrorMessage = $_.Exception.Message
                        Write-Warning "Error: $ErrorMessage"
                    }                         
                }
            }
            else {
                Write-Warning "No Logic Apps specified."
            }
        }
        ElseIf ($batch.checkType -Match "None") {
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
            Write-Warning "CheckType '$batch.checkType' has no known implementation, performing no check or stop on the Logic App.." 
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
    Write-Host("Executing batch: '$batchDescription'")
    Write-Host("====================================")
    #Call the ExecuteCheckType function which will call the ExecuteStopType function after a check for a Logic App has completed
    ExecuteCheckType -resourceGroupName $ResourceGroupName -batch $batch

    ## Wrap up
    Write-Host("-> Batch: '$batchDescription' has been executed")
    Write-Host("")
}