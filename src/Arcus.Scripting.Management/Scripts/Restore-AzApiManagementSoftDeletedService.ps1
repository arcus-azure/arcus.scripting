param(
    [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the API Management instance is required"),
    [Parameter(Mandatory = $false)][string] $SubscriptionId = "",     
    [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud",
    [Parameter(Mandatory = $false)][string] $AccessToken = "",  
    [Parameter(Mandatory = $false)][string] $ApiVersion = "2021-08-01"
)

if ($SubscriptionId -eq "" -or $AccessToken -eq "") {
    # Request accessToken in case the script contains no records
    $token = Get-AzCachedAccessToken

    $AccessToken = $token.AccessToken
    $SubscriptionId = $token.SubscriptionId
}

$authHeader = @{
   'Authorization'='Bearer ' + $AccessToken
}

$resourceManagerUrl = . $PSScriptRoot\Get-AzApiManagementResourceManagementUrl.ps1 -EnvironmentName $EnvironmentName

$deletedServices = . $PSScriptRoot\Get-AzApiManagementSoftDeletedResources.ps1 -Name $Name -SubscriptionId $SubscriptionId -ResourceManagerUrl $resourceManagerUrl -AuthHeader $authHeader -ApiVersion $ApiVersion

Write-Verbose "Restoring the soft deleted Azure API Management service '$Name'..."
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
    $putUri = "$resourceManagerUrl" + "$serviceId" + "?api-version=$ApiVersion"
    $restoreService = Invoke-RestMethod -Method PUT -Uri $putUri -ContentType 'application/json' -Headers $authHeader -Body $body
} catch {
    throw "Soft deleted Azure API Management service '$Name' could not be restored. Details: $($_.Exception.Message)"
}

Write-Host "Successfully restored the soft deleted API Management service '$Name'" -ForegroundColor Green