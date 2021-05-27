param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
    [Parameter(Mandatory = $true)][string] $StorageAccountResourceGroupName = $(throw = "Resource group for storage account is required"),
    [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Storage account name is required"),
    [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "API managgement service name is required"),
    [Parameter(Mandatory = $true)][string] $ContainerName =$(throw "Source container name is required"),
    [Parameter(Mandatory = $true)][string] $BlobName = $(throw "Source blob name is required"),
    [Parameter(Mandatory = $false)][switch] $PassThru = $false,
    [Parameter(Mandatory = $false)][Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer] $DefaultProfile = $null
)

Write-Host "Getting Azure storage account key..."
$storageKeys = Get-AzStorageAccountKey -ResourceGroupName $StorageAccountResourceGroupName -StorageAccountName $StorageAccountName

if ($storageKeys -eq $null -or $storageKeys.count -eq 0) {
    Write-Error "Cannot restore API Management service because no access keys found for storage account '$StorageAccountName'"
} else {
    Write-Host "Got Azure storage key!"
    $storageKey = $storageKeys[0]
    
    Write-Host "Create new Azure storage context with storage key..."
    $storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageKey.Value
    Write-Host "New Azure storage context with storage key created!"

    Write-Host "Start restoring up API management service..."
    if ($PassThru) {
        if ($DefaultProfile -ne $null) {
            Restore-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -SourceContainerName $ContainerName -SourceBlobName $BlobName -PassThru -DefaultProfile $DefaultProfile
        } else {
            Restore-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -SourceContainerName $ContainerName -SourceBlobName $BlobName -PassThru
        }
    } else {
        if ($DefaultProfile -ne $null) {
            Restore-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -SourceContainerName $ContainerName -SourceBlobName $BlobName -DefaultProfile $DefaultProfile
        } else {
            Restore-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -SourceContainerName $ContainerName -SourceBlobName $BlobName
        }
    }
    Write-Host "API management service is restored!"
}
