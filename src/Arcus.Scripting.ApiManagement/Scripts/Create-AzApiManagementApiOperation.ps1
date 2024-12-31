param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group is required"),
    [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "API management service name is required"),
    [Parameter(Mandatory = $true)][string] $ApiId = $(throw "API ID is required"),
    [Parameter(Mandatory = $true)][string] $OperationId = $(throw "Operation ID is required"),
    [Parameter(Mandatory = $true)][string] $Method = $(throw "Method is required"),
    [Parameter(Mandatory = $true)][string] $UrlTemplate = $(throw "URL template is required"),
    [Parameter(Mandatory = $false)][string] $OperationName = $OperationId,
    [Parameter(Mandatory = $false)][string] $Description = "",
    [Parameter(Mandatory = $false)][string] $PolicyFilePath = ""
)

$apim = Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName
if ($null -eq $apim) {
    throw "Unable to find the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
}
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName

New-AzApiManagementOperation -Context $apimContext -ApiId $ApiId -OperationId $OperationId -Name $OperationName -Method $Method -UrlTemplate $UrlTemplate -Description $Description
Write-Host "New API operation '$OperationName' was added on Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"

if ($OperationId -eq "" -or $PolicyFilePath -eq "") {
    Write-Warning "No policy has been defined for Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"
} else {
    Write-Verbose "Updating policy of the operation '$OperationId' in API '$ApiId' of the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'..."
    Set-AzApiManagementPolicy -Context $apimContext -ApiId $ApiId -OperationId $OperationId -PolicyFilePath $PolicyFilePath
    Write-Host "Updated policy of the operation '$OperationId' in API '$ApiId' of the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'" -ForegroundColor Green
}