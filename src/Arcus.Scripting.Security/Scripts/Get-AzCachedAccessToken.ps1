param(
   [Parameter()][switch] $AssignGlobalVariables = $false
)

function Get-AzCachedAccessToken()
{
    if (-not (Get-Module Az.Accounts)) {
        Import-Module Az.Accounts
    }

    $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    if (-not $azProfile.Accounts.Count) {
        Write-Error "Ensure you have logged in (Connect-AzAccount) before calling this function."
    }

    $currentAzureContext = Get-AzContext

    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azProfile)
    
    Write-Verbose ("Tenant: {0}" -f  $currentAzureContext.Subscription.Name)
    
    $token = $profileClient.AcquireAccessToken($currentAzureContext.Tenant.TenantId)
    
    if($AssignGlobalVariables) {
        $Global:subscriptionId = $currentAzureContext.Subscription.Id
        Write-Host "Global variable 'subscriptionId' assigned."

        $Global:accessToken = $token.AccessToken
        Write-Host "Global variable 'accessToken' assigned."
    }

    Write-Host "AccessToken and subscriptionId retrieved"

    return new-object psobject -Property @{ SubscriptionId = $currentAzureContext.Subscription.Id; AccessToken = $token.AccessToken }
}

Get-AzCachedAccessToken