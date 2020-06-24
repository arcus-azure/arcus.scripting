param(
    [string][parameter(Mandatory = $true)] $ResourceGroup,
    [string][parameter(Mandatory = $true)] $ServiceName,
    [string][parameter(Mandatory = $true)] $ApiId,
    [string][parameter(Mandatory = $true)] $OperationId,
    [string][parameter(Mandatory = $true)] $PolicyFilePath
)

$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroup -ServiceName $ServiceName

Write-Host "Updating policy of the operation '$OperationId' in API '$ApiId'"
$result = Set-AzApiManagementPolicy -Context $apimContext -ApiId $ApiId -OperationId $OperationId -PolicyFilePath $PolicyFilePath
if ($result) {
    Write-Host "Successfully updated the operation policy"
} else {
    Write-Error "Failed to update the operation policy, please check parameters"
}
