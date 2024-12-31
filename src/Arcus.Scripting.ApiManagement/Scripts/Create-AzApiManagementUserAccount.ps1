param(
    [string][Parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
    [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API management service name is required"),
    [string][parameter(Mandatory = $true)] $FirstName = $(throw "The first name of the user is required"),
    [string][parameter(Mandatory = $true)] $LastName = $(throw "The last name of the user is required"),
    [string][parameter(Mandatory = $true)] $MailAddress = $(throw "The mail-address of the user is required"),
    [string][parameter(Mandatory = $false)] $UserId = $($MailAddress -replace '\W', '-'),
    [string][parameter(Mandatory = $false)] $Password,
    [string][parameter(Mandatory = $false)] $Note,
    [switch][parameter(Mandatory = $false)] $SendNotification = $false,
    [string][parameter(Mandatory = $false)][ValidateSet('invite', 'signup')] $ConfirmationType = "invite",
    [string][parameter(Mandatory = $false)] $ApiVersion = "2022-08-01",
    [string][parameter(Mandatory = $false)] $SubscriptionId,
    [string][parameter(Mandatory = $false)] $AccessToken
)

$apim = Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName
if ($null -eq $apim) {
    throw "Unable to find the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
}

if ($SubscriptionId -eq "" -or $AccessToken -eq "") {
    # Request accessToken in case the script contains no records
    $token = Get-AzCachedAccessToken

    $AccessToken = $token.AccessToken
    $SubscriptionId = $token.SubscriptionId
}

$apimMgmtEndpoint = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.ApiManagement/service/$ServiceName/users/$($UserId)?notify=$SendNotification&api-version=$ApiVersion"
$fullUrl = $apimMgmtEndpoint.Replace('{subscriptionId}', $SubscriptionId)

try {
    if ($ConfirmationType -eq 'invite') {
        Write-Verbose "Attempting to invite $FirstName $LastName ($mailAddress) for Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
    } else {
        Write-Verbose "Attempting to create account for $FirstName $LastName ($mailAddress) for Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
    }

    $jsonRequest = ConvertTo-Json -Depth 3 @{
        'properties' = @{
            'firstName'    = $FirstName
            'lastName'     = $LastName
            'email'        = $MailAddress
            'confirmation' = $ConfirmationType
            'password'     = $Password
            'note'         = $Note
        }
    }

    $params = @{
        Method      = 'Put'
        Headers     = @{ 
            'authorization' = "Bearer $AccessToken"
        }
        URI         = $fullUrl
        Body        = $jsonRequest
        ContentType = 'application/json'
    }

    $web = Invoke-WebRequest @params -ErrorAction Stop
   
    Write-Verbose $web

    if ($ConfirmationType -eq 'invite') {
        Write-Host "Invitation has been sent to $FirstName $LastName ($mailAddress) for Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'" -ForegroundColor Green
    } else {
        Write-Host "Account has been created for $FirstName $LastName ($mailAddress) for Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'" -ForegroundColor Green
        if ($Password -eq $null -or $Password -eq "") {
            Write-Warning "Since no password was provided, one has been generated. Please advise the user to change this password the first time logging in for the Azure API Management instance '$($ServiceName)' in resource group '$($ResourceGroupName)'"
        }
    }

    return $UserId
} catch {
    throw "Failed to create an account for $FirstName $LastName ($MailAddress) for Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'. Details: $($_.Exception.Message)"
}