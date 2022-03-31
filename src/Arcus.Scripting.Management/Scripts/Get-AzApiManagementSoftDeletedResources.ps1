Param(
    [Parameter(Mandatory = $true)][string] $Name,
    [Parameter(Mandatory = $true)][string] $SubscriptionId,
    [Parameter(Mandatory = $true)][string] $ResourceManagerUrl,
    [Parameter(Mandatory = $true)][object] $AuthHeader,
    [Parameter(Mandatory = $true)][string] $ApiVersion
)

Write-Verbose "Checking if the API Management instance with name '$Name' is listed as a soft deleted service"
$getUri = "$ResourceManagerUrl" + "subscriptions/$SubscriptionId/providers/Microsoft.ApiManagement/deletedservices" + "?api-version=$ApiVersion"

$deletedServices = (Invoke-RestMethod -Method GET -Uri $getUri -Headers $AuthHeader)

if ($deletedServices.value.count -eq 0 -or ($deletedServices.value | Where-Object name -eq $Name).count -eq 0) {
    throw "API Management instance with name '$Name' is not listed as a soft deleted service and therefore it cannot be removed or restored"
}

Write-Host "API Management instance has been found for name '$Name' as a soft deleted service"

return $deletedServices