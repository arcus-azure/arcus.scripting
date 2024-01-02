param(
    [string][Parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
    [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API management service name is required"),
    [string][Parameter(Mandatory = $true)] $ConfigurationFileName = $(throw "Name of configuration file is required"),
    [string][parameter(Mandatory = $false)] $ApiVersion = "2021-08-01",
    [string][parameter(Mandatory = $false)] $SubscriptionId,
    [string][parameter(Mandatory = $false)] $AccessToken
)

try
{
    $json = Get-Content $ConfigurationFileName | Out-String | ConvertFrom-Json

    $json | ForEach-Object { 
        $firstName = $_.firstName
        $lastName = $_.lastName
        $mailAddress = $_.mailAddress
        $userId = $_.userId
        $note = $_.note
        $sendNotification = $_.sendNotification
        $confirmationType = $_.confirmationType

        if ($userId) {
            D:\Git\arcus.scripting\src\Arcus.Scripting.ApiManagement\Scripts\Create-AzApiManagementUserAccount.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -FirstName $firstName -LastName $lastName -MailAddress $mailAddress -UserId $userId -Note $note -SendNotification $sendNotification -ConfirmationType $confirmationType -ApiVersion $ApiVersion -SubscriptionId $SubscriptionId -AccessToken $AccessToken
        } else {
            D:\Git\arcus.scripting\src\Arcus.Scripting.ApiManagement\Scripts\Create-AzApiManagementUserAccount.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -FirstName $firstName -LastName $lastName -MailAddress $mailAddress -UserId $($mailAddress -replace '\W', '-') -Note $note -SendNotification $sendNotification -ConfirmationType $confirmationType -ApiVersion $ApiVersion -SubscriptionId $SubscriptionId -AccessToken $AccessToken
        }

    }
}
catch {
    Write-Host $_
    throw "Failed to create users based on the configuration file '$ConfigurationFileName' for Azure API Management service '$ServiceName' in resource group '$ResourceGroupName'"
}