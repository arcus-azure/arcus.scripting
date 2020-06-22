param(
    [string][parameter(Mandatory = $true)] $ResourceGroup,
    [string][parameter(Mandatory = $true)] $ServiceName
)

Write-Host "Start removing API Management defaults..."
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroup -ServiceName $ServiceName 

Write-Host "Removing Echo Api..."
Remove-AzApiManagementApi -Context $apimContext -ApiId 'echo-api'

Write-Host "Removing Starter product..."
Remove-AzApiManagementProduct -Context $apimContext -ProductId 'starter' -DeleteSubscriptions

Write-Host "Removing Unlimited product..."
Remove-AzApiManagementProduct -Context $apimContext -ProductId 'unlimited' -DeleteSubscriptions
Write-Host "Done removing API Management defaults!"