param(
  [string][Parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
  [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API management service name is required"),
  [string][Parameter(Mandatory = $true)] $ConfigurationFile = $(throw "Path to the configuration file is required"),
  [switch][parameter(Mandatory = $false)] $StrictlyFollowConfigurationFile = $false,
  [string][parameter(Mandatory = $false)] $ApiVersion = "2022-08-01",
  [string][parameter(Mandatory = $false)] $SubscriptionId,
  [string][parameter(Mandatory = $false)] $AccessToken
)

if (-not (Test-Path -Path $ConfigurationFile)) {
  throw "Cannot apply user configuration to Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName' based on JSON configuration file because no file was found at: '$ConfigurationFile'"
}
if ($null -eq (Get-Content -Path $ConfigurationFile -Raw)) {
  throw "Cannot apply user configuration to Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName' based on JSON configuration file because the file is empty."
}

$schema = @'
    {
      "$schema": "https://json-schema.org/draft/2020-12/schema",
      "$id": "https://scripting.arcus-azure.net/Features/powershell/azure-api-management/config.json",
      "type": "array",
      "title": "The configuration JSON schema",
      "$defs": {},
      "prefixItems": [
        {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "firstName": {
              "type": "string"
            },
            "lastName": {
              "type": "string"
            },
            "userId": {
              "type": "string"
            },
            "mailAddress": {
              "type": "string"
            },
            "sendNotification": {
              "type": "boolean"
            },
            "confirmationType": {
              "type": "string",
              "enum": ["signup", "invite"]
            },
            "note": {
              "type": "string"
            },
            "groups": {
              "type": "array",
              "prefixItems": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "properties": {
                    "id": {
                      "type": "string"
                    },
                    "displayName": {
                      "type": "string"
                    },
                    "description": {
                      "type": "string"
                    }
                  },
                  "required": [
                    "id",
                    "displayName"
                  ]
                }
              ]
            },
            "subscriptions": {
              "type": "array",
              "prefixItems": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "properties": {
                    "id": {
                      "type": "string"
                    },
                    "displayName": {
                      "type": "string"
                    },
                    "scope": {
                      "type": "string"
                    },
                    "allowTracing": {
                      "type": "boolean"
                    }
                  },
                  "required": [
                    "id",
                    "displayName",
                    "scope",
                    "allowTracing"
                  ]
                }
              ]
            }
          },
          "required": [
            "firstName",
            "lastName",
            "mailAddress",
            "sendNotification",
            "confirmationType"
          ]
        }
      ]
    }
'@

if (-not (Get-Content -Path $ConfigurationFile -Raw | Test-Json -Schema $schema -ErrorAction SilentlyContinue)) {
  throw "Cannot apply user configuration to Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName' based on JSON configuration file because the file does not contain a valid JSON configuration file."
}

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
  $json = Get-Content $ConfigurationFile | Out-String | ConvertFrom-Json

  $json | ForEach-Object { 
    $firstName = $_.firstName
    $lastName = $_.lastName
    $mailAddress = $_.mailAddress
    $userId = $_.userId
    $note = $_.note
    $sendNotification = $_.sendNotification
    $confirmationType = $_.confirmationType
    $groups = $_.groups
    $subscriptions = $_.subscriptions

    if ($userId) {
      $userId = Create-AzApiManagementUserAccount -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -FirstName $firstName -LastName $lastName -MailAddress $mailAddress -UserId $userId -Note $note -SendNotification $sendNotification -ConfirmationType $confirmationType -ApiVersion $ApiVersion -SubscriptionId $SubscriptionId -AccessToken $AccessToken
    } else {
      $userId = Create-AzApiManagementUserAccount -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -FirstName $firstName -LastName $lastName -MailAddress $mailAddress -UserId $($mailAddress -replace '\W', '-') -Note $note -SendNotification $sendNotification -ConfirmationType $confirmationType -ApiVersion $ApiVersion -SubscriptionId $SubscriptionId -AccessToken $AccessToken
    }

    if ($StrictlyFollowConfigurationFile) {
      $linkedGroups = Get-AzApiManagementGroup -Context $apimContext -UserId $userId
      if ($linkedGroups.Count -gt 0) {
        $linkedGroups | ForEach-Object {
          $groupId = $_.GroupId
          if (-Not $_.System -and ($groups | Where-Object { $_.id -eq $groupId }).Count -eq 0) {                        
            Remove-AzApiManagementUserFromGroup -Context $apimContext -UserId $userId -GroupId $groupId                        
            Write-Verbose "The user with ID '$userId' has been removed from the group '$groupId' in Azure API Management instance '$ServiceName'"
          }
        }
      }

      $linkedSubscriptions = Get-AzApiManagementSubscription -Context $apimContext -UserId $userId
      if ($linkedSubscriptions.Count -gt 0) {
        $linkedSubscriptions | ForEach-Object {
          $subscriptionId = $_.SubscriptionId
          if (($subscriptions | Where-Object { $_.id -eq $subscriptionId }).Count -eq 0) {
            Remove-AzApiManagementSubscription -Context $apimContext -SubscriptionId $subscriptionId                        
            Write-Verbose "The subscription with ID '$subscriptionId' has been removed in Azure API Management instance '$ServiceName'"
          }
        }
      }
    }

    if ($groups.Count -gt 0) {
      $groups | ForEach-Object {
        $groupId = $_.id;
        $groupDisplayName = $_.displayName;
        $groupDescription = $_.description;

        $group = New-AzApiManagementGroup -Context $apimContext -GroupId $groupId -Name $groupDisplayName -Description $groupDescription
        Write-Verbose "A group with ID '$groupId' and name '$groupDisplayName' has been created or updated in Azure API Management instance '$ServiceName'"
        $userToGroup = Add-AzApiManagementUserToGroup -Context $apimContext -GroupId $groupId -UserId $userId
        Write-Verbose "The user with ID '$userId' has been added to the group with ID '$groupId' in Azure API Management instance '$ServiceName'"
      }
    }

    if ($subscriptions.Count -gt 0) {
      $subscriptions | ForEach-Object {
        $subscriptionId = $_.id;
        $subscriptionDisplayName = $_.displayName;
        $subscriptionAllowTracing = $_.allowTracing;
        $subscriptionScope = $_.scope;

        if ($subscriptionAllowTracing) {
          $subscription = New-AzApiManagementSubscription -Context $apimContext -SubscriptionId $subscriptionId -Name $subscriptionDisplayName -Scope $subscriptionScope -UserId $userId -AllowTracing
        } else {
          $subscription = New-AzApiManagementSubscription -Context $apimContext -SubscriptionId $subscriptionId -Name $subscriptionDisplayName -Scope $subscriptionScope -UserId $userId
        }
        Write-Verbose "A subscription for user '$userId' with ID '$subscriptionId' and name '$subscriptionDisplayName' for scope '$subscriptionScope' has been created or updated in Azure API Management instance '$ServiceName'"
      }
    }

    Write-Host "User configuration has successfully been applied for user with id '$userId' to Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'" -ForegroundColor Green
  }
} catch {
  throw "Failed to apply user configuration based on the configuration file '$ConfigurationFile' for Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'. Details: $($_.Exception.Message)"
}