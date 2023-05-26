param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
    [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
    [Parameter(Mandatory = $true)][string] $TableName = $(throw "Name of Azure table is required"),
    [Parameter(Mandatory = $true)][string] $ConfigurationFile = $(throw "Path to the configuration file is required")
)

if (-not (Test-Path -Path $ConfigurationFile)) {
    throw "Cannot re-create entities based on JSON configuration file because no file was found at: '$ConfigurationFile'"
}

Write-Verbose "Retrieving Azure storage account context for Azure storage account '$StorageAccountName' in resource group '$ResourceGroupName'..."
$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
if ($storageAccount -eq $null) {
    throw "Retrieving Azure storage account context for Azure storage account '$StorageAccountName' in resource group '$ResourceGroupName' failed."
}
$ctx = $storageAccount.Context
Write-Verbose "Azure storage account context has been retrieved for Azure storage account '$StorageAccountName' in resource group '$ResourceGroupName'"

Write-Verbose "Retrieving Azure storage table '$TableName' for Azure storage account '$StorageAccountName' in resource group '$ResourceGroupName'..."
$storageTable = Get-AzStorageTable -Name $TableName -Context $ctx
if ($storageTable -eq $null) {
    throw "Retrieving Azure storage table '$TableName' for Azure storage account '$StorageAccountName' in resource group '$ResourceGroupName' failed."
}
$cloudTable = ($storageTable).CloudTable
Write-Verbose "Azure storage table '$TableName' has been retrieved for Azure storage account '$StorageAccountName' in resource group '$ResourceGroupName'"

Write-Host "Deleting all existing entities in Azure storage table '$TableName' for Azure storage account '$StorageAccountName' in resource group '$ResourceGroupName'..."
$entitiesToDelete = Get-AzTableRow -table $cloudTable
$deletedEntities = $entitiesToDelete | Remove-AzTableRow -table $cloudTable
Write-Host "Successfully deleted all existing entities in Azure storage table '$TableName' for Azure storage account '$StorageAccountName' in resource group '$ResourceGroupName'"

$configFile = Get-Content -Path $ConfigurationFile | ConvertFrom-Json
foreach ($entityToAdd in $configFile) {
    if ($entityToAdd.PartitionKey) {
        $partitionKey = $entityToAdd.PartitionKey
        $entityToAdd.PSObject.Properties.Remove('PartitionKey')
    } else {
        $partitionKey = New-Guid
    }

    if ($entityToAdd.RowKey) {
        $rowKey = $entityToAdd.RowKey
        $entityToAdd.PSObject.Properties.Remove('RowKey')
    } else {
        $rowKey = New-Guid
    }

    $entityHash = @{}
    $entityToAdd.PSObject.Properties | foreach { $entityHash[$_.Name] = $_.Value }

    $addedRow = Add-AzTableRow `
    -table $cloudTable `
    -partitionKey $partitionKey `
    -rowKey $rowKey `
    -property $entityHash

    Write-Verbose "Successfully added row with PartitionKey '$partitionKey' and RowKey '$rowKey' to Azure storage table '$TableName' for Azure storage account '$StorageAccountName' in resource group '$ResourceGroupName'"
}

Write-Host "Successfully added all entities in Azure storage table '$TableName' for Azure storage account '$StorageAccountName' in resource group '$ResourceGroupName'"