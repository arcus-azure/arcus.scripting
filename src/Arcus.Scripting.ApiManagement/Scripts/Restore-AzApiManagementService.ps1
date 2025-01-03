param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
    [Parameter(Mandatory = $true)][string] $StorageAccountResourceGroupName = $(throw = "Resource group for storage account is required"),
    [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Storage account name is required"),
    [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "API managgement service name is required"),
    [Parameter(Mandatory = $true)][string] $ContainerName = $(throw "Source container name is required"),
    [Parameter(Mandatory = $true)][string] $BlobName = $(throw "Source blob name is required"),
    [Parameter(Mandatory = $false)][switch] $PassThru = $false,
    [Parameter(Mandatory = $false)][Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer] $DefaultProfile = $null
)

Write-Verbose "Getting Azure storage account key for Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'..."
$storageKeys = Get-AzStorageAccountKey -ResourceGroupName $StorageAccountResourceGroupName -StorageAccountName $StorageAccountName

if ($null -eq $storageKeys -or $storageKeys.count -eq 0) {
    Write-Error "Cannot restore Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName' because no access keys found for storage account '$StorageAccountName'"
} else {
    Write-Host "Got Azure storage key for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'!" -ForegroundColor Green
    $storageKey = $storageKeys[0]
    
    Write-Verbose "Creating new Azure storage context with storage key for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'..."
    $storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageKey.Value
    Write-Host "New Azure storage context with storage key created for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'!" -ForegroundColor Green

    Write-Verbose "Start restoring up Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'..."
    if ($PassThru) {
        if ($null -ne $DefaultProfile) {
            Restore-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -SourceContainerName $ContainerName -SourceBlobName $BlobName -PassThru -DefaultProfile $DefaultProfile
        } else {
            Restore-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -SourceContainerName $ContainerName -SourceBlobName $BlobName -PassThru
        }
    } else {
        if ($null -ne $DefaultProfile) {
            Restore-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -SourceContainerName $ContainerName -SourceBlobName $BlobName -DefaultProfile $DefaultProfile
        } else {
            Restore-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName -StorageContext $storageContext -SourceContainerName $ContainerName -SourceBlobName $BlobName
        }
    }
    Write-Host "Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName' is restored!" -ForegroundColor Green
}
