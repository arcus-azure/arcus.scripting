param(
    [string][parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Resource group name is required"),
    [string][parameter(Mandatory = $true)] $StorageAccountName = $(throw "Storage account name is required"),
    [string][parameter(Mandatory = $true)] $ServiceName = $(throw "API managgement service name is required"),
    [string][parametre(Mandatory = $true)] $TargetContainerName = $(throw "Name of the target blob container is required"),
    [string][parameter(Mandatory = $false)] $TargetBlobName = $null,
    [switch][parameter(Mandatory = $false)] $PassThru = $false,
    [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer][parameter(Mandatory = $false)] $DefaultProfile = $null
)

Write-Host "Getting Azure storage account key..."
$storageKeys = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName

if ($storageKeys -eq $null -or $storageKeys.count -eq 0) {
    Write-Error "Cannot backup API Management service because no access keys found for storage account '$StorageAccountName'"
} else {
    Write-Host "Got Azure storage key!"
    $storageKey = $storageKeys[0]
    
    Write-Host "Create new Azure storage context with storage key..."
    $storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageKey.Value
    Write-Host "New Azure storage context with storage key created!"

    Write-Host "Start backing up API management service..."
    if ($TargetBlobName -ne $null) {
        if ($PassThru) {
            if ($DefaultProfile -ne $null) {
                Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageAccount -TargetContainerName $TargetContainerName -TargetBlobName $TargetBlobName -PassThru -DefaultProfile $DefaultProfile
            } else {
                Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageAccount -TargetContainerName $TargetContainerName -TargetBlobName $TargetBlobName -PassThru
            }
        } else {
            Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageAccount -TargetContainerName $TargetContainerName -TargetBlobName $TargetBlobName
        }
    } else {
        Backup-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageAccount -TargetContainerName $TargetContainerName
    }

    Write-Host "API management service is backed-up!"
}
