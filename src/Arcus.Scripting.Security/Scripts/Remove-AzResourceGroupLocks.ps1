param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
    [Parameter(Mandatory = $false)][string] $LockName = $null
)

if ($LockName) {
    Write-Host "Retrieving all locks in resourceGroup '$ResourceGroupName' with name '$LockName'"
} else {
    Write-Host "Retrieving all locks in resourceGroup '$ResourceGroupName'"
}

$locks = Get-AzResourceLock -ResourceGroupName $ResourceGroupName

if ($null -ne $locks) {
    Write-Host "Start removing all locks '$($locks.Name)' in resourceGroup '$ResourceGroupName'"
    foreach ($lock in $locks) {
        $lockId = $lock.LockId
        if ([string]::IsNullOrWhiteSpace($LockName) -or $LockName -eq $lock.Name) {
            Write-Host "Removing the lock: $($lock.Name)"
            Remove-AzResourceLock -LockId $lockId -Force
        }
    }

    Write-Host "All locks in resourceGroup '$ResourceGroupName' have been removed"
} else {
    Write-Host "No locks to remove."
}