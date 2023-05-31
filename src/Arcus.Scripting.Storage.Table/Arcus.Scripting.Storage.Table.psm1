<#
 .Synopsis
  Create a Azure Table Storage within an Azure Storage Account.
 
 .Description
  (Re)Create a Azure Table Storage within an Azure Storage Account.

 .Parameter ResourceGroupName
  The resource group where the Azure Storage Account is located.

 .Parameter StorageAccountName
  The name of the Azure Storage Account to add the table to.

 .Parameter TableName
  The name of the table to add on the Azure Storage Account.

 .Parameter Recreate
  The optional flag to indicate whether or not a possible already existing table should be deleted and re-created.

 .Parameter RetryIntervalSeconds
  The optional amount of seconds to wait each retry-run when a failure occures during the re-creating process.

 .Parameter MaxRetryCount
  The optional maximum amount of retry-runs should happen when a failure occurs during the re-creating process.
#>
function Create-AzStorageTable {
    param(
       [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
       [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
       [Parameter(Mandatory = $true)][string] $TableName = $(throw "Name of Azure table is required"),
       [Parameter()][switch] $Recreate = $false,
       [Parameter(Mandatory = $false)][int] $RetryIntervalSeconds = 5,
       [Parameter(Mandatory = $false)][int] $MaxRetryCount = 10
    )

    if ($Recreate) {
        . $PSScriptRoot\Scripts\Create-AzTableStorageAccountTable.ps1 `
            -ResourceGroupName $ResourceGroupName `
            -StorageAccountName $StorageAccountName `
            -TableName $TableName `
            -Recreate `
            -RetryIntervalSeconds $RetryIntervalSeconds `
            -MaxRetryCount $MaxRetryCount
    } else {
        . $PSScriptRoot\Scripts\Create-AzTableStorageAccountTable.ps1 `
            -ResourceGroupName $ResourceGroupName `
            -StorageAccountName $StorageAccountName `
            -TableName $TableName `
            -RetryIntervalSeconds $RetryIntervalSeconds `
            -MaxRetryCount $MaxRetryCount
    }
}

Export-ModuleMember -Function Create-AzStorageTable



<#
 .Synopsis
  Sets the entities in a specified table storage.
  
 .Description
  Sets (Delete & Add) the entities in a specified table storage to the values specified in a (JSON) configuration file.

  .Parameter ResourceGroupName
  The resource group where the Azure Storage Account is located.

 .Parameter StorageAccountName
  The name of the Azure Storage Account which holds the Azure table storage.

 .Parameter TableName
  The name of the table on the Azure Storage Account.

 .Parameter ConfigurationFile
  The Configuration File (JSON) specifying the entities that have to be set in the table storage. The JSON file has a single property "entities" which is an array of objects.

 .Parameter RetryIntervalSeconds
  The optional amount of seconds to wait each retry-run when a failure occures during the re-creating process.

 .Parameter MaxRetryCount
  The optional maximum amount of retry-runs should happen when a failure occurs during the re-creating process.
#>
function Set-AzTableStorageEntities {
    param(
       [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
       [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
       [Parameter(Mandatory = $true)][string] $TableName = $(throw "Name of Azure table is required"),
       [Parameter(Mandatory = $true)][string] $ConfigurationFile = $(throw "Path to the configuration file is required")
    )
   
    . $PSScriptRoot\Scripts\Set-AzTableStorageEntities.ps1 `
        -ResourceGroupName $ResourceGroupName `
        -StorageAccountName $StorageAccountName `
        -TableName $TableName `
        -ConfigurationFile $ConfigurationFile
}

Export-ModuleMember -Function Set-AzTableStorageEntities