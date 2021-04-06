param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
    [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
    [Parameter(Mandatory = $true)][string] $FileShareName = $(throw "Name of Azure file share is required"),
    [Parameter(Mandatory = $true)][string] $FolderName = $(throw "Name of folder is required")
)

try{
    Write-Host "Creating '$FolderName' directory in file share.."

    ## Get the storage account context  
    $ctx = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context  

    ## Create directory  
    Get-AzStorageShare -Context $ctx -Name $FileShareName | New-AzStorageDirectory -Path $FolderName -ErrorAction Stop

    Write-Host "Directory '$FolderName' has been created.."  
}
catch [Microsoft.Azure.Storage.StorageException]
{
    if($Error[0].Exception.Message -like "*already exists*")
    {
        Write-Host "The specified folder already exists."
    }
    else
    {
        throw
    }
}
catch
{
    $ErrorMessage = $_.Exception.Message
    Write-Error "Failed to create the directory '$FolderName' in file-share '$FileShareName'. Reason: $ErrorMessage"
    return $null
}
