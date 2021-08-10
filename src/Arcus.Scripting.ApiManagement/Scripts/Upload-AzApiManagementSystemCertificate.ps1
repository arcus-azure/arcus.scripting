param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group is required"),
    [Parameter(Mandatory = $true)][string] $ServiceName = $(throw "API Management service name is required"),
    [Parameter(Mandatory = $true)][string] $CertificateFilePath = $(throw "Certificate file-path is required"),
    [Parameter(Mandatory = $false)][switch] $AsJob = $false
)

Write-Verbose "Loading public CA certificate '$CertificateFilePath'..."
$rootCA = New-AzApiManagementSystemCertificate -StoreName "Root" -PfxPath $CertificateFilePath
$systemCert = @($rootCa)
Write-Host "Loaded public CA certificate '$CertificateFilePath'"

Write-Verbose "Retrieving Azure API Management service '$ServiceName' instance..."
$apimContext = Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $ServiceName
if ($apimContext -eq $null) {
    throw "Unable to find the Azure API Management Instance '$ServiceName' in resource group $ResourceGroupName"
}

$systemCertificates = $apimContext.SystemCertificates
$systemCertificates += $systemCert
$apimContext.SystemCertificates = $systemCertificates
Write-Host "Retrieved Azure API Management service '$ServiceName' instance"

Write-Verbose "Uploading Azure API Management '$ServiceName' public CA certificate '$CertificateFilePath'..."
if ($AsJob) {
    Set-AzApiManagement -InputObject $apimContext -PassThru -AsJob
} else {
    Set-AzApiManagement -InputObject $apimContext -PassThru
}
Write-Host "Uploaded public CA certificate '$CertificateFilePath' into Azure API Management '$ServiceName'"