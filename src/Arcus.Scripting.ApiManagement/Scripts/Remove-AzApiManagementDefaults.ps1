param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName,
    [Parameter(Mandatory = $true)][string] $ServiceName
)

Write-Host "Start removing Azure API Management defaults..."
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName 

Write-Host "Removing Echo Api..."
$apiResult = Remove-AzApiManagementApi -Context $apimContext -ApiId 'echo-api'

Write-Host "Removing Starter product..."
$starterResult = Remove-AzApiManagementProduct -Context $apimContext -ProductId 'starter' -DeleteSubscriptions

Write-Host "Removing Unlimited product..."
$unlimitedResult = Remove-AzApiManagementProduct -Context $apimContext -ProductId 'unlimited' -DeleteSubscriptions

if ($apiResult -and $starterResult -and $unlimitedResult) {
    Write-Host "Successfully removed the 'echo-api' API, 'starter' Product and 'unlimited' Product"
} else {
    $message = "Failed to remove API Management defaults"
    if (-not $apiResult) {
        $message += [System.Environment]::NewLine + "> Failed to remove the 'echo' API"
    }
    if (-not $starterResult) {
        $message += [System.Environment]::NewLine + "> Failed to remove the 'starter' Product"
    }
    if (-not $unlimitedResult) {
        $message += [System.Environment]::NewLine + "> Failed to remove the 'unlimited' Product"
    }

    Write-Error $message
}

Write-Host "Finished removing Azure API Management defaults!"
