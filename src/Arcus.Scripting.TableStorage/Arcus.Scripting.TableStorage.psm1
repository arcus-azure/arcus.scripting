<#
 .Synopsis
  Create a Azure Table Storage based to an Storage Account.
 
 .Description
  (Re)Create a Azure Table Storage based to an Storage Account.

 .Parameter ResourceGroupName
  The resource group where the Table Storage is located.

 .Parameter StorageAccountName
  The name of the Storage Account to add the table to.

 .Parameter TableName
  The name of the table to add on the Storage Account.

 .Parameter DeleteAndCreate
  The optional flag to indicate whether or not a possible already existing table should be deleted and re-created.
#>
function Create-AzTableStorageAccountTable {
	param(
		[string][parameter(Mandatory = $true)] $ResourceGroup = $(throw "Resource group is required"),
		[string][parameter(Mandatory = $true)] $StorageAccountName = $(throw "Storage account name is required"),
		[string][parameter(Mandatory = $true)] $TableName = $(throw = "Table Storage name is required"),
		[switch][parameter()] $DeleteAndCreate = $false
	)

	. $PSScriptRoot\Scripts\Create-AzTableStorageAccountTable.ps1 -ResourceGroup $ResourceGroup -StorageAccountName $StorageAccountName -TableName $TableName -DeleteAndCreate $DeleteAndCreate
}