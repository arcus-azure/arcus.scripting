param(
   [string][parameter(Mandatory = $true)] $ResourceGroup,
   [string][parameter(Mandatory = $true)] $StorageAccountName,
   [string][parameter(Mandatory = $true)] $TableName,
   [switch][parameter()] $DeleteAndCreate = $false
)

function Create-StorageAccountTable()
{
    [CmdletBinding()]
    param
    (
       [string][parameter(Mandatory = $true)] $ResourceGroup,
       [string][parameter(Mandatory = $true)] $StorageAccountName,
       [string][parameter(Mandatory = $true)] $TableName,
       [bool][parameter()] $DeleteAndCreate = $false
    )
    BEGIN
    {
        #Retrieve the storage account to which the table should be added
        Write-Host "Retrieving storage account ('$StorageAccountName') context..."
        $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $StorageAccountName
        Write-Host "Storage account context has been retrieved."
        
        #Check if the table already exists
        Write-Host "Checking if the table '$TableName' already exists..."
        $table = Get-AzStorageTable -Name $TableName -Context $storageAccount.Context -ErrorAction Ignore

        if($table)
        {
            #Table already exists
            if($DeleteAndCreate)
            {
                #Delete the table before re-creating
                Write-Host "Deleting existing table '$TableName' in the storage account '$StorageAccountName'..."
                Remove-AzStorageTable -Name $TableName -Context $storageAccount.Context
                Write-Host "Table '$TableName' has been removed"
                
                while(-not(Try-CreateTable -StorageAccount $storageAccount -TableName $TableName))
                {
                    Write-Host "Failed to create the table, retrying in 5 seconds..."
                    Start-Sleep -Seconds 5
                }
               
            }
            else
            {
                Write-Host "No actions performed, since the specified table ('$TableName') already exists in the storage account ('$StorageAccountName')."
            }
        }
        else
        {
            #Table does not exist
            Try-CreateTable -StorageAccount $storageAccount -TableName $TableName
        }
    }
}

function Try-CreateTable()
{
    [CmdletBinding()]
    param
    (
        [object][parameter(Mandatory = $true)] $StorageAccount,
        [string][parameter(Mandatory = $true)] $TableName
    )
    BEGIN
    {
        try
        {
            Write-Host "Creating table '$TableName' in the storage account '$StorageAccountName'..."
            New-AzStorageTable -Name $TableName -Context $StorageAccount.Context -ErrorAction Stop
            Write-Host "Table '$TableName' has been created"

            return $true
        }
        catch
        {
            return $false
        }
    }
}

Create-StorageAccountTable -ResourceGroup $ResourceGroup -StorageAccountName $StorageAccountName -TableName $TableName -DeleteAndCreate $DeleteAndCreate