param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
    [Parameter(Mandatory = $true)][string] $DeployFileName = $(throw "Name of deployment file is required"),
    [Parameter(Mandatory = $false)][string] $ResourcePrefix = "",
    [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud",
    [Parameter(Mandatory = $false)][string] $ApiVersion = "2016-06-01"
)

$Global:accessToken = "";
$Global:subscriptionId = "";

function ReverseStopType() {
    [CmdletBinding()]
    param
    (
        [string][parameter(Mandatory = $true)]$ResourceGroupName,
        [System.Array][parameter(Mandatory = $true)]$batch
    )
    BEGIN {
        Write-Host("> Reverting stopType '$($batch.stopType)' for batch '$($batch.description)' in resource group '$ResourceGroupName'")
        If ($batch.stopType -Match "Immediate") {
            If ($batch.logicApps.Length -gt 0 ) {
                $batch.logicApps | ForEach-Object {
                    $LogicAppName = $_;
                    if($ResourcePrefix.Length -gt 0){
                        $LogicAppName = "$ResourcePrefix$_"
                    }
                    try {
                        Enable-AzLogicApp -EnvironmentName $EnvironmentName -SubscriptionId $Global:subscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -ApiVersion $ApiVersion -AccessToken $Global:accessToken
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

if($json.Length -gt 0){
    # Request accessToken in case the script contains records
    $token = Get-AzCachedAccessToken -AssignGlobalVariables
}

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