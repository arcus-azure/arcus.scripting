param(
   [string][parameter(Mandatory = $true)] $ResourceGroup,
   [string][parameter(Mandatory = $true)] $ServiceName,
   [string][parameter(Mandatory = $true)] $ProductId,
   [string][parameter(Mandatory = $true)] $PolicyFilePath
)

# Retrieve the context of APIM
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroup -ServiceName $ServiceName

# Check if an operationId has been specified, it not - import the base policy
Write-Host "Updating policy of product '$ProductId'"
$result = Set-AzApiManagementPolicy -Context $apimContext -ProductId $ApiId -PolicyFilePath $PolicyFilePath
if ($result) {
    Write-Host "Successfully updated the product policy"
} else {
    Write-Error "Failed to update the product policy"
}