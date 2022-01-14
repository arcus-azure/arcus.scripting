Param(
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
    if ($agreementName -eq $null -or $agreementName -eq '') {
        throw "Cannot upload Agreement to Azure Integration Account '$Name' because the agreement name is empty"
    }

    if ($ArtifactsPrefix -ne '') {
        $agreementName = $ArtifactsPrefix + $agreementName
    }
    Write-Host "Uploading agreement '$agreementName' into the Integration Account '$Name'"

    $agreementType = $agreementData.properties.agreementType
    $hostPartner = $agreementData.properties.hostPartner
    $hostIdentityQualifier = $agreementData.properties.hostIdentity.qualifier
    $hostIdentityQualifierValue = $agreementData.properties.hostIdentity.value
    $guestPartner = $agreementData.properties.guestPartner    
    $guestIdentityQualifier = $agreementData.properties.guestIdentity.qualifier
    $guestIdentityQualifierValue = $agreementData.properties.guestIdentity.value
    $agreementContent = $agreementData.properties.content | ConvertTo-Json -Depth 20 -Compress

    $existingAgreement = $null
    try {
        Write-Verbose "Checking if the agreement '$agreementName' already exists in the Azure Integration Account '$Name'"
        $existingAgreement = Get-AzIntegrationAccountAgreement -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -AgreementName $agreementName -ErrorAction Stop
    }
    catch {
        if ($_.Exception.Message.Contains('could not be found')) {
            Write-Verbose "No agreement '$agreementName' could not be found in Azure Integration Account '$Name'"
        }
        else {
            throw $_.Exception
        }
    }
        
    try {
        if ($existingAgreement -eq $null) {
            Write-Verbose "Creating agreement '$agreementName' in Azure Integration Account '$Name'"
            $createdAgreement = New-AzIntegrationAccountAgreement -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -AgreementName $agreementName -AgreementType $agreementType -HostPartner $hostPartner -HostIdentityQualifier $hostIdentityQualifier -HostIdentityQualifierValue $hostIdentityQualifierValue -GuestPartner $guestPartner -GuestIdentityQualifier $guestIdentityQualifier -GuestIdentityQualifierValue $guestIdentityQualifierValue -AgreementContent $agreementContent -ErrorAction Stop
            Write-Verbose ($createdAgreement | Format-List -Force | Out-String)
        }
        else {
            Write-Verbose "Updating agreement '$agreementName' in Azure Integration Account '$Name'"
            $updatedAgreement = Set-AzIntegrationAccountAgreement -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -AgreementName $agreementName -AgreementType $agreementType -HostPartner $hostPartner -HostIdentityQualifier $hostIdentityQualifier -HostIdentityQualifierValue $hostIdentityQualifierValue -GuestPartner $guestPartner -GuestIdentityQualifier $guestIdentityQualifier -GuestIdentityQualifierValue $guestIdentityQualifierValue -AgreementContent $agreementContent -Force -ErrorAction Stop
            Write-Verbose ($updatedAgreement | Format-List -Force | Out-String)
        }
        Write-Host "Agreement '$agreementName' has been uploaded into the Azure Integration Account '$Name'"
    }
    catch {
        Write-Error "Failed to upload agreement '$agreementName' in Azure Integration Account '$Name': '$($_.Exception.Message)'"
    }
}

# Verify if Integration Account can be found based on the given information
$integrationAccount = Get-AzIntegrationAccount -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction SilentlyContinue
if ($integrationAccount -eq $null) {
    Write-Error "Unable to find the Azure Integration Account with name '$Name' in resource group '$ResourceGroupName'"
}
else {
    if ($AgreementsFolder -ne '' -and $AgreementFilePath -eq '') {
        foreach ($agreement in Get-ChildItem($AgreementsFolder) -File) {
            UploadAgreement -Agreement $agreement
            Write-Host '----------'
        }
    }
    elseif ($AgreementsFolder -eq '' -and $AgreementFilePath -ne '') {
        [System.IO.FileInfo]$agreement = New-Object System.IO.FileInfo($AgreementFilePath)
        UploadAgreement -Agreement $agreement
    }
}