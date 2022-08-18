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
    [string][parameter(Mandatory = $false)] $ApiVersion = "2021-08-01",
    [string][parameter(Mandatory = $false)] $SubscriptionId,
    [string][parameter(Mandatory = $false)] $AccessToken
)

$apimContext = Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName
if ($apimContext -eq $null) {
    throw "Unable to find the Azure API Management Instance $ServiceName in resource group $ResourceGroupName"
}

if ($SubscriptionId -eq "" -or $AccessToken -eq "") {
    # Request accessToken in case the script contains no records
    $token = Get-AzCachedAccessToken

    $AccessToken = $token.AccessToken
    $SubscriptionId = $token.SubscriptionId
}

$apimMgmtEndpoint = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.ApiManagement/service/$ServiceName/users/$($UserId)?notify=$SendNotification&api-version=$ApiVersion"
$fullUrl = $apimMgmtEndpoint.Replace('{subscriptionId}', $SubscriptionId)
    
try
{
    if($ConfirmationType -eq 'invite')
    {
        Write-Host "Attempting to invite $FirstName $LastName ($mailAddress)"
    }
    else
    {
        Write-Host "Attempting to create account for $FirstName $LastName ($mailAddress)"
    }

    $jsonRequest = ConvertTo-Json -Depth 3 @{
        'properties' = @{
            'firstName' = $FirstName
            'lastName' = $LastName
            'email' = $MailAddress
            'confirmation' = $ConfirmationType
            'password' = $Password
            'note' = $Note
        }
    }

    $params = @{
        Method = 'Put'
        Headers = @{ 
	        'authorization'="Bearer $AccessToken"
        }
        URI = $fullUrl
        Body = $jsonRequest
    }

    $web = Invoke-WebRequest @params -ErrorAction Stop
   
    Write-Verbose $web

    if($ConfirmationType -eq 'invite')
    {
        Write-Host "Invitation has been sent to $FirstName $LastName ($mailAddress)"
    }
    else
    {
        Write-Host "Account has been created for $FirstName $LastName ($mailAddress)"
        if($Password -eq $null -or $Password -eq ""){
            Write-Host "Since no password was provided, one has been generated. Please advise the user to change this password the first time logging in"
        }
    }

    return $UserId
}
catch {
    Write-Host $_
    throw "Failed to create an account for $FirstName $LastName ($MailAddress) in the APIM instance $ServiceName"
}