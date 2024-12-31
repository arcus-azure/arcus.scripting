param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName,
    [Parameter(Mandatory = $true)][string] $ServiceName,
    [Parameter(Mandatory = $true)][string] $ApiId,
    [Parameter(Mandatory = $true)][string] $OperationId,
    [Parameter(Mandatory = $true)][string] $PolicyFilePath
)

$apim = Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName
if ($null -eq $apim) {
    throw "Unable to find the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
}
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName

Write-Verbose "Updating policy of the operation '$OperationId' in API '$ApiId' for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
$result = Set-AzApiManagementPolicy -Context $apimContext -ApiId $ApiId -OperationId $OperationId -PolicyFilePath $PolicyFilePath -PassThru
if ($result) {
    Write-Host "Successfully updated the operation policy for the Azure API Management instance $ServiceName in resource group $ResourceGroupName" -ForegroundColor Green
} else {
    throw "Failed to update the operation policy for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName', please check parameters"
}
