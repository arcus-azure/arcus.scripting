param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName,
    [Parameter(Mandatory = $true)][string] $ServiceName
)

Write-Host "Start removing Azure API Management defaults..."
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName 

Write-Host "Checking if 'echo' API exists..."
$echoExists = $true
try {
    $apiGetResult = Get-AzApiManagementApi -Context $apimContext -ApiId 'echo-api' -ErrorAction Stop
}
catch {
    $echoExists = $false
    Write-Host "The 'echo' API does not exist, skipping removal..."
}
if ($echoExists) {
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
$starterExists = $true
try {
    $starterGetResult = Get-AzApiManagementProduct -Context $apimContext -ProductId 'starter' -ErrorAction Stop
}
catch {
    $starterExists = $false
    Write-Host "The 'starter' product does not exist, skipping removal..."
}
if ($starterExists) { 
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
$unlimitedExists = $true
try {
    $unlimitedGetResult = Get-AzApiManagementProduct -Context $apimContext -ProductId 'unlimited' -ErrorAction Stop
}
catch {
    $unlimitedExists = $false
    Write-Host "The 'unlimited' product does not exist, skipping removal..."
}
if ($unlimitedExists) { 
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
