param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Requires a resource group name where the Azure storage account is located"),
    [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Requires a name for the Azure sotrage account"),
    [Parameter(Mandatory = $true)][string] $TargetFolderPath = $(throw "Requires a folder file path to locate the targetted the files to be uploaded to Azure Blob Storage"),
    [Parameter(Mandatory = $true)][string] $ContainerName = $(throw "Requires a name for the Azure Blob Storage container to where the targetted files should be uploaded"),
    [Parameter(Mandatory = $false)][string] $ContainerPermissions = "Off",
    [Parameter(Mandatory = $false)][string] $FilePrefix = ""
)

$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName

#Create the blob container if not yet made
try{
    Write-Verbose "Try using existing Azure Storage Container $ContainerName..."
    Get-AzStorageContainer -Context $storageAccount.Context -Name $ContainerName -ErrorAction Stop
    Write-Host "Using existing Azure Storage Container $ContainerName"
}
catch {
    Write-Host "Creating Azure Storage Container $ContainerName"
    New-AzStorageContainer -Context $storageAccount.Context -Name $ContainerName -Permission $ContainerPermissions
} 

$files = Get-ChildItem $TargetFolderPath -File
Write-Host "Uploading $($files.Length) files from $TargetFolderPath"

foreach($file in $files)
{
    #Read schema name
    $blobFileName = $FilePrefix + $file.Name

    #upload the files to blob storage.
    $content = Set-AzStorageBlobContent -File $file.FullName -Container $ContainerName -Blob $blobFileName -Context $storageAccount.Context -Force
    $blobUri = $content.ICloudBlob.uri.AbsoluteUri
    Write-Host "Uploaded the file to Azure Blob storage: " $($blobUri)
}