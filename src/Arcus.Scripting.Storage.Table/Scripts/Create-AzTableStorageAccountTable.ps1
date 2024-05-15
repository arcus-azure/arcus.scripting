param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of resource group is required"),
    [Parameter(Mandatory = $true)][string] $StorageAccountName = $(throw "Name of Azure storage account is required"),
    [Parameter(Mandatory = $true)][string] $TableName = $(throw "Name of Azure table is required"),
    [Parameter()][switch] $Recreate = $false,
    [Parameter(Mandatory = $false)][int] $RetryIntervalSeconds = 10,
    [Parameter(Mandatory = $false)][int] $MaxRetryCount = 10
)

if ($RetryIntervalSeconds -le 0) {
    throw "Retry interval in seconds should be greater than zero"
}

if ($MaxRetryCount -le 0) {
    throw "Maximum retry-cycle count should be greater than zero"
}

function Try-CreateTable() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object] $StorageAccount,
        [Parameter(Mandatory = $true)][string] $TableName,
        [Parameter(Mandatory = $false)][int] $RetryIndex = 1
    )
    if ($RetryIndex -ge $MaxRetryCount) {
        throw "Azure storage table '$TableName' was not able to be created in Azure storage account, please check your connection information and access permissions"
    }

    try {
        Write-Verbose "Creating Azure storage table '$TableName' in the Azure storage account '$StorageAccountName'..."
        $storageTable = New-AzStorageTable -Name $TableName -Context $StorageAccount.Context -ErrorAction Stop
        Write-Host "Azure storage table '$TableName' created in Azure storage account '$StorageAccountName'" -ForegroundColor Green
        return $true
    } catch {
        return $false
    }
}

Write-Verbose "Retrieving Azure storage account context for Azure storage account '$StorageAccountName' in resource group '$ResourceGroupName'..."
$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
Write-Verbose "Azure storage account context has been retrieved for Azure storage account '$StorageAccountName' in resource group '$ResourceGroupName'"

Write-Verbose "Checking if the Azure storage table '$TableName' already exists in Azure storage account '$StorageAccountName'..."
$tables = Get-AzStorageTable -Context $storageAccount.Context

if ($TableName -in $tables.Name) {
    if ($Recreate) {
        Write-Verbose "Deleting existing Azure storage table '$TableName' in the Azure storage account '$StorageAccountName'..."
        $isRemoved = Remove-AzStorageTable -Name $TableName -Context $storageAccount.Context -Force
        if ($isRemoved -eq $false) {
            throw "Could not successfully remove Azure storage table '$TableName' in the Azure storage account '$StorageAccountName'"
        }
        
        Write-Host "Azure storage table '$TableName' has been removed from Azure storage account '$StorageAccountName'"
        
        $retryIndex = 1
        while (-not (Try-CreateTable -StorageAccount $storageAccount -TableName $TableName -RetryIndex $retryIndex)) {
            Write-Warning "Failed to re-create the Azure storage table '$TableName' in Azure storage account '$StorageAccountName', retrying in 5 seconds..."
            $retryIndex = $retryIndex + 1
            Start-Sleep -Seconds $RetryIntervalSeconds
        }
       
    } else {
        Write-Host "No actions performed, since the specified Azure storage table '$TableName' already exists in the Azure storage account '$StorageAccountName'"
    }
} else {
    Write-Host "Azure storage table '$TableName' does not exist yet in the Azure storage account '$StorageAccountName', so will create one"
    Try-CreateTable -StorageAccount $storageAccount -TableName $TableName
}