param(
   [Parameter(Mandatory = $true)][string] $ResourceGroupName,
   [Parameter(Mandatory = $true)][string] $ServiceName,
   [Parameter(Mandatory = $true)][string] $ProductId,
   [Parameter(Mandatory = $true)][string] $PolicyFilePath
)

$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName

Write-Host "Updating policy of product '$ProductId'"
$result = Set-AzApiManagementPolicy -Context $apimContext -ProductId $ProductId -PolicyFilePath $PolicyFilePath
if ($result) {
    Write-Host "Successfully updated the product policy"
} else {
    throw "Failed to update the product policy"
}