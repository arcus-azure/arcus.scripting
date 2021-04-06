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
#>
function Create-AzStorageTable {
    param(
       [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
       [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
       [Parameter(Mandatory = $true)][string] $TableName = $(throw "Name of Azure table is required"),
       [Parameter()][switch] $Recreate = $false
    )

    if ($Recreate) {
        . $PSScriptRoot\Scripts\Create-AzTableStorageAccountTable.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -TableName $TableName -Recreate
    } else {
        . $PSScriptRoot\Scripts\Create-AzTableStorageAccountTable.ps1 -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -TableName $TableName
    }
}

Export-ModuleMember -Function Create-AzStorageTable