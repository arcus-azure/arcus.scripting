param(
   [string][Parameter(Mandatory = $true)] $ResourceGroup = $(throw "Resource group is required"),
   [string][Parameter(Mandatory = $true)] $ServiceName = $(throw "API management service name is required"),
   [string][Parameter(Mandatory = $true)] $ApiId = $(throw "API ID is required"),
   [string][Parameter(Mandatory = $true)] $OperationId = $(throw "Operation ID is required"),
   [string][Parameter(Mandatory = $true)] $Method = $(throw "Method is required"),
   [string][Parameter(Mandatory = $true)] $UrlTemplate = $(throw "URL template is required"),
   [string][Parameter(Mandatory = $false)] $OperationName = $OperationId,
   [string][Parameter(Mandatory = $false)] $Description = "",
   [string][Parameter(Mandatory = $false)] $PolicyFilePath = ""
)

# Retrieve the context of APIM
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroup -ServiceName $ServiceName

# Create a new operation on the previously created API
New-AzApiManagementOperation -Context $apimContext -ApiId $ApiId -OperationId $OperationId -Name $OperationName -Method $Method -UrlTemplate $UrlTemplate -Description $Description
Write-Host "New API operation '$OperationName' on API Management service was added."

# Check if a policy-file has been specified, if not - the base policy is assigned by default
if($OperationId -eq "" -or $PolicyFilePath -eq "")
{
    Write-Host "No policy has been defined."
}
else
{
    Write-Host "Updating policy of the operation '$OperationId' in API '$ApiId'"
    Set-AzApiManagementPolicy -Context $apimContext -ApiId $ApiId -OperationId $OperationId -PolicyFilePath $PolicyFilePath
}