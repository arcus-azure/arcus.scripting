<#
 .Synopsis
  Creates a folder within a Azure File Share.
  
 .Description
  Creates a new folder within the Azure Store File Share resource.

 .Parameter ResourceGroupName
  The resource group containing the Azure File Share.
  
 .Parameter StorageAccountName
  The Azure Storage account name that has access to the Azure File Share.

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
        [string][Parameter(Mandatory = $true)] $FolderName,
    )
    
    . $PSScriptRoot\Scripts\Create-AzFileShareStorageFolder.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -FileShareName $FileShareName -FolderName $FolderName
}

Export-ModuleMember -Function Create-AzFileShareStorageFolder
