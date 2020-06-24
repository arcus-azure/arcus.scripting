param(
   [string][parameter(Mandatory = $true)] $ResourceGroup,
   [string][parameter(Mandatory = $true)] $ServiceName,
   [string][parameter(Mandatory = $true)] $ApiId,
   [string][parameter(Mandatory = $true)] $policyFilePath
)

# Retrieve the context of APIM
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroup -ServiceName $ServiceName

# Check if an operationId has been specified, it not - import the base policy
Write-Host "Updating policy of API '$ApiId'"
$result = Set-AzApiManagementPolicy -Context $apimContext -ApiId $ApiId -PolicyFilePath $policyFilePath
if ($result) {
    Write-Host "Successfully updated API policy"
} else {
    Write-Error "Failed to update API policy, please check parameters"
}