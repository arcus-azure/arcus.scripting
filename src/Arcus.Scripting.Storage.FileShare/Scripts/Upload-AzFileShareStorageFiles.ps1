param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
    [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
    [Parameter(Mandatory = $true)][string] $FileShareName = $(throw "Name of file share is required"),
    [Parameter(Mandatory = $true)][string] $SourceFolderPath = $(throw "Folder path to the source folder is required"),
    [Parameter(Mandatory = $true)][string] $DestinationFolderName = $(throw "Folder name to the destination folder is required"),
    [Parameter(Mandatory = $false)][string] $FileMask = ""
)

function VerifyAzureFileShareExists {
    try {
        $fileShare = Get-AzStorageShare -Context $context -Name $FileShareName -ErrorAction Stop 
        return $true
    } catch [Microsoft.Azure.Storage.StorageException] {
        if ($Error[0].Exception.Message -like "*does not exist*") {
            Write-Warning "No files can be uploaded because no Azure file-share '$FileShareName' seem to exist in Azure storage account '$StorageAccountName' in resource group '$ResourceGroupName'"
            return $false
        } else {
            throw
        }
    }
}

$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$context = $storageAccount.Context

Write-Verbose "Upload files to Azure FileShare storage '$FileShareName' in resource group '$ResourceGroupName'..."

if (VerifyAzureFileShareExists) {
    foreach ($file in Get-ChildItem ("$SourceFolderPath") -File) {
        try {
            if ($file.Name.EndsWith($FileMask, "CurrentCultureIgnoreCase")) {
                Set-AzStorageFileContent -Context $context -ShareName $FileShareName -Source $file.FullName -Path $DestinationFolderName -Force 
                Write-Host "Uploaded the '$($file.Name)' file to Azure FileShare '$FileShareName'" -ForegroundColor Green
            }
        } catch {
            $ErrorMessage = $_.Exception.Message
            Write-Error "Failed to upload files to directory '$DestinationFolderName' in file-share '$FileShareName'. Reason: $ErrorMessage"
        }
        
    }

    Write-Host "Files have been uploaded to Azure FileShare storage '$FileShareName' in resource group '$ResourceGroupName'"
}