param(
   [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
   [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
   [Parameter(Mandatory = $true)][string] $TableName = $(throw "Name of Azure table is required"),
   [Parameter()][switch] $Recreate = $false
)

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
        try {
            Write-Verbose "Creating table '$TableName' in the storage account '$StorageAccountName'..."
            New-AzStorageTable -Name $TableName -Context $StorageAccount.Context -ErrorAction Stop
            Write-Host "Table '$TableName' has been created"

            return $true
        } catch {
            Write-Warning "Table '$TableName' failed to be created: $_"
            return $false
        }
    }
}

Write-Host "Retrieving storage account ('$StorageAccountName') context..."
$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
Write-Host "Storage account context has been retrieved."

Write-Host "Checking if the table '$TableName' already exists..."
$tables = Get-AzStorageTable -Context $storageAccount.Context

if ($TableName -in $tables.Name) {
    if ($Recreate) {
        Write-Host "Deleting existing table '$TableName' in the storage account '$StorageAccountName'..."
        Remove-AzStorageTable -Name $TableName -Context $storageAccount.Context
        Write-Host "Table '$TableName' has been removed"
        
        while (-not(Try-CreateTable -StorageAccount $storageAccount -TableName $TableName)) {
            Write-Host "Failed to create the table, retrying in 5 seconds..."
            Start-Sleep -Seconds 5
        }
       
    } else {
        Write-Host "No actions performed, since the specified table ('$TableName') already exists in the storage account ('$StorageAccountName')."
    }
} else {
    Write-Host "Table '$TableName' does not exist yet"
    Try-CreateTable -StorageAccount $storageAccount -TableName $TableName
}

