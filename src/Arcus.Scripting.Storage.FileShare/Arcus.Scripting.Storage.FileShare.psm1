<#
 .Synopsis
  Creates a folder within a Azure File Share.
  
 .Description
  Creates a new folder within the Azure File Share resource.

 .Parameter ResourceGroupName
  The resource group containing the Azure File Share.
  
 .Parameter StorageAccountName
  The name of the Azure Storage account that is hosting the Azure File Share.

 .Parameter FileShareName
  The name of the Azure File Share.

 .Parameter FolderName
  The name of the folder to create in the Azure File Share.
#>
function Create-AzFileShareStorageFolder {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
        [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
        [Parameter(Mandatory = $true)][string] $FileShareName = $(throw "Name of Azure file share is required"),
        [Parameter(Mandatory = $true)][string] $FolderName = $(throw "Name of folder is required")
    )
    
    . $PSScriptRoot\Scripts\Create-AzFileShareStorageFolder.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -FileShareName $FileShareName -FolderName $FolderName
}

Export-ModuleMember -Function Create-AzFileShareStorageFolder

<#
 .Synopsis
  Upload a set of files from a given folder to an Azure File Share.

 .Description
  Upload a set of files from a given folder, optionally matching a specific file mask, to an Azure File Share.

 .Parameter ResourceGroupName
  The resource group containing the Azure File Share.

 .Parameter StorageAccountName
  The name of the Azure Storage account that is hosting the Azure File Share.

 .Parameter FileShareName
  The name of the Azure File Share.

 .Parameter SourceFolderPath
  The file directory where the targeted files are located.

 .Parameter DestinationFolderName
  The name of the destination folder on the Azure File Share where the targeted files will be uploaded.

 .Parameter FileMask
  The file mask that filters out the targetted files at the source folder that will be uploaded to the Azure File Share.
#>
function Copy-AzFileShareStorageFiles {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
        [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
        [Parameter(Mandatory = $true)][string] $FileShareName = $(throw "Name of file share is required"),
        [Parameter(Mandatory = $true)][string] $SourceFolderPath = $(throw "Folder path to the source folder is required"),
        [Parameter(Mandatory = $true)][string] $DestinationFolderName = $(throw "Folder name to the destination folder is required"),
        [Parameter(Mandatory = $false)][string] $FileMask = ""
    )

    Write-Warning "Function 'Copy-AzFileShareStorageFile' is deprecated, use the 'Upload-AzFileShareStorageFiles' function instead"
    . $PSScriptRoot\Scripts\Upload-AzFileShareStorageFiles.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -FileShareName $FileShareName -SourceFolderPath $SourceFolderPath -DestinationFolderName $DestinationFolderName -FileMask $FileMask
}

Export-ModuleMember -Function Copy-AzFileShareStorageFiles

<#
 .Synopsis
  Upload a set of files from a given folder to an Azure File Share.

 .Description
  Upload a set of files from a given folder, optionally matching a specific file mask, to an Azure File Share.

 .Parameter ResourceGroupName
  The resource group containing the Azure File Share.

 .Parameter StorageAccountName
  The name of the Azure Storage account that is hosting the Azure File Share.

 .Parameter FileShareName
  The name of the Azure File Share.

 .Parameter SourceFolderPath
  The file directory where the targeted files are located.

 .Parameter DestinationFolderName
  The name of the destination folder on the Azure File Share where the targeted files will be uploaded.

 .Parameter FileMask
  The file mask that filters out the targetted files at the source folder that will be uploaded to the Azure File Share.
#>
function Upload-AzFileShareStorageFiles {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
        [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
        [Parameter(Mandatory = $true)][string] $FileShareName = $(throw "Name of file share is required"),
        [Parameter(Mandatory = $true)][string] $SourceFolderPath = $(throw "Folder path to the source folder is required"),
        [Parameter(Mandatory = $true)][string] $DestinationFolderName = $(throw "Folder name to the destination folder is required"),
        [Parameter(Mandatory = $false)][string] $FileMask = ""
    )

    . $PSScriptRoot\Scripts\Upload-AzFileShareStorageFiles.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -FileShareName $FileShareName -SourceFolderPath $SourceFolderPath -DestinationFolderName $DestinationFolderName -FileMask $FileMask
}

Export-ModuleMember -Function Upload-AzFileShareStorageFiles