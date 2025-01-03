param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
    [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
    [Parameter(Mandatory = $true)][string] $FileShareName = $(throw "Name of Azure file share is required"),
    [Parameter(Mandatory = $true)][string] $FolderName = $(throw "Name of folder is required")
)

$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$fileShare = Get-AzStorageFile -Context $storageAccount.Context -ShareName $FileShareName
$fileShareFolders = Get-AzStorageFile -ShareName $FileShareName -Context $storageAccount.Context | Where-Object { $_.GetType().Name -eq "AzureStorageFileDirectory" }

if ($FolderName -in $fileShareFolders.Name) {
    Write-Warning "Azure FileShare storage folder '$FolderName' already exists, skipping"
} else {
    Write-Verbose "Creating Azure FileShare storage folder '$FolderName' in file share '$FileShareName'..."
    New-AzStorageDirectory -Context $storageAccount.Context -ShareName $FileShareName -Path $FolderName
    Write-Host "Created Azure FileShare storage folder '$FolderName' in file share '$FileShareName'"
}