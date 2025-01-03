param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
    [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the Integration Account is required"),
    [parameter(Mandatory = $false)][string] $PartnerFilePath = $(if ($PartnersFolder -eq '') { throw "Either the file path of a specific partner or the file path of a folder containing multiple partners is required, e.g.: -PartnerFilePath 'C:\Partners\partner.json' or -PartnersFolder 'C:\Partners'" }),
    [parameter(Mandatory = $false)][string] $PartnersFolder = $(if ($PartnerFilePath -eq '') { throw "Either the file path of a specific partner or the file path of a folder containing multiple partners is required, e.g.: -PartnerFilePath 'C:\Partners\partner.json' or -PartnersFolder 'C:\Partners'" }),
    [Parameter(Mandatory = $false)][string] $ArtifactsPrefix = ''
)

if ($PartnerFilePath -ne '' -and $PartnersFolder -ne '') {
    throw "Either the file path of a specific partner or the file path of a folder containing multiple partners is required, e.g.: -PartnerFilePath 'C:\Partners\partner.json' or -PartnersFolder 'C:\Partners'"
}

function UploadPartner {
    param(
        [Parameter(Mandatory = $true)][System.IO.FileInfo] $Partner
    )

    $partnerData = Get-Content -Raw -Path $Partner.FullName | ConvertFrom-Json

    $partnerName = $partnerData.name
    if ($null -eq $partnerName -or $partnerName -eq '') {
        throw "Cannot upload Partner to Azure Integration Account '$Name' because the partner name is empty"
    }

    if ($ArtifactsPrefix -ne '') {
        $partnerName = $ArtifactsPrefix + $partnerName
    }
    Write-Verbose "Uploading partner '$partnerName' into the Azure Integration Account '$Name'..."

    $businessIdentities = $null
    foreach ($businessIdentity in $partnerData.properties.content.b2b.businessIdentities) {
        $qualifier = $businessIdentity.qualifier
        $value = $businessIdentity.value

        $businessIdentities += , @("$qualifier", "$value")
    }

    if ($businessIdentities.Count -eq 0) {
        throw "Cannot upload Partner to Azure Integration Account '$Name' because at least one business identity must be supplied"
    }

    $existingPartner = $null
    try {
        Write-Verbose "Checking if the partner '$partnerName' already exists in the Azure Integration Account '$Name'..."
        $existingPartner = Get-AzIntegrationAccountPartner -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -PartnerName $partnerName -ErrorAction Stop
    } catch {
        if ($_.Exception.Message.Contains('could not be found')) {
            Write-Warning "No partner '$partnerName' could not be found in Azure Integration Account '$Name'"
        } else {
            throw $_.Exception
        }
    }
        
    try {
        if ($null -eq $existingPartner) {
            Write-Verbose "Creating partner '$partnerName' in Azure Integration Account '$Name'..."
            $createdPartner = New-AzIntegrationAccountPartner -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -PartnerName $partnerName -BusinessIdentities $businessIdentities -ErrorAction Stop
            Write-Debug ($createdPartner | Format-List -Force | Out-String)
        } else {
            Write-Verbose "Updating partner '$partnerName' in Azure Integration Account '$Name'..."
            $updatedPartner = Set-AzIntegrationAccountPartner -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -PartnerName $partnerName -BusinessIdentities $businessIdentities -Force -ErrorAction Stop 
            Write-Debug ($updatedPartner | Format-List -Force | Out-String)
        }
        Write-Host "Partner '$partnerName' has been uploaded into the Azure Integration Account '$Name'" -ForegroundColor Green
    } catch {
        Write-Error "Failed to upload partner '$partnerName' in Azure Integration Account '$Name'. Details: '$($_.Exception.Message)'"
    }
}

$integrationAccount = Get-AzIntegrationAccount -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction SilentlyContinue
if ($null -eq $integrationAccount) {
    Write-Error "Unable to find the Azure Integration Account with name '$Name' in resource group '$ResourceGroupName'"
} else {
    if ($PartnersFolder -ne '' -and $PartnerFilePath -eq '') {
        foreach ($partner in Get-ChildItem($PartnersFolder) -File) {
            UploadPartner -Partner $partner
        }
    } elseif ($PartnersFolder -eq '' -and $PartnerFilePath -ne '') {
        [System.IO.FileInfo]$partner = New-Object System.IO.FileInfo($PartnerFilePath)
        UploadPartner -Partner $partner
    }
}