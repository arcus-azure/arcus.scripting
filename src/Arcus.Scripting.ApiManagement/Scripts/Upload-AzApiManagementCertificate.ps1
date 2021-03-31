param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName,
    [Parameter(Mandatory = $true)][string] $ServiceName,
    [Parameter(Mandatory = $true)][string] $CertificateFilePath,
    [Parameter(Mandatory = $true)][string] $CertificatePassword
)

$context = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName
Write-Host "Using API Management instance '$ServiceName' in resource group '$ResourceGroupName'"

Write-Verbose "Uploading private certificate at '$CertificateFilePath'..."
New-AzApiManagementCertificate -Context $context -PfxFilePath $CertificateFilePath -PfxPassword $CertificatePassword
Write-Host "Uploaded private certificate at '$CertificateFilePath'"