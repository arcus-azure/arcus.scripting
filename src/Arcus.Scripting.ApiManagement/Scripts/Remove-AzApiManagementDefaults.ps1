param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName,
    [Parameter(Mandatory = $true)][string] $ServiceName
)

Write-Host "Start removing Azure API Management defaults..."
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName 

Write-Host "Checking if 'echo' API exists..."
$Global:Error.clear()
try {
    $apiGetResult = Get-AzApiManagementApi -Context $apimContext -ApiId 'echo-api' -ErrorAction Stop
}
catch {
    Write-Host "The 'echo' API does not exist, skipping removal..."
}
if (!$Global:Error) {
    try {
        Write-Host "Removing 'echo' API..."
        $apiRemoveResult = Remove-AzApiManagementApi -Context $apimContext -ApiId 'echo-api' -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to remove the 'echo' API"
        throw
    }
}

Write-Host "Checking if 'starter' product exists..."
$Global:Error.clear()
try {
    $starterGetResult = Get-AzApiManagementProduct -Context $apimContext -ProductId 'starter' -ErrorAction Stop
}
catch {
    Write-Host "The 'starter' product does not exist, skipping removal..."
}
if (!$Global:Error) { 
    try {
        Write-Host "Removing 'starter' product..."
        $starterRemoveResult = Remove-AzApiManagementProduct -Context $apimContext -ProductId 'starter' -DeleteSubscriptions -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to remove the 'starter' product"
        throw
    }
}

Write-Host "Checking if 'unlimited' product exists..."
$Global:Error.clear()
try {
    $unlimitedGetResult = Get-AzApiManagementProduct -Context $apimContext -ProductId 'unlimited' -ErrorAction Stop
}
catch {
    Write-Host "The 'unlimited' product does not exist, skipping removal..."
}
if (!$Global:Error) { 
    try {
        Write-Host "Removing 'unlimited' product..."
        $unlimitedRemoveResult = Remove-AzApiManagementProduct -Context $apimContext -ProductId 'unlimited' -DeleteSubscriptions -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to remove the 'unlimited' product"
        throw
    }
}

Write-Host "Finished removing Azure API Management defaults!"
