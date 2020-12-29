param(
    [string][parameter(Mandatory = $true)] $ResourceGroupName = $(throw "Requires a resource group name where the Azure storage account is located"),
    [string][parameter(Mandatory = $true)] $StorageAccountName = $(throw "Requires a name for the Azure sotrage account"),
    [string][parameter(Mandatory = $true)] $TargetFolderPath = $(throw "Requires a folder file path to locate the targetted the files to be uploaded to Azure Blob Storage"),
    [string][parameter(Mandatory = $true)] $ContainerName = $(throw "Requires a name for the Azure Blob Storage container to where the targetted files should be uploaded"),
    [string][parameter(Mandatory = $true)] $StorageAccountResourceId = $(throw "Requires a resource ID for the Azure Storage account to authenticate with the Azure Blob Storage resource"),
    [string][parameter(Mandatory = $false)] $ContainerPermissions = "Off",
    [string][parameter(Mandatory = $false)] $FilePrefix = ""
)

$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName

#Create the blob container if not yet made
try{
    Get-AzStorageContainer -Context $storageAccount.Context -Name $ContainerName -ErrorAction Stop
}
catch{
    Write-Host "Creating Storage Container $ContainerName"
    New-AzStorageContainer -Context $storageAccount.Context -Name $ContainerName -Permission $ContainerPermissions
} 

$files = Get-ChildItem ("$TargetFolderPath") -File
foreach($file in $files)
{
    #Read schema name
    $blobFileName = $FilePrefix + $file.Name

    #upload the files to blob storage.
    $content = Set-AzStorageBlobContent -File $file.FullName -Container $ContainerName -Blob $blobFileName -Context $storageAccount.Context -Force
    $blobUri = $content.ICloudBlob.uri.AbsoluteUri
    Write-Host "Uploaded the file to Blob Storage: " $($blobUri)
}