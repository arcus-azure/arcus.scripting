param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName,
    [Parameter(Mandatory = $true)][string] $ServiceName,
    [Parameter(Mandatory = $true)][string] $ApiId,
    [Parameter(Mandatory = $true)][string] $OperationId,
    [Parameter(Mandatory = $true)][string] $PolicyFilePath
)

$apim = Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName
if ($apim -eq $null) {
    throw "Unable to find the Azure API Management Instance $ServiceName in resource group $ResourceGroupName"
}
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName

Write-Host "Updating policy of the operation '$OperationId' in API '$ApiId'"
$result = Set-AzApiManagementPolicy -Context $apimContext -ApiId $ApiId -OperationId $OperationId -PolicyFilePath $PolicyFilePath
if ($result) {
    Write-Host "Successfully updated the operation policy"
} else {
    throw "Failed to update the operation policy, please check parameters"
}
