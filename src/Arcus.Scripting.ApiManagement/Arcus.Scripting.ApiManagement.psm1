<#
 .Synopsis
  Backs up an API Management service.

 .Description
  The Backup-AzApiManagement cmdlet backs up an instance of an Azure API Management instance by getting the account storage key and creating an new storage context. 
  This cmdlet stores the backup as an Azure Storage blob.

 .Parameter ResourceGroupName
  The name of the of resource group under which the API Management deployment exists.

 .Parameter StorageAccountResourceGroupName
  The name of the resource group under which the Storage Account exists.

 .Parameter StorageAccountName
  The name of the Storage account for which this cmdlet gets keys.

 .Parameter ServiceName
  The name of the API Management deployment that this cmdlet backs up.

 .Parameter ContainerName
  The name of the container of the blob for the backup. If the container does not exist, this cmdlet creates it.

 .Parameter AccessType
  The type of access to be used for the connection from APIM to the storage account, valid values are `SystemAssignedManagedIdentity` and `UserAssignedManagedIdentity`.

 .Parameter IdentityClientId
  The client id of the managed identity to connect from API Management to Storage Account, this is only required when AccessType is set to `UserAssignedManagedIdentity`.

 .Parameter BlobName
  The name of the blob for the backup. If the blob does not exist, this cmdlet creates it. 
  This cmdlet generates a default value based on the following pattern: {Name}-{yyyy-MM-dd-HH-mm}.apimbackup

 .Parameter PassThru
  Indicates that this cmdlet returns the backed up PsApiManagement object, if the operation succeeds.

 .Parameter DefaultProfile
  The credentials, account, tenant, and subscription used for communication with azure.
#>
function Backup-AzApiManagementService {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
        [Parameter(Mandatory = $true)][string] $StorageAccountResourceGroupName = $(throw = "Resource group for storage account is required"),
        [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Storage account name is required"),
        [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "API management service name is required"),
        [Parameter(Mandatory = $true)][string] $ContainerName = $(throw "Name of the target blob container is required"),
        [Parameter(Mandatory = $true)][string][ValidateSet('SystemAssignedManagedIdentity', 'UserAssignedManagedIdentity')] $AccessType = $(throw "The access type is required"),
        [Parameter(Mandatory = $false)][string] $IdentityClientId = "",
        [Parameter(Mandatory = $false)][string] $BlobName = $null,
        [Parameter(Mandatory = $false)][switch] $PassThru = $false,
        [Parameter(Mandatory = $false)][Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer] $DefaultProfile = $null
    )

    if ($PassThru) {
        . $PSScriptRoot\Scripts\Backup-AzApiManagementService.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountResourceGroupName $StorageAccountResourceGroupName -StorageAccountName $StorageAccountName -ServiceName $ServiceName -ContainerName $ContainerName -AccessType $AccessType -IdentityClientId $IdentityClientId -BlobName $BlobName -DefaultProfile $DefaultProfile -PassThru
    } else {
        . $PSScriptRoot\Scripts\Backup-AzApiManagementService.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountResourceGroupName $StorageAccountResourceGroupName -StorageAccountName $StorageAccountName -ServiceName $ServiceName -ContainerName $ContainerName -AccessType $AccessType -IdentityClientId $IdentityClientId -BlobName $BlobName -DefaultProfile $DefaultProfile
    }
}

Export-ModuleMember -Function Backup-AzApiManagementService

<#
 .Synopsis
  Create an operation on an API in Azure API Management.

 .Description
  Create an operation on an existing API in Azure API Management.

 .Parameter ResourceGroupName
  The resource group containing the API Management service.

 .Parameter ServiceName
  The name of the API Management service located in Azure.

 .Parameter ServiceName
  The name of the Azure API Management instance.

 .Parameter ApiId
  The ID to identify the API running in Azure API Management.

 .Parameter OperationId
  The ID to identify the to-be-created operation on the API.

 .Parameter Method
  The method of the to-be-created operation on the API.

 .Parameter UrlTemplate
  The URL-template, or endpoint-URL, of the to-be-created operation on the API.

 .Parameter OperationName
  The optional descriptive name to give to the to-be-created operation on the API.

 .Parameter Description
  The optional explanation to describe the to-be-created operation on the API.

 .Parameter PolicyFilePath
  The path to the file containing the optional policy of the to-be-created operation on the API.
#>
function Create-AzApiManagementApiOperation {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group is required"),
        [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "Service name for API Management service name is required"),
        [Parameter(Mandatory = $true)][string] $ApiId = $(throw "API ID to identitfy the Azure API Management instance is required"),
        [Parameter(Mandatory = $true)][string] $OperationId = $(throw "Operation ID is required"),
        [Parameter(Mandatory = $true)][string] $Method = $(throw "Method is required"),
        [Parameter(Mandatory = $true)][string] $UrlTemplate = $(throw "URL template is required"),
        [Parameter(Mandatory = $false)][string] $OperationName = $OperationId,
        [Parameter(Mandatory = $false)][string] $Description = "",
        [Parameter(Mandatory = $false)][string] $PolicyFilePath = ""
    )
    . $PSScriptRoot\Scripts\Create-AzApiManagementApiOperation.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -ApiId $ApiId -OperationId $OperationId -Method $Method -UrlTemplate $UrlTemplate -OperationName $OperationName -Description $Description -PolicyFilePath $PolicyFilePath
}

Export-ModuleMember -Function Create-AzApiManagementApiOperation

<#
 .Synopsis
  Creates a user in Azure API Management.

 .Description
  Signup or invite a new user in an existing Azure API Management instance.

 .Parameter ResourceGroupName
  The resource group containing the API Management service.

 .Parameter ServiceName
  The name of the API Management service located in Azure.

 .Parameter FirstName
  The first name of the user.

 .Parameter LastName
  The last name of the user.

 .Parameter MailAddress
  The e-mail address of the user.

 .Parameter UserId
  [Optional] The UserId the user should get in API Management.

 .Parameter Password
  [Optional] The password for the user.

 .Parameter Note
  [Optional] The note that should be added to the user in API Management.

 .Parameter SendNotification
  [Optional] Whether or not to send a notification to the user. 

 .Parameter ConfirmationType
  [Optional] The confirmation type to use when creating the user, this can be set to 'invite' or 'signup'.

 .Parameter ApiVersion
  [Optional] The version of the API to be used.

 .Parameter SubscriptionId
  [Optional] The Id of the subscription containing the Azure API Management instance. When not provided, it will be retrieved from the current context (Get-AzContext).

 .Parameter AccessToken
  [Optional] The access token to be used. When not provided, it will be retrieved from the current context (Get-AzContext).
#>
function Create-AzApiManagementUserAccount {
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
    if ($SendNotification) {
        . $PSScriptRoot\Scripts\Create-AzApiManagementUserAccount.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -FirstName $FirstName -LastName $LastName -MailAddress $MailAddress -UserId $UserId -Password $Password -Note $Note -ConfirmationType $ConfirmationType -ApiVersion $ApiVersion -SubscriptionId $SubscriptionId -AccessToken $AccessToken -SendNotification
    } else {
        . $PSScriptRoot\Scripts\Create-AzApiManagementUserAccount.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -FirstName $FirstName -LastName $LastName -MailAddress $MailAddress -UserId $UserId -Password $Password -Note $Note -ConfirmationType $ConfirmationType -ApiVersion $ApiVersion -SubscriptionId $SubscriptionId -AccessToken $AccessToken
    }
}

Export-ModuleMember -Function Create-AzApiManagementUserAccount

<#
 .Synopsis
  Create or update users in Azure API Management.

 .Description
  Create or update users in an existing Azure API Management instance based on a configuration file.

 .Parameter ResourceGroupName
  The resource group containing the API Management service.

 .Parameter ServiceName
  The name of the API Management service located in Azure.

 .Parameter ConfigurationFile
  The file containing the users and their configuration.

 .Parameter StrictlyFollowConfigurationFile
  Indicates whether the configuration file should strictly be followed, for example remove the user from groups not defined in the configuration file.

 .Parameter ApiVersion
  [Optional] The version of the API to be used.

 .Parameter SubscriptionId
  [Optional] The Id of the subscription containing the Azure API Management instance. When not provided, it will be retrieved from the current context (Get-AzContext).

 .Parameter AccessToken
  [Optional] The access token to be used. When not provided, it will be retrieved from the current context (Get-AzContext).
#>
function Create-AzApiManagementUserAccountsFromConfig {
    param(
        [string][Parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
        [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API management service name is required"),
        [string][Parameter(Mandatory = $true)] $ConfigurationFile = $(throw "Name of configuration file is required"),
        [switch][parameter(Mandatory = $false)] $StrictlyFollowConfigurationFile = $false,
        [string][parameter(Mandatory = $false)] $ApiVersion = "2022-08-01",
        [string][parameter(Mandatory = $false)] $SubscriptionId,
        [string][parameter(Mandatory = $false)] $AccessToken
    )
    if ($StrictlyFollowConfigurationFile) {
        . $PSScriptRoot\Scripts\Create-AzApiManagementUserAccountsFromConfig.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -ConfigurationFile $ConfigurationFile -ApiVersion $ApiVersion -SubscriptionId $SubscriptionId -AccessToken $AccessToken -StrictlyFollowConfigurationFile
    } else {
        . $PSScriptRoot\Scripts\Create-AzApiManagementUserAccountsFromConfig.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -ConfigurationFile $ConfigurationFile -ApiVersion $ApiVersion -SubscriptionId $SubscriptionId -AccessToken $AccessToken
    }
}

Export-ModuleMember -Function Create-AzApiManagementUserAccountsFromConfig


<#
 .Synopsis
  Removes a user from Azure API Management.

 .Description
  Remove a user from Azure API Management based on e-mail address.

 .Parameter ResourceGroupName
  The resource group containing the API Management service.

 .Parameter ServiceName
  The name of the API Management service located in Azure.

 .Parameter MailAddress
  The e-mail address of the user.

 .Parameter SubscriptionId
  [Optional] The Id of the subscription containing the Azure API Management instance. When not provided, it will be retrieved from the current context (Get-AzContext).

 .Parameter AccessToken
  [Optional] The access token to be used. When not provided, it will be retrieved from the current context (Get-AzContext).
#>
function Remove-AzApiManagementUserAccount {
    param(
        [string][Parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
        [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API management service name is required"),
        [string][parameter(Mandatory = $true)] $MailAddress = $(throw "The mail-address of the user is required"),
        [string][parameter(Mandatory = $false)] $SubscriptionId,
        [string][parameter(Mandatory = $false)] $AccessToken
    )

    . $PSScriptRoot\Scripts\Remove-AzApiManagementUserAccount.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -MailAddress $MailAddress -SubscriptionId $SubscriptionId -AccessToken $AccessToken

}

Export-ModuleMember -Function Remove-AzApiManagementUserAccount

<#
 .Synopsis
  Import a policy to a product in Azure API Management.

 .Description
  Import a policy to a product in Azure API Management.

 .Parameter ResourceGroupName
  The resource group containing the Azure API Management instance.

 .Parameter ServiceName
  The name of the Azure API Management instance located in Azure.

 .Parameter ProductId
  The ID to identify the product in Azure API Management.

 .Parameter PolicyFilePath
  The path to the file containing the optional policy of the to-be-imported policy on the API.
#>
function Import-AzApiManagementProductPolicy {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group is required"),
        [Parameter(Mandatory = $true)][string] $ServiceName = $(throw = "Service name for API Management service name is required"),
        [Parameter(Mandatory = $true)][string] $ProductId = $(throw "Product ID is required"),
        [Parameter(Mandatory = $true)][string] $PolicyFilePath = $(throw "Policy file path is required")
    )

    . $PSScriptRoot\Scripts\Import-AzApiManagementProductPolicy.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -ProductId $ProductId -PolicyFilePath $PolicyFilePath
}

Export-ModuleMember -Function Import-AzApiManagementProductPolicy

<#
.Synopsis
  Remove all defaults from the API Management instance.

 .Description
 Remove all default API's and products from an Azure API Management instance ('echo-api' API, 'starter' & 'unlimited' products), including the subscriptions. 

 .Parameter ResourceGroupName
  The resource group containing the Azure API Management instance.

 .Parameter ServiceName
 The name of the Azure API Management instance.
#>
function Remove-AzApiManagementDefaults {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group is required"),
        [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "Service name for API Management service name is required")
    )

    . $PSScriptRoot\Scripts\Remove-AzApiManagementDefaults.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName 
}

Export-ModuleMember -Function Remove-AzApiManagementDefaults

<#
 .Synopsis
  Import a policy to an API in Azure API Management.

 .Description
  Import a base-policy to an API hosted in Azure API Management.

 .Parameter ResourceGroupName
 The resource group containing the Azure API Management instance.

 .Parameter ServiceName
  The name of the Azure API Management instance located in Azure.

 .Parameter ApiId
  The ID to identify the API running in API Management.

 .Parameter PolicyFilePath
  The path to the file containing the optional policy of the to-be-imported policy on the API.
#>
function Import-AzApiManagementApiPolicy {
    param(
        [parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw = "Resource group is required"),
        [parameter(Mandatory = $true)][string] $ServiceName = $(throw = "Service name for API Management service name is required"),
        [parameter(Mandatory = $true)][string] $ApiId = $(throw = "API ID to identitfy the Azure API Management instance is required"),
        [parameter(Mandatory = $true)][string] $PolicyFilePath = $(throw "Policy file path is required")
    )

    . $PSScriptRoot\Scripts\Import-AzApiManagementApiPolicy.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -ApiId $ApiId -PolicyFilePath $PolicyFilePath
}

Export-ModuleMember -Function Import-AzApiManagementApiPolicy

<#
 .Synopsis
 Imports a policy to an operation in Azure API Management.

 .Description
  Imports a policy from a file to an API operation in Azure API Management.

 .Parameter ResourceGroupName
  The resource group containing the Azure API Management instance.

 .Parameter ServiceName
  The name of the Azure API Management instance located in Azure.
  
 .Parameter ApiId
  The ID to identify the API running in Azure API Management.

 .Parameter OperationId
  The ID to identify the operation for which to import the policy.

 .Parameter PolicyFilePath
  The path to the file containing the to-be-imported policy.
#>
function Import-AzApiManagementOperationPolicy {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group is required"),
        [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "API management service name is required"),
        [Parameter(Mandatory = $true)][string] $ApiId = $(throw "API ID to identitfy the Azure API Management instance is required"),
        [Parameter(Mandatory = $true)][string] $OperationId = $(throw "Operation ID is required"),
        [Parameter(Mandatory = $true)][string] $PolicyFilePath = $(throw "Policy file path is required")
    )

    . $PSScriptRoot\Scripts\Import-AzApiManagementOperationPolicy.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -ApiId $ApiId -OperationId $OperationId -PolicyFilePath $PolicyFilePath
}

Export-ModuleMember -Function Import-AzApiManagementOperationPolicy

<#
 .Synopsis
  Restores an API Management Service from the specified Azure storage blob.

 .Description
  The Restore-AzApiManagement cmdlet restores an API Management Service from the specified backup residing in an Azure Storage blob.

 .Parameter ResourceGroupName
  The name of resource group under which API Management exists.

 .Parameter StorageAccountResourceGroupName
  The name of the resource group that contains the Storage account.

 .Parameter StorageAccountName
  The name of the Storage account for which this cmdlet gets keys.

 .Parameter ServiceName
  The name of the API Management instance that will be restored with the backup.

 .Parameter ContainerName
  The name of the Azure storage backup source container.

 .Parameter BlobName
  The name of the Azure storage backup source blob.

 .Parameter PassThru
  Returns an object representing the item with which you are working. By default, this cmdlet does not generate any output.

 .Parameter DefaultProfile
  The credentials, account, tenant, and subscription used for communication with azure.
#>
function Restore-AzApiManagementService {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
        [Parameter(Mandatory = $true)][string] $StorageAccountResourceGroupName = $(throw = "Resource group for storage account is required"),
        [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name for the Azure storage account is required"),
        [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "Service name for API Management service name is required"),
        [Parameter(Mandatory = $true)][string] $ContainerName = $(throw "Name of the source container is required"),
        [Parameter(Mandatory = $true)][string] $BlobName = $(throw "Name of the Azure storage blob is required"),
        [Parameter(Mandatory = $false)][switch] $PassThru = $false,
        [Parameter(Mandatory = $false)][Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer] $DefaultProfile = $null
    )

    if ($PassThru) {
        . $PSScriptRoot\Scripts\Restore-AzApiManagementService.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountResourceGroupName $StorageAccountResourceGroupName -StorageAccountName $StorageAccountName -ServiceName $ServiceName -ContainerName $ContainerName -BlobName $BlobName -DefaultProfile $DefaultProfile -PassThru
    } else {
        . $PSScriptRoot\Scripts\Restore-AzApiManagementService.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountResourceGroupName $StorageAccountResourceGroupName -StorageAccountName $StorageAccountName -ServiceName $ServiceName -ContainerName $ContainerName -BlobName $BlobName -DefaultProfile $DefaultProfile
    }
}

Export-ModuleMember -Function Restore-AzApiManagementService

<#
 .Synopsis
  Sets the authentication keys in Azure API Management.

 .Description
  Sets the authentication header/query parameter on an API in Azure API Management.

 .Parameter ResourceGroupName
  The resource group containing the Azure API Management instance.

 .Parameter ServiceName
  The name of the Azure API Management instance located in Azure.
  
 .Parameter ApiId
  The ID to identify the API running in Azure API Management.

 .Parameter KeyHeaderName
  The name of the header where the subscription key should be set.

 .Parameter QueryParamName
  The name of the query parameter where the subscription key should be set.
#>
function Set-AzApiManagementApiSubscriptionKey {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw = "Resource group name is required"),
        [Parameter(Mandatory = $true)][string] $ServiceName = $(throw = "Azure API Management instance name is required"),
        [Parameter(Mandatory = $true)][string] $ApiId = $("API ID to identitfy the Azure API Management instance is required"),
        [Parameter(Mandatory = $false)][string] $HeaderName = "x-api-key",
        [Parameter(Mandatory = $false)][string] $QueryParamName = "apiKey"
    )

    . $PSScriptRoot\Scripts\Set-AzApiManagementApiSubscriptionKey.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -ApiId $ApiId -HeaderName $HeaderName -QueryParamName $QueryParamName
}

Export-ModuleMember -Function Set-AzApiManagementApiSubscriptionKey

<#
 .Synopsis
  Uploads a certificate to the Azure API Management certificate store.

 .Description
  Uploads a private certificate to the Azure API Management certificate store, allowing authentication against backend services.

 .Parameter ResourceGroupName
  The name of the resource group containing the Azure API Management instance.

 .Parameter ServiceName
  The name of the Azure API Management instance.

 .Parameter CertificateFilePath
  The full file path to the location of the public certificate.

 .Parameter CertificatePassword
  The password for the private certificate.
#>
function Upload-AzApiManagementCertificate {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
        [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "API management service name is required"),
        [Parameter(Mandatory = $true)][string] $CertificateFilePath = $(throw "Full file path to the certificate is required"),
        [Parameter(Mandatory = $true)][string] $CertificatePassword = $(throw "Password for certificate is required")
    )

    . $PSScriptRoot\Scripts\Upload-AzApiManagementCertificate.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -CertificateFilePath $CertificateFilePath -CertificatePassword $CertificatePassword
}

Export-ModuleMember -Function Upload-AzApiManagementCertificate

<#
 .Synopsis
  Uploads a CA certificate to the Azure API management certificate store.

 .Description
  Uploads a public CA certificate to the Azure API management Root certificate store, allowing certificate validation in the Azure API Management instance policy.

 .Parameter ResourceGroupName
  The name of the resource group containing the Azure API Management instance.

 .Parameter ServiceName
  The name of the Azure API Management instance.

 .Parameter CertificateFilePath
  The full file path to the location of the public CA certificate.

 .Parameter AsJob
  Indicates whether or not the public CA certificate uploading process should be run in the background.
#>
function Upload-AzApiManagementSystemCertificate {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group is required"),
        [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "API Management service name is required"),
        [Parameter(Mandatory = $true)][string] $CertificateFilePath = $(throw "Certificate file-path is required"),
        [Parameter(Mandatory = $false)][switch] $AsJob = $false
    )

    if ($AsJob) {
        . $PSScriptRoot\Scripts\Upload-AzApiManagementSystemCertificate.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -CertificateFilePath $CertificateFilePath -AsJob
    } else {
        . $PSScriptRoot\Scripts\Upload-AzApiManagementSystemCertificate.ps1 -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName -CertificateFilePath $CertificateFilePath
    }
}