param(
    [Parameter(Mandatory = $true)][string] $ResourceGroup,
    [Parameter(Mandatory = $true)][string] $ServiceName,
    [Parameter(Mandatory = $true)][string] $ApiId,
    [Parameter(Mandatory = $false)][string] $ApiKeyHeaderName = "x-api-key",
    [Parameter(Mandatory = $false)][string] $ApiQueryParamName = "apiKey"
)

$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroup -ServiceName $ServiceName
Write-Host "Using API Management instance '$ServiceName' in resource group '$ResourceGroup'"

Set-AzApiManagementApi -Context $apimContext -ApiId $ApiId -Protocols "https" -SubscriptionKeyHeaderName $ApiKeyHeaderName -SubscriptionKeyQueryParamName $ApiQueryParamName
Write-Host "Subscription key header '$ApiKeyHeaderName' was assigned"
Write-Host "Subscription key query parameter '$ApiQueryParamName' was assigned"