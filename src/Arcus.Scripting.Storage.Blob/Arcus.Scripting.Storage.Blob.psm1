<#
 .Synopsis
  Uploads a set of files in a directory to Azure Blob Storage.
 
 .Description
  Uploads a set of files located in a given directory to a container on a Azure Blob Storage resource.

 .Parameter TargetFolderPath
  The directory where the files are located to upload to Azure Blob Storage.

 .Parameter ContainerName
  The name of the container at Azure Blob Storage to upload the targetted files to.

 .Parameter StorageAccountResourceId
  The ID of the Azure storage account resource to authenticate with the Azure Blob Storage.

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
        [string][parameter(Mandatory = $true)] $TargetFolderPath = $(throw "Requires a folder file path to locate the targetted the files to be uploaded to Azure Blob Storage"),
        [string][parameter(Mandatory = $true)] $ContainerName = $(throw "Requires a name for the Azure Blob Storage container to where the targetted files should be uploaded"),
        [string][parameter(Mandatory = $true)] $StorageAccountResourceId = $(throw "Requires a resource ID for the Azure Storage account to authenticate with the Azure Blob Storage resource"),
        [string][parameter(Mandatory = $false)] $ContainerPermissions = "Off",
        [string][parameter(Mandatory = $false)] $FilePrefix = ""
    )

    . $PSScriptRoot\Scripts\Upload-AzFilesToBlobStorage.ps1 -TargetFolderPath $TargetFolderPath -ContainerName $ContainerName -StorageAccountResourceId $StorageResourceId -ContainerPermissions $ContainerPermissions -FilePrefix $FilePrefix
}

Export-ModuleMember -Function Upload-AzFilesToBlobStorage