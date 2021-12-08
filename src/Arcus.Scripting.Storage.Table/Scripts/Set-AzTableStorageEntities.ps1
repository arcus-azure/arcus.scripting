param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
    [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
    [Parameter(Mandatory = $true)][string] $TableName = $(throw "Name of Azure table is required"),
    [Parameter(Mandatory = $true)][string] $ConfigurationFile = $(throw "Path to the configuration file is required"),
    [Parameter(Mandatory = $false)][int] $RetryIntervalSeconds = 5,
    [Parameter(Mandatory = $false)][int] $MaxRetryCount = 10
)

if ($RetryIntervalSeconds -le 0) {
    throw "Retry interval in seconds should be greater than zero"
}

if ($MaxRetryCount -le 0) {
    throw "Maximum retry-cycle count should be greater than zero"
}

# Retrieve Azure storage Account / table
Write-Host "Retrieving Azure storage account..."
$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$ctx = $storageAccount.Context
Write-Host "Azure storage account has been retrieved"

Write-Verbose "Retrieving Azure table..."
$storageTable = Get-AzStorageTable -Name $TableName  -Context $ctx
$cloudTable = ($storageTable).CloudTable
Write-Host "Azure table has been retrieved"


# Delete all existing entities 
Write-Host "Deleting all existing entities..."
$entitiesToDelete = Get-AzTableRow `
                        -table $cloudTable `

$entitiesToDelete | Remove-AzTableRow -table $cloudTable
Write-Host "Succesfully deleted all entities"


#Create all new entities specified in json file
$configFile = Get-Content -Path $ConfigurationFile | ConvertFrom-Json
foreach ($entityToAdd in $configFile.entities)
{
    #Check if PartitionKey provided
    if($entityToAdd.PartitionKey -ne $null)
    {
        $partitionKey = $entityToAdd.PartitionKey
        $entityToAdd.PSObject.Properties.Remove('PartitionKey')
    }
    else{
        $partitionKey = New-Guid
    }

    #Check if RowKey provided
    if($entityToAdd.RowKey -ne $null)
    {
        $rowKey = $entityToAdd.RowKey
        $entityToAdd.PSObject.Properties.Remove('RowKey')
    }
    else{
        $rowKey = New-Guid
    }

    #Convert psObject to hashtable
    $entityHash=@{}
    $entityToAdd.PSObject.Properties | Foreach { $entityHash[$_.Name] = $_.Value }

    #Create entity in table storage
    Add-AzTableRow `
    -table $cloudTable `
    -partitionKey $partitionKey `
    -rowKey $rowKey `
    -property $entityHash
}

Write-Host "Succesfully added all entities"

