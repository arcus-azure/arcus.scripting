param(
   [Parameter(Mandatory = $true)][string] $ResourceGroupName,
   [Parameter(Mandatory = $true)][string] $ServiceName,
   [Parameter(Mandatory = $true)][string] $ApiId,
   [Parameter(Mandatory = $true)][string] $policyFilePath
)

$apim = Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName
if ($apim -eq $null) {
    throw "Unable to find the Azure API Management Instance $ServiceName in resource group $ResourceGroupName"
}
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName

Write-Host "Updating policy of API '$ApiId'"
$result = Set-AzApiManagementPolicy -Context $apimContext -ApiId $ApiId -PolicyFilePath $policyFilePath
if ($result) {
    Write-Host "Successfully updated API policy"
} else {
    throw "Failed to update API policy, please check parameters"
}