param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName,
    [Parameter(Mandatory = $true)][string] $ServiceName,
    [Parameter(Mandatory = $true)][string] $ApiId,
    [Parameter(Mandatory = $false)][string] $HeaderName = "x-api-key",
    [Parameter(Mandatory = $false)][string] $QueryParamName = "apiKey"
)

$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName
if ($apimContext -eq $null) {
    throw "Unable to find the Azure API Management Instance '$ServiceName' in resource group $ResourceGroupName"
}
Write-Host "Using API Management instance '$ServiceName' in resource group '$ResourceGroupName'"

Set-AzApiManagementApi -Context $apimContext -ApiId $ApiId -SubscriptionKeyHeaderName $HeaderName -SubscriptionKeyQueryParamName $QueryParamName
Write-Host "Subscription key header '$HeaderName' was assigned"
Write-Host "Subscription key query parameter '$QueryParamName' was assigned"
