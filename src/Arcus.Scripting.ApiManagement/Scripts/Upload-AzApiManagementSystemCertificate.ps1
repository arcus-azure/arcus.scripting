param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group is required"),
    [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "API Management service name is required"),
    [Parameter(Mandatory = $true)][string] $CertificateFilePath = $(throw "Certificate file-path is required"),
    [Parameter(Mandatory = $false)][switch] $AsJob = $false
)

Write-Verbose "Loading public CA certificate '$CertificateFilePath' for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'..."
$rootCA = New-AzApiManagementSystemCertificate -StoreName "Root" -PfxPath $CertificateFilePath
$systemCert = @($rootCa)
Write-Host "Loaded public CA certificate '$CertificateFilePath' for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"

Write-Verbose "Retrieving Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'..."
$apimContext = Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName
if ($null -eq $apimContext) {
    throw "Unable to find the Azure API Management Instance '$ServiceName' in resource group $ResourceGroupName"
}

$systemCertificates = $apimContext.SystemCertificates
$systemCertificates += $systemCert
$apimContext.SystemCertificates = $systemCertificates
Write-Host "Retrieved Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'"

Write-Verbose "Uploading public CA certificate '$CertificateFilePath' for the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'..."
if ($AsJob) {
    Set-AzApiManagement -InputObject $apimContext -PassThru -AsJob
} else {
    Set-AzApiManagement -InputObject $apimContext -PassThru
}
Write-Host "Uploaded public CA certificate '$CertificateFilePath' into the Azure API Management instance '$ServiceName' in resource group '$ResourceGroupName'" -ForegroundColor Green