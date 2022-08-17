param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
    [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "API management service name is required"),
    [Parameter(Mandatory = $true)][string] $CertificateFilePath = $(throw "Full file path to certificate is required"),
    [Parameter(Mandatory = $true)][string] $CertificatePassword = $(throw "Password for certificate is required")
)

$apim = Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName
if ($apim -eq $null) {
    throw "Unable to find the Azure API Management Instance $ServiceName in resource group $ResourceGroupName"
}
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName
Write-Host "Using API Management instance '$ServiceName' in resource group '$ResourceGroupName'"

Write-Verbose "Uploading private certificate at '$CertificateFilePath'..."
New-AzApiManagementCertificate -Context $apimContext -PfxFilePath $CertificateFilePath -PfxPassword $CertificatePassword
Write-Host "Uploaded private certificate at '$CertificateFilePath'"
