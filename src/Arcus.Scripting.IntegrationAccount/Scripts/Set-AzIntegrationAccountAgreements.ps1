param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
    [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the Integration Account is required"),
    [parameter(Mandatory = $false)][string] $AgreementFilePath = $(if ($AgreementsFolder -eq '') { throw "Either the file path of a specific agreement or the file path of a folder containing multiple agreements is required, e.g.: -AgreementFilePath 'C:\Agreements\agreement.json' or -AgreementsFolder 'C:\Agreements'" }),
    [parameter(Mandatory = $false)][string] $AgreementsFolder = $(if ($AgreementFilePath -eq '') { throw "Either the file path of a specific agreement or the file path of a folder containing multiple agreements is required, e.g.: -AgreementFilePath 'C:\Agreements\agreement.json' or -AgreementsFolder 'C:\Agreements'" }),
    [Parameter(Mandatory = $false)][string] $ArtifactsPrefix = ''
)

if ($AgreementFilePath -ne '' -and $AgreementsFolder -ne '') {
    throw "Either the file path of a specific agreement or the file path of a folder containing multiple agreements is required, e.g.: -AgreementFilePath 'C:\Agreements\agreement.json' or -AgreementsFolder 'C:\Agreements'"
}

function UploadAgreement {
    param(
        [Parameter(Mandatory = $true)][System.IO.FileInfo] $Agreement
    )

    $agreementData = Get-Content -Raw -Path $Agreement.FullName | ConvertFrom-Json

    $agreementName = $agreementData.name
    if ($null -eq $agreementName -or $agreementName -eq '') {
        throw "Cannot upload Agreement to Azure Integration Account '$Name' because the agreement name is empty"
    }

    if ($ArtifactsPrefix -ne '') {
        $agreementName = $ArtifactsPrefix + $agreementName
    }
    Write-Verbose "Uploading agreement '$agreementName' into the Azure Integration Account '$Name'..."

    $agreementType = $agreementData.properties.agreementType
    if ($null -eq $agreementType -or $agreementType -eq '') {
        throw "Cannot upload Agreement to Azure Integration Account '$Name' because the agreement type is empty"
    }

    $hostPartner = $agreementData.properties.hostPartner
    if ($null -eq $hostPartner -or $hostPartner -eq '') {
        throw "Cannot upload Agreement to Azure Integration Account '$Name' because the host partner is empty"
    }

    $hostIdentityQualifier = $agreementData.properties.hostIdentity.qualifier
    if ($null -eq $hostIdentityQualifier -or $hostIdentityQualifier -eq '') {
        throw "Cannot upload Agreement to Azure Integration Account '$Name' because the host identity qualifier is empty"
    }

    $hostIdentityQualifierValue = $agreementData.properties.hostIdentity.value
    if ($null -eq $hostIdentityQualifierValue -or $hostIdentityQualifierValue -eq '') {
        throw "Cannot upload Agreement to Azure Integration Account '$Name' because the host identity value is empty"
    }

    $guestPartner = $agreementData.properties.guestPartner   
    if ($null -eq $guestPartner -or $guestPartner -eq '') {
        throw "Cannot upload Agreement to Azure Integration Account '$Name' because the guest partner is empty"
    }

    $guestIdentityQualifier = $agreementData.properties.guestIdentity.qualifier
    if ($null -eq $guestIdentityQualifier -or $guestIdentityQualifier -eq '') {
        throw "Cannot upload Agreement to Azure Integration Account '$Name' because the guest identity qualifier is empty"
    }

    $guestIdentityQualifierValue = $agreementData.properties.guestIdentity.value
    if ($null -eq $guestIdentityQualifierValue -or $guestIdentityQualifierValue -eq '') {
        throw "Cannot upload Agreement to Azure Integration Account '$Name' because the guest identity value is empty"
    }

    $agreementContent = $agreementData.properties.content | ConvertTo-Json -Depth 20 -Compress
    if ($null -eq $agreementContent -or $agreementContent -eq 'null' -or $agreementContent -eq '') {
        throw "Cannot upload Agreement to Azure Integration Account '$Name' because the agreement content is empty"
    }

    $existingAgreement = $null
    try {
        Write-Verbose "Checking if the agreement '$agreementName' already exists in the Azure Integration Account '$Name'..."
        $existingAgreement = Get-AzIntegrationAccountAgreement -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -AgreementName $agreementName -ErrorAction Stop
    } catch {
        if ($_.Exception.Message.Contains('could not be found')) {
            Write-Warning "No agreement '$agreementName' could not be found in Azure Integration Account '$Name'"
        } else {
            throw $_.Exception
        }
    }
        
    try {
        if ($null -eq $existingAgreement) {
            Write-Verbose "Creating agreement '$agreementName' in Azure Integration Account '$Name'..."
            $createdAgreement = New-AzIntegrationAccountAgreement -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -AgreementName $agreementName -AgreementType $agreementType -HostPartner $hostPartner -HostIdentityQualifier $hostIdentityQualifier -HostIdentityQualifierValue $hostIdentityQualifierValue -GuestPartner $guestPartner -GuestIdentityQualifier $guestIdentityQualifier -GuestIdentityQualifierValue $guestIdentityQualifierValue -AgreementContent $agreementContent -ErrorAction Stop
            Write-Debug ($createdAgreement | Format-List -Force | Out-String)
        } else {
            Write-Verbose "Updating agreement '$agreementName' in Azure Integration Account '$Name'..."
            $updatedAgreement = Set-AzIntegrationAccountAgreement -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -AgreementName $agreementName -AgreementType $agreementType -HostPartner $hostPartner -HostIdentityQualifier $hostIdentityQualifier -HostIdentityQualifierValue $hostIdentityQualifierValue -GuestPartner $guestPartner -GuestIdentityQualifier $guestIdentityQualifier -GuestIdentityQualifierValue $guestIdentityQualifierValue -AgreementContent $agreementContent -Force -ErrorAction Stop
            Write-Debug ($updatedAgreement | Format-List -Force | Out-String)
        }
        Write-Host "Agreement '$agreementName' has been uploaded into the Azure Integration Account '$Name'" -ForegroundColor Green
    } catch {
        Write-Error "Failed to upload agreement '$agreementName' in Azure Integration Account '$Name'. Details: '$($_.Exception.Message)'"
    }
}

$integrationAccount = Get-AzIntegrationAccount -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction SilentlyContinue
if ($null -eq $integrationAccount) {
    Write-Error "Unable to find the Azure Integration Account with name '$Name' in resource group '$ResourceGroupName'"
} else {
    if ($AgreementsFolder -ne '' -and $AgreementFilePath -eq '') {
        foreach ($agreement in Get-ChildItem($AgreementsFolder) -File) {
            UploadAgreement -Agreement $agreement
        }
    } elseif ($AgreementsFolder -eq '' -and $AgreementFilePath -ne '') {
        [System.IO.FileInfo]$agreement = New-Object System.IO.FileInfo($AgreementFilePath)
        UploadAgreement -Agreement $agreement
    }
}