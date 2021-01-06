<#
 .Synopsis
  Creates a folder within a Azure File Share.
  
 .Description
  Creates a new folder within the Azure File Share resource.

 .Parameter ResourceGroupName
  The resource group containing the Azure File Share.
  
 .Parameter StorageAccountName
  The Azure Storage account name that is hosting the Azure File Share.

 .Parameter FileShareName
  The name of the Azure File Share.

 .Parameter FolderName
  The name of the folder to create in the Azure File Share.
#>
function Create-AzFileShareStorageFolder {
    param(
        [string][Parameter(Mandatory = $true)] $ResourceGroupName,
        [string][Parameter(Mandatory = $true)] $StorageAccountName,
        [string][Parameter(Mandatory = $true)] $FileShareName,
        [string][Parameter(Mandatory = $true)] $FolderName
    )
    
    . $PSScriptRoot\Scripts\Create-AzFileShareStorageFolder.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -FileShareName $FileShareName -FolderName $FolderName
}

Export-ModuleMember -Function Create-AzFileShareStorageFolder

<#
 .Synopsis
  Upload a series of files at a given folder to a Azure File Share.

 .Description
  Upload a series of files at a given folder, matching an optional file mask, to a Azure File Share.

 .Parameter ResourceGroupName
  The resource group containing the Azure File Share.

 .Parameter FileShareName
  The name of the Azure File Share.

 .Parameter SourceFolderPath
  The file directory where the targetted files are located.

 .Parameter DestinationFolderName
  The name of the destination folder on the Azure File Share where the targetted files will be uploaded.

 .Parameter FileMask
  The file mask that filters out the targetted files at the source folder that will be uploaded to the Azure File Share.
#>
function Copy-AzFileShareStorageFiles {
    param(
        [parameter(Mandatory = $true)][string] $ResourceGroupName,
        [parameter(Mandatory = $true)][string] $StorageAccountName,
        [parameter(Mandatory = $true)][string] $FileShareName,
        [parameter(Mandatory = $true)][string] $SourceFolderPath,
        [parameter(Mandatory = $true)][string] $DestinationFolderName,
        [parameter(Mandatory = $false)][string] $FileMask = ""
    )

    . $PSScriptRoot\Script\Copy-AzFileShareStorageFiles.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -FileShareName $FileShareName -SourceFolderPath $SourceFolderPath -DestinationFolderName $DestinationFolderName -FileMask $FileMask
}