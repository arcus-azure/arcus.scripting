<#
 .Synopsis
  Upload/update a single, or multiple schemas into an Azure Integration Account.
 
 .Description
  Provide a file- or folder-path to upload/update a single or multiple schemas into an Integration Account.

 .Parameter ResourceGroupName
  The name of the Azure resource group where the Azure Integration Account is located.
 
 .Parameter Name
  The name of the Azure Integration Account into which the schemas are to be uploaded/updated.

 .Parameter SchemaFilePath
  The full path of a schema that should be uploaded/updated.
  
 .Parameter SchemasFolder
  The path to a directory containing all schemas that should be uploaded/updated.

 .Parameter ArtifactsPrefix
  The prefix, if any, that should be added to the schemas before uploading/updating.

 .Parameter RemoveFileExtensions
  Indicator whether the extension should be removed from the name before uploading/updating.
#>
function Set-AzIntegrationAccountSchemas {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
        [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the Integration Account is required"),
        [parameter(Mandatory = $false)][string] $SchemaFilePath = $(if ($SchemasFolder -eq '') { throw "Either the file path of a specific schema or the file path of a folder containing multiple schemas is required, e.g.: -SchemaFilePath 'C:\Schemas\Schema.xsd' or -SchemasFolder 'C:\Schemas'" }),
        [parameter(Mandatory = $false)][string] $SchemasFolder = $(if ($SchemaFilePath -eq '') { throw "Either the file path of a specific schema or the file path of a folder containing multiple schemas is required, e.g.: -SchemaFilePath 'C:\Schemas\Schema.xsd' or -SchemasFolder 'C:\Schemas'" }),
        [Parameter(Mandatory = $false)][string] $ArtifactsPrefix = '',
        [Parameter(Mandatory = $false)][switch] $RemoveFileExtensions = $false
    )

    if ($RemoveFileExtensions) {
        . $PSScriptRoot\Scripts\Set-AzIntegrationAccountSchemas.ps1 -ResourceGroupName $ResourceGroupName -Name $Name -SchemaFilePath $SchemaFilePath -SchemasFolder $SchemasFolder -ArtifactsPrefix $ArtifactsPrefix -RemoveFileExtensions
    } else {
        . $PSScriptRoot\Scripts\Set-AzIntegrationAccountSchemas.ps1 -ResourceGroupName $ResourceGroupName -Name $Name -SchemaFilePath $SchemaFilePath -SchemasFolder $SchemasFolder -ArtifactsPrefix $ArtifactsPrefix
    }
}

Export-ModuleMember -Function Set-AzIntegrationAccountSchemas

<#
 .Synopsis
  Upload/update a single, or multiple maps into an Azure Integration Account.
 
 .Description
  Provide a file- or folder-path to upload/update a single or multiple maps into an Integration Account.

 .Parameter ResourceGroupName
  The name of the Azure resource group where the Azure Integration Account is located.
 
 .Parameter Name
  The name of the Azure Integration Account into which the schemas are to be uploaded/updated.

 .Parameter MapFilePath
  The full path of a map that should be uploaded/updated.
  
 .Parameter MapsFolder
  The path to a directory containing all maps that should be uploaded/updated.

 .Parameter MapType
  The type of map to be created (Defaulted to 'Xslt').

 .Parameter ArtifactsPrefix
  The prefix, if any, that should be added to the maps before uploading/updating.

 .Parameter RemoveFileExtensions
  Indicator whether the extension should be removed from the name before uploading/updating.
#>
function Set-AzIntegrationAccountMaps {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
        [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the Integration Account is required"),
        [parameter(Mandatory = $false)][string] $MapFilePath = $(if ($MapsFolder -eq '') { throw "Either the file path of a specific map or the file path of a folder containing multiple maps is required, e.g.: -MapFilePath 'C:\Maps\map.xslt' or -MapsFolder 'C:\Maps'" }),
        [parameter(Mandatory = $false)][string] $MapsFolder = $(if ($MapFilePath -eq '') { throw "Either the file path of a specific map or the file path of a folder containing multiple maps is required, e.g.: -MapFilePath 'C:\Maps\map.xslt' or -MapsFolder 'C:\Maps'" }),
        [Parameter(Mandatory = $false)][string] $MapType = 'Xslt',
        [Parameter(Mandatory = $false)][string] $ArtifactsPrefix = '',
        [Parameter(Mandatory = $false)][switch] $RemoveFileExtensions = $false
    )

    if ($RemoveFileExtensions) {
        . $PSScriptRoot\Scripts\Set-AzIntegrationAccountMaps.ps1 -ResourceGroupName $ResourceGroupName -Name $Name -MapFilePath $MapFilePath -MapsFolder $MapsFolder -MapType $MapType -ArtifactsPrefix $ArtifactsPrefix -RemoveFileExtensions
    } else {
        . $PSScriptRoot\Scripts\Set-AzIntegrationAccountMaps.ps1 -ResourceGroupName $ResourceGroupName -Name $Name -MapFilePath $MapFilePath -MapsFolder $MapsFolder -MapType $MapType -ArtifactsPrefix $ArtifactsPrefix
    }
}

Export-ModuleMember -Function Set-AzIntegrationAccountMaps

<#
 .Synopsis
  Upload/update a single, or multiple assemblies into an Azure Integration Account.
 
 .Description
  Provide a file- or folder-path to upload/update a single or multiple assemblies into an Integration Account.

 .Parameter ResourceGroupName
  The name of the Azure resource group where the Azure Integration Account is located.
 
 .Parameter Name
  The name of the Azure Integration Account into which the assemblies are to be uploaded/updated.

 .Parameter AssemblyFilePath
  The full path of a assembly that should be uploaded/updated.
  
 .Parameter AssembliesFolder
  The path to a directory containing all assemblies that should be uploaded/updated.

 .Parameter ArtifactsPrefix
  The prefix, if any, that should be added to the assemblies before uploading/updating.
#>
function Set-AzIntegrationAccountAssemblies {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
        [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the Integration Account is required"),
        [parameter(Mandatory = $false)][string] $AssemblyFilePath = $(if ($AssembliesFolder -eq '') { throw "Either the file path of a specific assembly or the file path of a folder containing multiple assemblies is required, e.g.: -AssemblyFilePath 'C:\Assemblies\assembly.dll' or -AssembliesFolder 'C:\Assemblies'" }),
        [parameter(Mandatory = $false)][string] $AssembliesFolder = $(if ($AssemblyFilePath -eq '') { throw "Either the file path of a specific assembly or the file path of a folder containing multiple assemblies is required, e.g.: -AssemblyFilePath 'C:\Assemblies\assembly.dll' or -AssembliesFolder 'C:\Assemblies'" }),
        [Parameter(Mandatory = $false)][string] $ArtifactsPrefix = ''
    )

    . $PSScriptRoot\Scripts\Set-AzIntegrationAccountAssemblies.ps1 -ResourceGroupName $ResourceGroupName -Name $Name -AssemblyFilePath $AssemblyFilePath -AssembliesFolder $AssembliesFolder -ArtifactsPrefix $ArtifactsPrefix
}

Export-ModuleMember -Function Set-AzIntegrationAccountAssemblies

<#
 .Synopsis
  Upload/update a single, or multiple certificates into an Azure Integration Account.
 
 .Description
  Provide a file- or folder-path to upload/update a single or multiple certificates into an Integration Account.

 .Parameter ResourceGroupName
  The name of the Azure resource group where the Azure Integration Account is located.
 
 .Parameter Name
  The name of the Azure Integration Account into which the certificates are to be uploaded/updated.

 .Parameter CertificateType
  The type of certificate, this can either be Public or Private.

 .Parameter CertificateFilePath
  The full path of a certificate that should be uploaded/updated.
  
 .Parameter CertificatesFolder
  The path to a directory containing all certificates that should be uploaded/updated.

 .Parameter KeyName
  The name of the key in Azure KeyVault that will be used for uploading/updating private certificates.

 .Parameter KeyVersion
  The version of the key in Azure KeyVault that will be used for uploading/updating private certificates.

 .Parameter KeyVaultId
  The id of the Azure KeyVault that will be used for uploading/updating private certificates.

 .Parameter ArtifactsPrefix
  The prefix, if any, that should be added to the certificates before uploading/updating.
#>
function Set-AzIntegrationAccountCertificates {
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

    . $PSScriptRoot\Scripts\Set-AzIntegrationAccountCertificates.ps1 -ResourceGroupName $ResourceGroupName -Name $Name -CertificateType $CertificateType -CertificateFilePath $CertificateFilePath -CertificatesFolder $CertificatesFolder -KeyName $KeyName -KeyVersion $KeyVersion -KeyVaultId $KeyVaultId -ArtifactsPrefix $ArtifactsPrefix
}

Export-ModuleMember -Function Set-AzIntegrationAccountCertificates

<#
 .Synopsis
  Upload/update a single, or multiple partners into an Azure Integration Account.
 
 .Description
  Provide a file- or folder-path to upload/update a single or multiple partners into an Integration Account.

 .Parameter ResourceGroupName
  The name of the Azure resource group where the Azure Integration Account is located.
 
 .Parameter Name
  The name of the Azure Integration Account into which the partners are to be uploaded/updated.

 .Parameter PartnerFilePath
  The full path of a partner that should be uploaded/updated.
  
 .Parameter PartnersFolder
  The path to a directory containing all partners that should be uploaded/updated.

 .Parameter ArtifactsPrefix
  The prefix, if any, that should be added to the partners before uploading/updating.
#>
function Set-AzIntegrationAccountPartners {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
        [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the Integration Account is required"),
        [parameter(Mandatory = $false)][string] $PartnerFilePath = $(if ($PartnersFolder -eq '') { throw "Either the file path of a specific partner or the file path of a folder containing multiple partners is required, e.g.: -PartnerFilePath 'C:\Partners\partner.json' or -PartnersFolder 'C:\Partners'" }),
        [parameter(Mandatory = $false)][string] $PartnersFolder = $(if ($PartnerFilePath -eq '') { throw "Either the file path of a specific partner or the file path of a folder containing multiple partners is required, e.g.: -PartnerFilePath 'C:\Partners\partner.json' or -PartnersFolder 'C:\Partners'" }),
        [Parameter(Mandatory = $false)][string] $ArtifactsPrefix = ''
    )

    . $PSScriptRoot\Scripts\Set-AzIntegrationAccountPartners.ps1 -ResourceGroupName $ResourceGroupName -Name $Name -PartnerFilePath $PartnerFilePath -PartnersFolder $PartnersFolder -ArtifactsPrefix $ArtifactsPrefix
}

Export-ModuleMember -Function Set-AzIntegrationAccountPartners

<#
 .Synopsis
  Upload/update a single, or multiple agreements into an Azure Integration Account.
 
 .Description
  Provide a file- or folder-path to upload/update a single or multiple agreements into an Integration Account.

 .Parameter ResourceGroupName
  The name of the Azure resource group where the Azure Integration Account is located.
 
 .Parameter Name
  The name of the Azure Integration Account into which the agreements are to be uploaded/updated.

 .Parameter AgreementFilePath
  The full path of a agreement that should be uploaded/updated.
  
 .Parameter AgreementsFolder
  The path to a directory containing all agreements that should be uploaded/updated.

 .Parameter ArtifactsPrefix
  The prefix, if any, that should be added to the agreements before uploading/updating.
#>
function Set-AzIntegrationAccountAgreements {
    param(
        [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
        [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the Integration Account is required"),
        [parameter(Mandatory = $false)][string] $AgreementFilePath = $(if ($AgreementsFolder -eq '') { throw "Either the file path of a specific agreement or the file path of a folder containing multiple agreements is required, e.g.: -AgreementFilePath 'C:\Agreements\agreement.json' or -AgreementsFolder 'C:\Agreements'" }),
        [parameter(Mandatory = $false)][string] $AgreementsFolder = $(if ($AgreementFilePath -eq '') { throw "Either the file path of a specific agreement or the file path of a folder containing multiple agreements is required, e.g.: -AgreementFilePath 'C:\Agreements\agreement.json' or -AgreementsFolder 'C:\Agreements'" }),
        [Parameter(Mandatory = $false)][string] $ArtifactsPrefix = ''
    )

    . $PSScriptRoot\Scripts\Set-AzIntegrationAccountAgreements.ps1 -ResourceGroupName $ResourceGroupName -Name $Name -AgreementFilePath $AgreementFilePath -AgreementsFolder $AgreementsFolder -ArtifactsPrefix $ArtifactsPrefix
}

Export-ModuleMember -Function Set-AzIntegrationAccountAgreements