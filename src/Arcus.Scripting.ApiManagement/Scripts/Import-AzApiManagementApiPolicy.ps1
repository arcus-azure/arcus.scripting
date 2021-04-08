param(
   [Parameter(Mandatory = $true)][string] $ResourceGroupName,
   [Parameter(Mandatory = $true)][string] $ServiceName,
   [Parameter(Mandatory = $true)][string] $ApiId,
   [Parameter(Mandatory = $true)][string] $policyFilePath
)

$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName

Write-Host "Updating policy of API '$ApiId'"
$result = Set-AzApiManagementPolicy -Context $apimContext -ApiId $ApiId -PolicyFilePath $policyFilePath
if ($result) {
    Write-Host "Successfully updated API policy"
} else {
    Write-Error "Failed to update API policy, please check parameters"
}