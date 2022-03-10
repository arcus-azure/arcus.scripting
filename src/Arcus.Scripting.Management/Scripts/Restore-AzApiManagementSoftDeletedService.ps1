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
    throw "API Management instance with name '$Name' is not listed as a soft deleted service and therefore it cannot be restored"
}

Write-Host "API Management instance has been found for name '$Name' as a soft deleted service"

Write-Host "Restoring the soft deleted API Management instance '$Name'"
try {
    $location = ($deletedServices.value | Where-Object name -eq $Name).location
    $serviceId = ($deletedServices.value | Where-Object name -eq $Name).properties.serviceId
    $data = @{   
        location = $location
        properties = @{
            restore = $true
        };
    };
    $body = $data | ConvertTo-Json;
    $putUri = 'https://management.azure.com{0}?api-version=2021-08-01' -f $serviceId
    $restoreService = Invoke-RestMethod -Method PUT -Uri $putUri -ContentType 'application/json' -Headers $authHeader -Body $body
} catch {
    throw "The soft deleted API Management instance '$Name' could not be restored. Details: $($_.Exception.Message)"
}

Write-Host "Successfully restored the soft deleted API Management instance '$Name'"