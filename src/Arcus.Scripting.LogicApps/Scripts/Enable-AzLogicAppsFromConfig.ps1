param(
    [string][Parameter(Mandatory = $true)]$ResourceGroupName,
    [string][Parameter(Mandatory = $true)]$DeployFileName,
    [string][Parameter(Mandatory = $false)]$ResourcePrefix = ""
)

$Global:acces_token = "";
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
                        . $PSScriptRoot\Enable-AzLogicApp.ps1 -SubscriptionId $Global:subscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -AccessToken $Global:acces_token
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

function EnableLogicApp(){
    param
    (
        [string][parameter(Mandatory = $true)]$ResourceGroupName,
        [string][parameter(Mandatory = $true)]$LogicAppName
    )
    $params = @{
        Method = 'Post'
        Headers = @{ 
		    'authorization'="Bearer $Global:acces_token"
        }
        URI = "https://management.azure.com/subscriptions/$Global:subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows/$LogicAppName/enable?api-version=2016-06-01"
    }

    Invoke-RestMethod @params -ErrorAction Stop
}


$json = Get-Content $DeployFileName | Out-String | ConvertFrom-Json

if($json.Length -gt 0){
    # Request accessToken in case the script contains records
    $token = . $PSScriptRoot\Get-AzCachedAccessToken.ps1
    $Global:acces_token = $token.AccessToken
    $Global:subscriptionId = $token.SubscriptionId
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
