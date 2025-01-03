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

if ($AccessType -eq 'UserAssignedManagedIdentity' -and $IdentityClientId -eq "") {
    throw "Id of the user assigned managed identity is required if AccessType is set to 'UserAssignedManagedIdentity'"
}

Write-Verbose "Getting Azure storage account key for storage account '$($StorageAccountName)' in resource group '$($StorageAccountResourceGroupName)'..."
$storageKeys = Get-AzStorageAccountKey -ResourceGroupName $StorageAccountResourceGroupName -StorageAccountName $StorageAccountName

if ($null -eq $storageKeys -or $storageKeys.count -eq 0) {
    Write-Error "Cannot backup API Management service because no access keys found for storage account '$StorageAccountName' in resource group '$($StorageAccountResourceGroupName)'"
} else {
    Write-Host "Got Azure storage key for storage account '$($StorageAccountName)' in resource group '$($StorageAccountResourceGroupName)'!" -ForegroundColor Green
    $storageKey = $storageKeys[0]
    
    Write-Verbose "Creating new Azure storage context for storage account '$($StorageAccountName)' with storage key..."
    $storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageKey.Value
    Write-Host "New Azure storage context for storage account '$($StorageAccountName)' with storage key created!" -ForegroundColor Green

    $backupArguments = @{
      ResourceGroupName = $ResourceGroupName
      Name = $ServiceName
      AccessType = $AccessType
      StorageContext = $storageContext
      TargetContainerName = $ContainerName
      DefaultProfile = $DefaultProfile
    }

    if ($PassThru) {
      $backupArguments.PassThru = $true
    } else {
      $backupArguments.PassThru = $false
    }

    if ($AccessType -eq 'UserAssignedManagedIdentity') {
      $backupArguments.IdentityClientId = $IdentityClientId
    }

    if ($BlobName -ne $null -and $BlobName -ne "") {
      $backupArguments.TargetBlobName = $BlobName
    }

    Write-Verbose "Start backing up Azure API Management instance '$($ServiceName)' in resource group '$($ResourceGroupName)'..."
    Backup-AzApiManagement @backupArguments
    Write-Host "Azure API Management instance '$($ServiceName)' in resource group '$($ResourceGroupName)' is backed-up!" -ForegroundColor Green
}
