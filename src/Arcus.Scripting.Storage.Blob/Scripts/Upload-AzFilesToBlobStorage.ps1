param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Requires a resource group name where the Azure storage account is located"),
    [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Requires a name for the Azure sotrage account"),
    [Parameter(Mandatory = $true)][string] $TargetFolderPath = $(throw "Requires a folder file path to locate the targetted the files to be uploaded to Azure Blob Storage"),
    [Parameter(Mandatory = $true)][string] $ContainerName = $(throw "Requires a name for the Azure Blob Storage container to where the targetted files should be uploaded"),
    [Parameter(Mandatory = $false)][string] $ContainerPermissions = "Off",
    [Parameter(Mandatory = $false)][string] $FilePrefix = ""
)

$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName

try {
    Write-Verbose "Try using existing Azure Blob storage container '$ContainerName..."
    Get-AzStorageContainer -Context $storageAccount.Context -Name $ContainerName -ErrorAction Stop
    Write-Verbose "Using existing Azure Blob storage container '$ContainerName'"
} catch {
    Write-Verbose "Creating Azure Blob storage container '$ContainerName' to upload files..."
    New-AzStorageContainer -Context $storageAccount.Context -Name $ContainerName -Permission $ContainerPermissions
    Write-Verbose "Created Azure Blob storage container '$ContainerName' to upload files"
}

$files = Get-ChildItem $TargetFolderPath -File
Write-Verbose "Uploading files from '$TargetFolderPath' to Azure Blob storage container '$ContainerName' in resource group '$ResourceGroupName'..."

foreach ($file in $files) {
    $blobFileName = $FilePrefix + $file.Name

    $content = Set-AzStorageBlobContent -File $file.FullName -Container $ContainerName -Blob $blobFileName -Context $storageAccount.Context -Force
    $blobUri = $content.ICloudBlob.uri.AbsoluteUri
    Write-Host "Uploaded file '$($file.Name)' to Azure Blob storage container: $blobUri" -ForegroundColor Green
}