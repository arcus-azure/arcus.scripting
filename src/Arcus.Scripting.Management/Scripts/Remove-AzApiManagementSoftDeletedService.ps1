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

Write-Verbose "Removing the soft deleted Azure API Management instance '$Name'..."
try {
    $serviceId = ($deletedServices.value | Where-Object name -eq $Name).id
    $deleteUri = "$resourceManagerUrl" + "$serviceId" + "?api-version=$ApiVersion"
    $removeService = Invoke-RestMethod -Method DELETE -Uri $deleteUri -Headers $authHeader
} catch {
    throw "Soft deleted Azure API Management service '$Name' could not be removed. Details: $($_.Exception.Message)"
}

Write-Host "Successfully removed the soft deleted Azure API Management service '$Name'" -ForegroundColor Green