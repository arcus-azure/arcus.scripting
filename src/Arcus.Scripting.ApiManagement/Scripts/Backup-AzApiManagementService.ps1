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

Write-Host "Getting Azure storage account key..."
$storageKeys = Get-AzStorageAccountKey -ResourceGroupName $StorageAccountResourceGroupName -StorageAccountName $StorageAccountName

if ($storageKeys -eq $null -or $storageKeys.count -eq 0) {
    Write-Error "Cannot backup API Management service because no access keys found for storage account '$StorageAccountName'"
} else {
    Write-Host "Got Azure storage key!"
    $storageKey = $storageKeys[0]
    
    Write-Host "Create new Azure storage context with storage key..."
    $storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageKey.Value
    Write-Host "New Azure storage context with storage key created!"

    Write-Host "Start backing up API management service..."
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

    Write-Host "API management service is backed-up!"
}
