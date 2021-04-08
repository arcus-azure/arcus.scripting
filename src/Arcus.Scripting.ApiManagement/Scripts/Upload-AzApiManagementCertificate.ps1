param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
    [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "API management service name is required")),
    [Parameter(Mandatory = $true)][string] $CertificateFilePath = $(throw "Full file path to certificate is required"),
    [Parameter(Mandatory = $true)][string] $CertificatePassword = $(throw "Password for certificate is required")
)

$context = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName
Write-Host "Using API Management instance '$ServiceName' in resource group '$ResourceGroupName'"

Write-Verbose "Uploading private certificate at '$CertificateFilePath'..."
New-AzApiManagementCertificate -Context $context -PfxFilePath $CertificateFilePath -PfxPassword $CertificatePassword
Write-Host "Uploaded private certificate at '$CertificateFilePath'"
