param(
    [string][Parameter(Mandatory = $true)]$ResourceGroupName,
    [string]$DeployFileName
)

function ReverseStopType() {
    [CmdletBinding()]
    param
    (
        [string][parameter(Mandatory = $true)]$resourceGroupName,
        [System.Array][parameter(Mandatory = $true)]$batch
    )
    BEGIN {
        Write-Host("> Reverting stopType '$($batch.stopType)' for batch '$($batch.description)' in resource group '$resourceGroupName'")
        If ($batch.stopType -Match "Immediate") {
            If ($batch.logicApps.Length -gt 0 ) {
                $batch.logicApps | ForEach-Object {
                    $LogicAppName = $_;
                    try {
                        Write-Host "Attempting to enable $LogicAppName"
                        Set-AzLogicApp -ResourceGroupName $resourceGroupName -Name $LogicAppName -State Enabled -Force -ErrorAction Stop
                        Write-Host "Successfully enabled $LogicAppName" 
                    }
                    catch {
                        Write-Warning "Failed to enable $LogicAppName"
                        $ErrorMessage = $_.Exception.Message 
                        Write-Warning "Error: $ErrorMessage"
                    }           
                }
            }
            else {
                Write-Warning "No Logic Apps specified."
            }
        }
        ElseIf ($batch.stopType -Match "None") {
            Write-Host "StopType equals 'None', performing no enable action on the Logic App(s)"
        }
        else {
            Write-Warning "StopType '$($batch.stopType)' has no known implementation, doing nothing.." 
        }        
    }
}

$json = Get-Content $DeployFileName | Out-String | ConvertFrom-Json
$json | ForEach-Object { 
    $batch = $_;    
    $batchDescription = $batch.description
    Write-Host("Executing batch: '$batchDescription'")
    Write-Host("====================================")
    #Call the ReverseStopType function which will revert the executed stopType
    ReverseStopType -resourceGroupName $resourceGroupName -batch $batch

    ## Wrap up
    Write-Host("-> Batch: '$batchDescription' has been executed")
    Write-Host("")
}
