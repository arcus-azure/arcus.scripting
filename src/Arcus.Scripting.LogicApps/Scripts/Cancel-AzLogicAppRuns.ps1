param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of the resource group is required"),
    [Parameter(Mandatory = $true)][string] $LogicAppName = $(throw "Name of the logic app is required")
)

try{
    $runs = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $LogicAppName | 
        Where-Object {$_.Status -eq 'Running'} | 
        Stop-AzLogicAppRun -ResourceGroupName $ResourceGroupName -Name $LogicAppName -RunName {$_.Name} -Force

    Write-Host "Successfully cancelled all running instances of the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'" -ForegroundColor Green 
} catch {
    throw "Failed to cancel all running instances of the Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'. Details: $($_.Exception.Message)"
}