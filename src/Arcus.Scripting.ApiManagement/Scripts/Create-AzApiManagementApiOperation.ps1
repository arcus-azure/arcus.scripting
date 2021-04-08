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

$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName

New-AzApiManagementOperation -Context $apimContext -ApiId $ApiId -OperationId $OperationId -Name $OperationName -Method $Method -UrlTemplate $UrlTemplate -Description $Description
Write-Host "New API operation '$OperationName' on API Management instance was added."

if($OperationId -eq "" -or $PolicyFilePath -eq "")
{
    Write-Host "No policy has been defined."
}
else
{
    Write-Host "Updating policy of the operation '$OperationId' in API '$ApiId'"
    Set-AzApiManagementPolicy -Context $apimContext -ApiId $ApiId -OperationId $OperationId -PolicyFilePath $PolicyFilePath
}