Param(
    [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the API Management instance is required")
)

$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
if (-not $azProfile.Accounts.Count) {
    throw "Ensure you have logged in (Connect-AzAccount) before calling this function"
}
$currentAzureContext = Get-AzContext
$subscriptionId = $currentAzureContext.Subscription.id
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azProfile)
$token = $profileClient.AcquireAccessToken($currentAzureContext.Tenant.TenantId)
$authHeader = @{
   'Authorization'='Bearer ' + $token.AccessToken
}

Write-Host "Checking if the API Management instance with name '$Name' is listed as a soft deleted service"
$getUri = 'https://management.azure.com/subscriptions/{0}/providers/Microsoft.ApiManagement/deletedservices?api-version=2021-08-01' -f $subscriptionId
$deletedServices = (Invoke-RestMethod -Method GET -Uri $getUri -Headers $authHeader)

if ($deletedServices.value.count -eq 0 -or ($deletedServices.value | Where-Object name -eq $Name).count -eq 0) {
    throw "API Management instance with name '$Name' is not listed as a soft deleted service and therefore it cannot be removed"
}

Write-Host "API Management instance has been found for name '$Name' as a soft deleted service"

Write-Host "Removing the soft deleted API Management instance '$Name'"
try {
    $serviceId = ($deletedServices.value | Where-Object name -eq $Name).id
    $deleteUri = 'https://management.azure.com{0}?api-version=2021-08-01' -f $serviceId
    $removeService = Invoke-RestMethod -Method DELETE -Uri $deleteUri -Headers $authHeader
} catch {
    throw "The soft deleted API Management instance '$Name' could not be removed. Details: $($_.Exception.Message)"
}

Write-Host "Successfully removed the soft deleted API Management instance '$Name'"