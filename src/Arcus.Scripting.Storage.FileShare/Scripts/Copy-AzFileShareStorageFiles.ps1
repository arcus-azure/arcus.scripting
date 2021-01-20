param(
    [parameter(Mandatory = $true)][string] $ResourceGroupName,
    [parameter(Mandatory = $true)][string] $StorageAccountName,
    [parameter(Mandatory = $true)][string] $FileShareName,
    [parameter(Mandatory = $true)][string] $SourceFolderPath,
    [parameter(Mandatory = $true)][string] $DestinationFolderName,
    [parameter(Mandatory = $false)][string] $FileMask = ""
)

function VerifyAzureFileShareExists 
{
    try
    {
        $fileShare = Get-AzStorageShare -Context $context -Name $FileShareName -ErrorAction Stop 
        return $true
    }
    catch [Microsoft.Azure.Storage.StorageException]
    {
        if($Error[0].Exception.Message -like "*does not exist*")
        {
            Write-Host "The given file-share '$FileShareName' does not seem to exist in storage account '$StorageAccountName'."
            Write-Error "The given file-share '$FileShareName' does not seem to exist in storage account '$StorageAccountName'."
            return $false
        }
        else
        {
            throw
        }
    }
}

try
{
    Write-Host "Upload files to file share..."
    
    ## Get the storage account context  
    $context = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context  
    
    ## Get the file share  
    if(VerifyAzureFileShareExists)
    {
        ## Loop all files in the source-folder
        foreach($file in Get-ChildItem ("$SourceFolderPath") -File)
        {
            ## Does the file match the FileMask
            if($file.Name.EndsWith($FileMask,"CurrentCultureIgnoreCase"))
            {
                ## Upload the file  
                Set-AzStorageFileContent -Context $context -ShareName $FileShareName -Source $file.FullName -Path $DestinationFolderName -Force 
                $fileName = $file.Name
                Write-Host "Uploaded the file to File Share: $fileName"
            }
        }

        Write-Host "Files have been uploaded" 
    }
}
catch
{
    $ErrorMessage = $_.Exception.Message
    Write-Error "Failed to upload files to directory '$DestinationFolderName' in file-share '$FileShareName'. Reason: $ErrorMessage"
    return $null
}