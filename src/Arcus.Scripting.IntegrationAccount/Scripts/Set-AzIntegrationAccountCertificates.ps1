param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
    [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the Integration Account is required"),
    [Parameter(Mandatory = $true)][string] $CertificateType = $(throw "Certificate type is required, this can be either 'Public' or 'Private'"),
    [parameter(Mandatory = $false)][string] $CertificateFilePath = $(if ($CertificatesFolder -eq '') { throw "Either the file path of a specific certificate or the file path of a folder containing multiple certificates is required, e.g.: -CertificateFilePath 'C:\Certificates\certificate.cer' or -CertificatesFolder 'C:\Certificates'" }),
    [parameter(Mandatory = $false)][string] $CertificatesFolder = $(if ($CertificateFilePath -eq '') { throw "Either the file path of a specific certificate or the file path of a folder containing multiple certificates is required, e.g.: -CertificateFilePath 'C:\Certificates\certificate.cer' or -CertificatesFolder 'C:\Certificates'" }),
    [Parameter(Mandatory = $false)][string] $KeyName = $(if ($CertificateType -eq 'Private') { throw "If the CertificateType is set to 'Private', the KeyName must be supplied" }),
    [Parameter(Mandatory = $false)][string] $KeyVersion = $(if ($CertificateType -eq 'Private') { throw "If the CertificateType is set to 'Private', the KeyVersion must be supplied" }),
    [Parameter(Mandatory = $false)][string] $KeyVaultId = $(if ($CertificateType -eq 'Private') { throw "If the CertificateType is set to 'Private', the KeyVaultId must be supplied" }),
    [Parameter(Mandatory = $false)][string] $ArtifactsPrefix = ''
)

if ($CertificateFilePath -ne '' -and $CertificatesFolder -ne '') {
    throw "Either the file path of a specific certificate or the file path of a folder containing multiple certificates is required, e.g.: -CertificateFilePath 'C:\Certificates\certificate.cer' or -CertificatesFolder 'C:\Certificates'"
}

if ($CertificateType -ne 'Public' -and $CertificateType -ne 'Private') {
    throw "The CertificateType should be either 'Public' or 'Private'"
}

if ($CertificateType -eq 'Private' -and $CertificatesFolder -ne '' -and $CertificateFilePath -eq '') {
    throw "Using the CertificatesFolder parameter in combination with Private certificates is not possible, since this would upload multiple certificates using the same Key in Azure KeyVault"
}

function UploadCertificate {
    param(
        [Parameter(Mandatory = $true)][System.IO.FileInfo] $Certificate
    )

    $certificateName = $Certificate.BaseName
    if ($ArtifactsPrefix -ne '') {
        $certificateName = $ArtifactsPrefix + $certificateName
    }
    Write-Host "Uploading certificate '$certificateName' into the Azure Integration Account '$Name'..."

    $existingCertificate = $null
    try {
        Write-Verbose "Checking if the certificate '$certificateName' already exists in the Azure Integration Account '$Name'..."
        $existingCertificate = Get-AzIntegrationAccountCertificate -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -CertificateName $certificateName -ErrorAction Stop
    } catch {
        if ($_.Exception.Message.Contains('could not be found')) {
            Write-Warning "No certificate '$certificateName' could not be found in Azure Integration Account '$Name'"
        } else {
            throw $_.Exception
        }
    }
        
    try {
        if ($null -eq $existingCertificate) {
            Write-Verbose "Creating certificate '$certificateName' in Azure Integration Account '$Name'..."
            if ($CertificateType -eq 'Public') {
                $createdCertificate = New-AzIntegrationAccountCertificate -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -CertificateName $certificateName -PublicCertificateFilePath $Certificate.FullName -ErrorAction Stop
            } else {
                $createdCertificate = New-AzIntegrationAccountCertificate -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -CertificateName $certificateName -PublicCertificateFilePath $Certificate.FullName -KeyName $KeyName -KeyVersion $KeyVersion -KeyVaultId $KeyVaultId -ErrorAction Stop
            }
            Write-Debug ($createdCertificate | Format-List -Force | Out-String)
        } else {
            Write-Verbose "Updating certificate '$certificateName' in Azure Integration Account '$Name'..."
            if ($CertificateType -eq 'Public') {
                $updatedCertificate = Set-AzIntegrationAccountCertificate -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -CertificateName $certificateName -PublicCertificateFilePath $Certificate.FullName -Force -ErrorAction Stop
            } else {
                $updatedCertificate = Set-AzIntegrationAccountCertificate -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -CertificateName $certificateName -PublicCertificateFilePath $Certificate.FullName -KeyName $KeyName -KeyVersion $KeyVersion -KeyVaultId $KeyVaultId -Force -ErrorAction Stop
            }
            Write-Debug ($updatedCertificate | Format-List -Force | Out-String)
        }
        Write-Host "Certificate '$certificateName' has been uploaded into the Azure Integration Account '$Name'" -ForegroundColor Green
    } catch {
        Write-Error "Failed to upload certificate '$certificateName' in Azure Integration Account '$Name'. Details: '$($_.Exception.Message)'"
    }
}

$integrationAccount = Get-AzIntegrationAccount -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction SilentlyContinue
if ($null -eq $integrationAccount) {
    Write-Error "Unable to find the Azure Integration Account with name '$Name' in resource group '$ResourceGroupName'"
} else {
    if ($CertificatesFolder -ne '' -and $CertificateFilePath -eq '') {
        foreach ($certificate in Get-ChildItem($CertificatesFolder) -File) {
            UploadCertificate -Certificate $certificate
        }
    } elseif ($CertificatesFolder -eq '' -and $CertificateFilePath -ne '') {
        [System.IO.FileInfo]$certificate = New-Object System.IO.FileInfo($CertificateFilePath)
        UploadCertificate -Certificate $certificate
    }
}