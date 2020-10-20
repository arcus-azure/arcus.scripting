param(
    [string][parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
    [string][parameter(Mandatory = $true)] $StorageAccountResourceGroupName = $(throw = "Resource group for storage account is required"),
    [string][parameter(Mandatory = $true)] $StorageAccountName = $(throw "Storage account name is required"),
    [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API managgement service name is required"),
    [string][parameter(Mandatory = $true)] $ContainerName = $(throw "Name of the target blob container is required"),
    [string][parameter(Mandatory = $false)] $BlobName = $null,
    [switch][parameter(Mandatory = $false)] $PassThru = $false,
    [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer][parameter(Mandatory = $false)] $DefaultProfile = $null
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
            Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -TargetContainerName $ContainerName -TargetBlobName $BlobName
        }
    } else {
        Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -TargetContainerName $ContainerName
    }

    Write-Host "API management service is backed-up!"
}
