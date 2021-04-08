<#
 .Synopsis
  Uploads a set of files in a directory to Azure Blob Storage.
 
 .Description
  Uploads a set of files located in a given directory to a container on a Azure Blob Storage resource.

 .Parameter ResourceGroupName
  The name of the Azure resource group where the Azure storage account is located.

 .Parameter StorageAccountName
  The name of the Azure storage account.

 .Parameter TargetFolderPath
  The directory where the files are located to upload to Azure Blob Storage.

 .Parameter ContainerName
  The name of the container at Azure Blob Storage to upload the targetted files to.

 .Parameter ContainerPermissions
  The level of public access to this container. By default, the container and any blobs in it can be accessed only by the owner of the storage account. 
  To grant anonymous users read permissions to a container and its blobs, you can set the container permissions to enable public access. 
  Anonymous users can read blobs in a publicly available container without authenticating the request. The acceptable values for this parameter are:

  Container: Provides full read access to a container and its blobs. Clients can enumerate blobs in the container through anonymous request, but cannot enumerate containers in the storage account.
  Blob: Provides read access to blob data throughout a container through anonymous request, but does not provide access to container data. Clients cannot enumerate blobs in the container by using anonymous request.
  Off: Which restricts access to only the storage account owner.

 .Parameter FilePrefix
  The optional prefix to append to the blob content when uploading the file in the targetted directory to Azure Blob Storage.
#>
function Upload-AzFilesToBlobStorage {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Requires a resource group name where the Azure storage account is located"),
        [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Requires a name for the Azure sotrage account"),
        [Parameter(Mandatory = $true)][string] $TargetFolderPath = $(throw "Requires a folder file path to locate the targetted the files to be uploaded to Azure Blob Storage"),
        [Parameter(Mandatory = $true)][string] $ContainerName = $(throw "Requires a name for the Azure Blob Storage container to where the targetted files should be uploaded"),
        [Parameter(Mandatory = $false)][string] $ContainerPermissions = "Off",
        [Parameter(Mandatory = $false)][string] $FilePrefix = ""
    )

    . $PSScriptRoot\Scripts\Upload-AzFilesToBlobStorage.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -TargetFolderPath $TargetFolderPath -ContainerName $ContainerName -ContainerPermissions $ContainerPermissions -FilePrefix $FilePrefix
}

Export-ModuleMember -Function Upload-AzFilesToBlobStorage