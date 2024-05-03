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

if ($storageKeys -eq $null -or $storageKeys.count -eq 0) {
    Write-Error "Cannot backup API Management service because no access keys found for storage account '$StorageAccountName' in resource group '$($StorageAccountResourceGroupName)'"
} else {
    Write-Host "Got Azure storage key for storage account '$($StorageAccountName)' in resource group '$($StorageAccountResourceGroupName)'!" -ForegroundColor Green
    $storageKey = $storageKeys[0]
    
    Write-Verbose "Creating new Azure storage context for storage account '$($StorageAccountName)' with storage key..."
    $storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageKey.Value
    Write-Host "New Azure storage context for storage account '$($StorageAccountName)' with storage key created!" -ForegroundColor Green

    Write-Verbose "Start backing up Azure API Management instance '$($ServiceName)' in resource group '$($ResourceGroupName)'..."
    if ($BlobName -ne $null -and $BlobName -ne "") {
        if ($PassThru) {
            if ($DefaultProfile -ne $null) {
                if ($AccessType -eq 'UserAssignedManagedIdentity') {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -IdentityClientId $IdentityClientId -StorageContext $storageContext -TargetContainerName $ContainerName -TargetBlobName $BlobName -PassThru -DefaultProfile $DefaultProfile
                } else {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -StorageContext $storageContext -TargetContainerName $ContainerName -TargetBlobName $BlobName -PassThru -DefaultProfile $DefaultProfile
                }
            } else {
                if ($AccessType -eq 'UserAssignedManagedIdentity') {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -IdentityClientId $IdentityClientId -StorageContext $storageContext -TargetContainerName $ContainerName -TargetBlobName $BlobName -PassThru
                } else {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -StorageContext $storageContext -TargetContainerName $ContainerName -TargetBlobName $BlobName -PassThru
                }
            }
        } else {
            if ($DefaultProfile -ne $null) {
                if ($AccessType -eq 'UserAssignedManagedIdentity') {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -IdentityClientId $IdentityClientId -StorageContext $storageContext -TargetContainerName $ContainerName -TargetBlobName $BlobName -DefaultProfile $DefaultProfile
                } else {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -StorageContext $storageContext -TargetContainerName $ContainerName -TargetBlobName $BlobName -DefaultProfile $DefaultProfile
                }
            } else {
                if ($AccessType -eq 'UserAssignedManagedIdentity') {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -IdentityClientId $IdentityClientId -StorageContext $storageContext -TargetContainerName $ContainerName -TargetBlobName $BlobName
                } else {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -StorageContext $storageContext -TargetContainerName $ContainerName -TargetBlobName $BlobName
                }
            }
        }
    } else {
        if ($PassThru) {
            if ($DefaultProfile -ne $null) {
                if ($AccessType -eq 'UserAssignedManagedIdentity') {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -IdentityClientId $IdentityClientId -StorageContext $storageContext -TargetContainerName $ContainerName -PassThru -DefaultProfile $DefaultProfile
                } else {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -StorageContext $storageContext -TargetContainerName $ContainerName -PassThru -DefaultProfile $DefaultProfile
                }
            } else {
                if ($AccessType -eq 'UserAssignedManagedIdentity') {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -IdentityClientId $IdentityClientId -StorageContext $storageContext -TargetContainerName $ContainerName -PassThru
                } else {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -StorageContext $storageContext -TargetContainerName $ContainerName -PassThru
                }
            }
        } else {
            if ($DefaultProfile -ne $null) {
                if ($AccessType -eq 'UserAssignedManagedIdentity') {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -IdentityClientId $IdentityClientId -StorageContext $storageContext -TargetContainerName $ContainerName -DefaultProfile $DefaultProfile
                } else {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -StorageContext $storageContext -TargetContainerName $ContainerName -DefaultProfile $DefaultProfile
                }
            } else {
                if ($AccessType -eq 'UserAssignedManagedIdentity') {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -IdentityClientId $IdentityClientId -StorageContext $storageContext -TargetContainerName $ContainerName
                } else {
                    Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -AccessType $AccessType -StorageContext $storageContext -TargetContainerName $ContainerName
                }
            }
        }
    }

    Write-Host "Azure API Management instance '$($ServiceName)' in resource group '$($ResourceGroupName)' is backed-up!" -ForegroundColor Green
}
