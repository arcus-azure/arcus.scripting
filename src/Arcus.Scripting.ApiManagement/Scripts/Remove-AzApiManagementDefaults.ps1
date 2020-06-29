param(
    [string][parameter(Mandatory = $true)] $ResourceGroup,
    [string][parameter(Mandatory = $true)] $ServiceName
)

Write-Host "Start removing API Management defaults..."
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroup -ServiceName $ServiceName 

Write-Host "Removing Echo Api..."
$apiResult = Remove-AzApiManagementApi -Context $apimContext -ApiId 'echo-api'
if ($apiResult) {
    Write-Host "Successfully removed the 'echo-api' API"
} else {
    Write-Error "Failed to remove the 'echo-api' API"
}

Write-Host "Removing Starter product..."
$starterResult = Remove-AzApiManagementProduct -Context $apimContext -ProductId 'starter' -DeleteSubscriptions
if ($starterResult) {
    Write-Host "Successfully removed the 'starter' product"
} else {
    Write-Error "Failed to remove the 'starter' product"
}

Write-Host "Removing Unlimited product..."
$unlimitedResult = Remove-AzApiManagementProduct -Context $apimContext -ProductId 'unlimited' -DeleteSubscriptions
if ($unlimitedResult) {
    Write-Host "Successfully removed 'unlimited' product"
} else {
    Write-Error "Failed to remove the 'unlimited' product"
}

Write-Host "Done removing API Management defaults!"