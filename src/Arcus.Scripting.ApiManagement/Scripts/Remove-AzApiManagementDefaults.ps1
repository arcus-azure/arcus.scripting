param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName,
    [Parameter(Mandatory = $true)][string] $ServiceName
)

Write-Host "Start removing Azure API Management defaults..."
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName 
$exceptionOccurredOnDelete = $false

Write-Host "Checking if 'echo' API exists..."
$echoExists = $true
try {
    Get-AzApiManagementApi -Context $apimContext -ApiId 'echo-api' -ErrorAction Stop | Out-Null
}
catch {
    $echoExists = $false
    Write-Host "The 'echo' API does not exist, skipping removal..."
}
if ($echoExists) {
    try {
        Write-Host "Removing 'echo' API..."
        Remove-AzApiManagementApi -Context $apimContext -ApiId 'echo-api' -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Error "Failed to remove the 'echo' API"
        $exceptionOccurredOnDelete = $true
    }
}

Write-Host "Checking if 'starter' product exists..."
$starterExists = $true
try {
    Get-AzApiManagementProduct -Context $apimContext -ProductId 'starter' -ErrorAction Stop | Out-Null
}
catch {
    $starterExists = $false
    Write-Host "The 'starter' product does not exist, skipping removal..."
}
if ($starterExists) { 
    try {
        Write-Host "Removing 'starter' product..."
        Remove-AzApiManagementProduct -Context $apimContext -ProductId 'starter' -DeleteSubscriptions -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Error "Failed to remove the 'starter' product"
        $exceptionOccurredOnDelete = $true
    }
}

Write-Host "Checking if 'unlimited' product exists..."
$unlimitedExists = $true
try {
    Get-AzApiManagementProduct -Context $apimContext -ProductId 'unlimited' -ErrorAction Stop | Out-Null
}
catch {
    $unlimitedExists = $false
    Write-Host "The 'unlimited' product does not exist, skipping removal..."
}
if ($unlimitedExists) { 
    try {
        Write-Host "Removing 'unlimited' product..."
        Remove-AzApiManagementProduct -Context $apimContext -ProductId 'unlimited' -DeleteSubscriptions -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Error "Failed to remove the 'unlimited' product"
        $exceptionOccurredOnDelete = $true
    }
}

if ($exceptionOccurredOnDelete)
{
    throw
}

Write-Host "Finished removing Azure API Management defaults!"
