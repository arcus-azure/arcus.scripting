param
(
    [Parameter(Mandatory)]
    [String]$ResourceGroupName,

    [Parameter(Mandatory)]
    [String]$StorageAccountName,

    [Parameter(Mandatory)]
    [String]$FileShareName,

    [Parameter(Mandatory)]
    [String]$FolderName
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
