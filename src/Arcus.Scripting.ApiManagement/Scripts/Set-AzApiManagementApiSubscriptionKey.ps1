param(
    [Parameter(Mandatory = $true)][string] $ResourceGroup,
    [Parameter(Mandatory = $true)][string] $ServiceName,
    [Parameter(Mandatory = $true)][string] $ApiId,
    [Parameter(Mandatory = $false)][string] $KeyHeaderName = "x-api-key",
    [Parameter(Mandatory = $false)][string] $QueryParamName = "apiKey"
)

$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroup -ServiceName $ServiceName
Write-Host "Using API Management instance '$ServiceName' in resource group '$ResourceGroup'"

Set-AzApiManagementApi -Context $apimContext -ApiId $ApiId -SubscriptionKeyHeaderName $KeyHeaderName -SubscriptionKeyQueryParamName $QueryParamName
Write-Host "Subscription key header '$KeyHeaderName' was assigned"
Write-Host "Subscription key query parameter '$QueryParamName' was assigned"