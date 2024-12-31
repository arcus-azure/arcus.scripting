param(
    [string][Parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
    [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API management service name is required"),
    [string][parameter(Mandatory = $true)] $MailAddress = $(throw "The mail-address of the user is required"),
    [string][parameter(Mandatory = $false)] $SubscriptionId,
    [string][parameter(Mandatory = $false)] $AccessToken
)

$apim = Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName
if ($null -eq $apim) {
    throw "Unable to find the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
}
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName

if ($SubscriptionId -eq "" -or $AccessToken -eq "") {
    # Request accessToken in case the script contains no records
    $token = Get-AzCachedAccessToken

    $AccessToken = $token.AccessToken
    $SubscriptionId = $token.SubscriptionId
}

try {
    Write-Verbose "Retrieving the user account with e-mail '$mailAddress' for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
    $apimUser = Get-AzApiManagementUser -Context $apimContext -Email $MailAddress

    if ($null -ne $apimUser) {
        $apimUserId = $apimUser.UserId

        Write-Verbose "Attempting to remove the user account with e-mail '$mailAddress' and ID '$apimUserId' for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
        Remove-AzApiManagementUser -Context $apimContext -UserId $apimUserId
        Write-Host "Removed the user account with e-mail '$MailAddress' and ID '$apimUserId' for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'" -ForegroundColor Green
    } else {
        Write-Warning "User account with e-mail '$MailAddress' not found in the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
    }    
} catch {
    throw "Failed to remove the user account for '$MailAddress' for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'. Details: $($_.Exception.Message)"
}