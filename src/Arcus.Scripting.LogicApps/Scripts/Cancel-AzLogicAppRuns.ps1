param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of the resource group is required"),
    [Parameter(Mandatory = $true)][string] $LogicAppName = $(throw "Name of the logic app is required"),
    [Parameter(Mandatory = $false)][int] $MaximumFollowNextPageLink = 10
)

try {
    $runs = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $LogicAppName -FollowNextPageLink -MaximumFollowNextPageLink $MaximumFollowNextPageLink | 
        Where-Object {$_.Status -eq 'Running'}

    foreach ($run in $runs) {
        Stop-AzLogicAppRun -ResourceGroupName $ResourceGroupName -Name $LogicAppName -RunName $run.Name -Force
        Write-Verbose "Cancelled run $run.Name for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'"
    }

    Write-Host "Successfully cancelled all running instances for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'" -ForegroundColor Green
} catch {
    throw "Failed to cancel all running instances for the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'. Details: $($_.Exception.Message)"
}