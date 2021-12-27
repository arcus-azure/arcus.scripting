param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName,
    [Parameter(Mandatory = $true)][string] $ServiceName
)

Write-Host "Start removing Azure API Management defaults..."
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName 
$exceptionOccurred = $false
$failedActions = @()

Write-Host "Checking if 'echo' API exists..."
$echoExists = $true
try {
    Get-AzApiManagementApi -Context $apimContext -ApiId 'echo-api' -ErrorAction Stop | Out-Null
}
catch {
    If ($_.Exception.Response.StatusCode -eq 'NotFound' -or $_.TargetObject.Response.StatusCode -eq 'NotFound') {
        $echoExists = $false
        Write-Host "The 'echo' API does not exist, skipping removal..."
    }
    Else {
        Write-Error $_
        $exceptionOccurred = $true
        $failedActions += "getting the 'echo-api'"
    }
}
if ($echoExists) {
    try {
        Write-Host "Removing 'echo' API..."
        Remove-AzApiManagementApi -Context $apimContext -ApiId 'echo-api' -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Error "Failed to remove the 'echo' API"
        $exceptionOccurred = $true
        $failedActions += "removing the 'echo-api'"
    }
}

Write-Host "Checking if 'starter' product exists..."
$starterExists = $true
try {
    Get-AzApiManagementProduct -Context $apimContext -ProductId 'starter' -ErrorAction Stop | Out-Null
}
catch {
    If ($_.Exception.Response.StatusCode -eq 'NotFound' -or $_.TargetObject.Response.StatusCode -eq 'NotFound') {
        $starterExists = $false
        Write-Host "The 'starter' product does not exist, skipping removal..."
    }
    Else {
        Write-Error $_
        $exceptionOccurred = $true
        $failedActions += "getting the 'starter' product"
    }
}
if ($starterExists) { 
    try {
        Write-Host "Removing 'starter' product..."
        Remove-AzApiManagementProduct -Context $apimContext -ProductId 'starter' -DeleteSubscriptions -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Error "Failed to remove the 'starter' product"
        $exceptionOccurred = $true
        $failedActions += "removing the 'starter' product"
    }
}

Write-Host "Checking if 'unlimited' product exists..."
$unlimitedExists = $true
try {
    Get-AzApiManagementProduct -Context $apimContext -ProductId 'unlimited' -ErrorAction Stop | Out-Null
}
catch {
    If ($_.Exception.Response.StatusCode -eq 'NotFound' -or $_.TargetObject.Response.StatusCode -eq 'NotFound') {
        $unlimitedExists = $false
    Write-Host "The 'unlimited' product does not exist, skipping removal..."
    }
    Else {
        Write-Error $_
        $exceptionOccurred = $true
        $failedActions += "getting the 'unlimited' product"
    }
}
if ($unlimitedExists) { 
    try {
        Write-Host "Removing 'unlimited' product..."
        Remove-AzApiManagementProduct -Context $apimContext -ProductId 'unlimited' -DeleteSubscriptions -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Error "Failed to remove the 'unlimited' product"
        $exceptionOccurred = $true
        $failedActions += "removing the 'unlimited' product"
    }
}

if ($exceptionOccurred)
{
    $failedActionsString = $failedActions -join ", "
    throw "These action(s) failed: $failedActionsString"
}

Write-Host "Finished removing Azure API Management defaults!"