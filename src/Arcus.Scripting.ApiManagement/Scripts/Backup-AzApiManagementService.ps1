param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
    [Parameter(Mandatory = $true)][string] $StorageAccountResourceGroupName = $(throw = "Resource group for storage account is required"),
    [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Storage account name is required"),
    [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "API managgement service name is required"),
    [Parameter(Mandatory = $true)][string] $ContainerName = $(throw "Name of the target blob container is required"),
    [Parameter(Mandatory = $false)][string]  $BlobName = $null,
    [Parameter(Mandatory = $false)][switch] $PassThru = $false,
    [Parameter(Mandatory = $false)][Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer] $DefaultProfile = $null
)

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

    Write-Verbose "Start backing up Azure API management service '$($ServiceName)' in resource group '$($ResourceGroupName)'..."
    if ($BlobName -ne $null) {
        if ($PassThru) {
            if ($DefaultProfile -ne $null) {
                Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -TargetContainerName $ContainerName -TargetBlobName $BlobName -PassThru -DefaultProfile $DefaultProfile
            } else {
                Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -TargetContainerName $ContainerName -TargetBlobName $BlobName -PassThru
            }
        } else {
            if ($DefaultProfile -ne $null) {
                Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -TargetContainerName $ContainerName -TargetBlobName $BlobName -DefaultProfile $DefaultProfile
            } else {
                Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -TargetContainerName $ContainerName -TargetBlobName $BlobName
            }
        }
    } else {
        if ($PassThru) {
            if ($DefaultProfile -ne $null) {
                Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -TargetContainerName $ContainerName -PassThru -DefaultProfile $DefaultProfile
            } else {
                Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -TargetContainerName $ContainerName -PassThru
            }
        } else {
            if ($DefaultProfile -ne $null) {
                Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -TargetContainerName $ContainerName -DefaultProfile $DefaultProfile
            } else {
                Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -TargetContainerName $ContainerName
            }
        }
    }

    Write-Host "Azure API management service '$($ServiceName)' in resource group '$($ResourceGroupName)' is backed-up!" -ForegroundColor Green
}
