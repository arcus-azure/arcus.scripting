param(
    [Parameter(Mandatory = $true)][string] $Name,
    [Parameter(Mandatory = $true)][string] $SubscriptionId,
    [Parameter(Mandatory = $true)][string] $ResourceManagerUrl,
    [Parameter(Mandatory = $true)][object] $AuthHeader,
    [Parameter(Mandatory = $true)][string] $ApiVersion
)

Write-Verbose "Checking if the Azure API Management service '$Name' is listed as a soft deleted service..."
$getUri = "$ResourceManagerUrl" + "subscriptions/$SubscriptionId/providers/Microsoft.ApiManagement/deletedservices" + "?api-version=$ApiVersion"
Write-Host "Get soft deleted services at: $getUri $AuthHeader"

$deletedServices = (Invoke-RestMethod -Method GET -Uri $getUri -Headers $AuthHeader)

if ($deletedServices.value.count -eq 0 -or ($deletedServices.value | Where-Object name -eq $Name).count -eq 0) {
    throw "Azure API Management service '$Name' is not listed as a soft deleted service and therefore it cannot be removed or restored"
}

Write-Host "Found Azure API Management service '$Name' as a soft deleted service" -ForegroundColor Green

return $deletedServices