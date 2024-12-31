param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName,
    [Parameter(Mandatory = $true)][string] $ServiceName,
    [Parameter(Mandatory = $true)][string] $ProductId,
    [Parameter(Mandatory = $true)][string] $PolicyFilePath
)

$apim = Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName
if ($null -eq $apim) {
    throw "Unable to find the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
}
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName

Write-Verbose "Updating policy of product '$ProductId' for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
$result = Set-AzApiManagementPolicy -Context $apimContext -ProductId $ProductId -PolicyFilePath $PolicyFilePath -PassThru
if ($result) {
    Write-Host "Successfully updated the product policy for the Azure API Management instance $ServiceName in resource group $ResourceGroupName" -ForegroundColor Green
} else {
    throw "Failed to update the product policy for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
}