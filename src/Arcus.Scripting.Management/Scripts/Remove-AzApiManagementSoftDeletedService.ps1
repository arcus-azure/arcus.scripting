Param(
    [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the API Management instance is required"),
    [Parameter(Mandatory = $false)][string] $SubscriptionId = "",
    [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud",
    [Parameter(Mandatory = $false)][string] $AccessToken = "",
    [Parameter(Mandatory = $false)][string] $ApiVersion = "2021-08-01"
)

if($SubscriptionId -eq "" -or $AccessToken -eq ""){
    # Request accessToken in case the script contains no records
    $token = Get-AzCachedAccessToken

    $AccessToken = $token.AccessToken
    $SubscriptionId = $token.SubscriptionId
}

$authHeader = @{
   'Authorization'='Bearer ' + $AccessToken
}

Write-Verbose "Checking if the API Management instance with name '$Name' is listed as a soft deleted service"
$getUri = . $PSScriptRoot\Get-AzApiManagementResourceManagementUrl.ps1 -EnvironmentName $EnvironmentName -SubscriptionId $SubscriptionId -ApiVersion $ApiVersion
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