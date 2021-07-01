param(
   [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
   [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
   [Parameter(Mandatory = $true)][string] $TableName = $(throw "Name of Azure table is required"),
   [Parameter()][switch] $Recreate = $false
)

function Try-CreateTable() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][object] $StorageAccount,
        [Parameter(Mandatory = $true)][string] $TableName,
        [Parameter(Mandatory = $true)][int] $RetryIndex = 1
    )
     if ($RetryIndex -ge 3) {
         Write-Warning "Azure storage table '$TableName' was not able to be created in Azure storage account '$StorageAccountName', please check your connection information and access permissions"
         return $true
     }

     try {
         Write-Verbose "Creating Azure storage table '$TableName' in the Azure storage account '$StorageAccountName'..."
         New-AzStorageTable -Name $TableName -Context $StorageAccount.Context
         Write-Host "Azure storage table '$TableName' has been created"

         return $true
     } catch {
         Write-Warning "Azure storage table '$TableName' failed to be created: $_"
         return $false
     }
}

Write-Verbose "Retrieving Azure storage account '$StorageAccountName' context..."
$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
Write-Host "Azure storage account context has been retrieved"

Write-Verbose "Checking if the Azure storage table '$TableName' already exists..."
$tables = Get-AzStorageTable -Context $storageAccount.Context

if ($TableName -in $tables.Name) {
    if ($Recreate) {
        Write-Verbose "Deleting existing Azure storage table '$TableName' in the Azure storage account '$StorageAccountName'..."
        Remove-AzStorageTable -Name $TableName -Context $storageAccount.Context -Force
        Write-Host "Table '$TableName' has been removed"
        
        $retryIndex = 1
        while (-not(Try-CreateTable -StorageAccount $storageAccount -TableName $TableName -RetryIndex $retryIndex)) {
            Write-Warning "Failed to create the Azure storage table, retrying in 5 seconds..."
            $retryIndex = $retryIndex + 1
            Start-Sleep -Seconds 5
        }
       
    } else {
        Write-Host "No actions performed, since the specified Azure storage table '$TableName' already exists in the Azure storage account '$StorageAccountName'"
    }
} else {
    Write-Host "Azure storage table '$TableName' does not exist yet in the Azure storage account '$StorageAccountName'"
    Try-CreateTable -StorageAccount $storageAccount -TableName $TableName
}

