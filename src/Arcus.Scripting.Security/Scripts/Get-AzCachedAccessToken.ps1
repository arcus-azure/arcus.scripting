param(
    [Parameter(Mandatory = $false)][switch] $AssignGlobalVariables = $false
)

$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
if (-not $azProfile.Accounts.Count) {
    throw "Ensure you have logged in (Connect-AzAccount) before calling this function"
}

$currentAzureContext = Get-AzContext

$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azProfile)

$token = $profileClient.AcquireAccessToken($currentAzureContext.Tenant.TenantId)

if ($AssignGlobalVariables) {
    $Global:subscriptionId = $currentAzureContext.Subscription.Id
    Write-Host "Global variable 'subscriptionId' assigned"

    $Global:accessToken = $token.AccessToken
    Write-Host "Global variable 'accessToken' assigned"
}

Write-Host "Azure access token and subscription ID retrieved from current active Azure authenticated session"
return New-Object psobject -Property @{ SubscriptionId = $currentAzureContext.Subscription.Id; AccessToken = $token.AccessToken }