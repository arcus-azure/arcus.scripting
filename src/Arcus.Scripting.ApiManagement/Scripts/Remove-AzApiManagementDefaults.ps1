param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName,
    [Parameter(Mandatory = $true)][string] $ServiceName
)

Write-Verbose "Start removing Azure API Management instance '$ServiceName' defaults in resource group '$ResourceGroupName'..."
$apim = Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName
if ($null -eq $apim) {
    throw "Unable to find the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
}
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName
$exceptionOccurred = $false
$failedActions = @()

Write-Verbose "Checking if 'echo' API exists in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'..."
$echoExists = $true
try {
    Get-AzApiManagementApi -Context $apimContext -ApiId 'echo-api' -ErrorAction Stop | Out-Null
} catch {
    if ($_.Exception.Response.StatusCode -eq 'NotFound' -or $_.TargetObject.Response.StatusCode -eq 'NotFound') {
        $echoExists = $false
        Write-Verbose "The 'echo' API does not exist in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName', skipping removal..."
    } else {
        Write-Error $_
        $exceptionOccurred = $true
        $failedActions += "getting the 'echo-api'"
    }
}
if ($echoExists) {
    try {
        Write-Verbose "Removing 'echo' API in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'..."
        Remove-AzApiManagementApi -Context $apimContext -ApiId 'echo-api' -ErrorAction Stop | Out-Null
        Write-Host "Removed 'echo' API in the Azure API Management instance $ServiceName in resource group $ResourceGroupName" -ForegroundColor Green
    } catch {
        Write-Error "Failed to remove the 'echo' API in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
        $exceptionOccurred = $true
        $failedActions += "removing the 'echo-api'"
    }
}

Write-Verbose "Checking if 'starter' product exists in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'..."
$starterExists = $true
try {
    Get-AzApiManagementProduct -Context $apimContext -ProductId 'starter' -ErrorAction Stop | Out-Null
} catch {
    if ($_.Exception.Response.StatusCode -eq 'NotFound' -or $_.TargetObject.Response.StatusCode -eq 'NotFound') {
        $starterExists = $false
        Write-Verbose "The 'starter' product does not exist in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName', skipping removal..."
    } else {
        Write-Error $_
        $exceptionOccurred = $true
        $failedActions += "getting the 'starter' product"
    }
}
if ($starterExists) { 
    try {
        Write-Verbose "Removing 'starter' product in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'..."
        Remove-AzApiManagementProduct -Context $apimContext -ProductId 'starter' -DeleteSubscriptions -ErrorAction Stop | Out-Null
        Write-Host "Removed 'starter' product in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'" -ForegroundColor Green
    } catch {
        Write-Error "Failed to remove the 'starter' product in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
        $exceptionOccurred = $true
        $failedActions += "removing the 'starter' product"
    }
}

Write-Verbose "Checking if 'unlimited' product exists in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'..."
$unlimitedExists = $true
try {
    Get-AzApiManagementProduct -Context $apimContext -ProductId 'unlimited' -ErrorAction Stop | Out-Null
} catch {
    if ($_.Exception.Response.StatusCode -eq 'NotFound' -or $_.TargetObject.Response.StatusCode -eq 'NotFound') {
        $unlimitedExists = $false
        Write-Verbose "The 'unlimited' product does not exist in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName', skipping removal..."
    } else {
        Write-Error $_
        $exceptionOccurred = $true
        $failedActions += "getting the 'unlimited' product"
    }
}
if ($unlimitedExists) { 
    try {
        Write-Verbose "Removing 'unlimited' product in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'..."
        Remove-AzApiManagementProduct -Context $apimContext -ProductId 'unlimited' -DeleteSubscriptions -ErrorAction Stop | Out-Null
        Write-Host "Removed 'unlimited' product in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'" -ForegroundColor Green
    } catch {
        Write-Error "Failed to remove the 'unlimited' product"
        $exceptionOccurred = $true
        $failedActions += "removing the 'unlimited' product"
    }
}

if ($exceptionOccurred) {
    $failedActionsString = $failedActions -join ", "
    throw "These action(s) failed: $failedActionsString for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
}

Write-Host "Finished removing Azure API Management defaults in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'!" -ForegroundColor Green