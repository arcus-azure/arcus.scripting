param (
    [Parameter(Mandatory=$true)][string]$ResourceGroupName = $(throw "ResourceGroup is required"),
    [Parameter(Mandatory=$false)][string]$LockName = $null
)

$locks = $null

if ($LockName) {
    Write-Host "Retrieving all locks in resourceGroup '$ResourceGroupName' with name '$LockName'"
    $locks = Get-AzResourceLock -LockName $LockName -ResourceGroupName $ResourceGroupName
} else {
    Write-Host "Retrieving all locks in resourceGroup '$ResourceGroupName'"
    $locks = Get-AzResourceLock -ResourceGroupName $ResourceGroupName
}

if ($locks -ne $null -and $locks.Count -gt 0) {
    Write-Host "Start removing all locks '$locks' in resourceGroup '$ResourceGroupName'"
    foreach ($lock in $locks) {
        $lockId = $lock.LockId
        Write-Host "Removing the lock with ID:" $lockId
        Remove-AzResourceLock -LockId $lockId -Force
    }

    Write-Host "All locks in resourceGroup '$ResourceGroupName' have been removed"
} else {
    Write-Host "No locks to remove."
}