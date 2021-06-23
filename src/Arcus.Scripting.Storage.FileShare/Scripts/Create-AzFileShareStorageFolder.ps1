param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
    [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
    [Parameter(Mandatory = $true)][string] $FileShareName = $(throw "Name of Azure file share is required"),
    [Parameter(Mandatory = $true)][string] $FolderName = $(throw "Name of folder is required")
)

$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$fileShareFolders =
    Get-AzStorageFile -ShareName $fileShareName -Context $storageAccount.Context | 
        where { $_.GetType().Name -eq "AzureStorageFileDirectory" }

if ($fileShareFolders -contains $FolderName)
{
    Write-Host "Azure FileShare storage folder '$FolderName' already exists, skipping"
}
else
{
    Write-Verbose "Creating Azure FileShare storage folder '$FolderName' in file share '$FileShareName'.."
    Get-AzStorageFile -Context $storageAccount.Context -ShareName $FileShareName |
        New-AzStorageDirectory -Path $FolderName
    Write-Host "Created Azure FileShare storage folder '$FolderName' in file share '$FileShareName'"
}