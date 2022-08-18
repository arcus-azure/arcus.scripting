param(
    [string][Parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
    [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API management service name is required"),
    [string][parameter(Mandatory = $true)] $MailAddress = $(throw "The mail-address of the user is required"),
    [string][parameter(Mandatory = $false)] $SubscriptionId,
    [string][parameter(Mandatory = $false)] $AccessToken
)

$apim = Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName
if ($apim -eq $null) {
    throw "Unable to find the Azure API Management Instance $ServiceName in resource group $ResourceGroupName"
}
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName

if ($SubscriptionId -eq "" -or $AccessToken -eq "") {
    # Request accessToken in case the script contains no records
    $token = Get-AzCachedAccessToken

    $AccessToken = $token.AccessToken
    $SubscriptionId = $token.SubscriptionId
}

try {
    Write-Host "Retrieving the user account with e-mail '$mailAddress'"
    $apimUser = Get-AzApiManagementUser -Context $apimContext -Email $MailAddress

    if ($apimUser -ne $null) {
        $apimUserId = $apimUser.UserId

        Write-Host "Attempting to remove the user account with e-mail '$mailAddress' and id '$apimUserId'"
        Remove-AzApiManagementUser -Context $apimContext -UserId $apimUserId
        Write-Host "Removed the user account with e-mail '$mailAddress' and id '$apimUserId'"
    } else {
        Write-Host "User account with e-mail '$mailAddress' not found in the APIM instance '$ServiceName'"
    }    
}
catch {
    Write-Host $_
    throw "Failed to remove the user account for '$MailAddress' in the APIM instance '$ServiceName'"
}