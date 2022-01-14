---
title: "Azure Integration Account"
layout: default
---

# Azure Integration Account

This module provides the following capabilities:
- [Uploading schemas into an Azure Integration Account](#uploading-schemas-into-an-azure-integration-account)
- [Uploading maps into an Azure Integration Account](#uploading-maps-into-an-azure-integration-account)
- [Uploading assemblies into an Azure Integration Account#](#uploading-assemblies-into-an-azure-integration-account)
- [Uploading certificates into an Azure Integration Account#](#uploading-certificates-into-an-azure-integration-account)
- [Uploading partners into an Azure Integration Account#](#uploading-partners-into-an-azure-integration-account)
- [Uploading agreements into an Azure Integration Account#](#uploading-agreements-into-an-azure-integration-account)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.IntegrationAccount
```

## Uploading schemas into an Azure Integration Account

Upload/update a single, or multiple schemas into an Azure Integration Account.

| Parameter              | Mandatory   | Description                                                                                                                            |
| ---------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`    | yes         | The name of the Azure resource group where the Azure Integration Account is located.                                                   |
| `Name`                 | yes         | The name of the Azure Integration Account into which the schemas are to be uploaded/updated.                                           |
| `SchemaFilePath`       | conditional | The full path of a schema that should be uploaded/updated. (_Mandatory if SchemasFolder has not been specified_).                      |
| `SchemasFolder`        | conditional | The path to a directory containing all schemas that should be uploaded/updated. (_Mandatory if SchemaFilePath has not been specified_).|
| `ArtifactsPrefix`      | no          | The prefix, if any, that should be added to the schemas before uploading/updating.                                                     |
| `RemoveFileExtensions` | no          | Indicator (switch) whether the extension should be removed from the name before uploading/updating.                                    |

**Example**  

Uploading a *single schema* into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountSchemas -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -SchemaFilePath "C:\Schemas\MySchema.xsd"
# Uploading schema 'MySchema.xsd' into the Azure Integration Account 'my-integration-account'
# Schema 'MySchema.xsd' has been uploaded into the Azure Integration Account 'my-integration-account'
```

Uploading a *single schema* into an Integration Account and remove the file-extension.  
```powershell
PS> Set-AzIntegrationAccountSchemas -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -SchemaFilePath "C:\Schemas\MySchema.xsd" -RemoveFileExtensions
# Uploading schema 'MySchema' into the Azure Integration Account 'my-integration-account'
# Schema 'MySchema' has been uploaded into the Azure Integration Account 'my-integration-account'
```
Uploading a *single schema* into an Integration Account and set add a prefix to the name of the schema within the Integration Account.  
```powershell
PS> Set-AzIntegrationAccountSchemas -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -SchemaFilePath "C:\Schemas\MySchema.xsd" -ArtifactsPrefix 'dev-'
# Uploading schema 'dev-MySchema.xsd' into the Azure Integration Account 'my-integration-account'
# Schema 'dev-MySchema.xsd' has been uploaded into the Azure Integration Account 'my-integration-account'
```

Uploading *all schemas* located in a specific folder into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountSchemas -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -SchemasFolder "C:\Schemas"
# Uploading schema 'MyFirstSchema.xsd' into the Azure Integration Account 'my-integration-account'
# Schema 'MyFirstSchema.xsd' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
# Uploading schema 'MySecondSchema.xsd' into the Azure Integration Account 'my-integration-account'
# Schema 'MySecondSchema.xsd' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
```

Uploading *all schemas* located in a specific folder into an Integration Account and remove the file-extension.  
```powershell
PS> Set-AzIntegrationAccountSchemas -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -SchemasFolder "C:\Schemas" -RemoveFileExtensions
# Uploading schema 'MyFirstSchema' into the Azure Integration Account 'my-integration-account'
# Schema 'MyFirstSchema' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
# Uploading schema 'MySecondSchema' into the Azure Integration Account 'my-integration-account'
# Schema 'MySecondSchema' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
```

Uploading *all schemas* located in a specific folder into an Integration Account and set add a prefix to the name of the schemas.
```powershell
PS> Set-AzIntegrationAccountSchemas -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -SchemasFolder "C:\Schemas" -ArtifactsPrefix 'dev-'
# Uploading schema 'dev-MyFirstSchema.xsd' into the Azure Integration Account 'my-integration-account'
# Schema 'dev-MyFirstSchema.xsd' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
# Uploading schema 'dev-MySecondSchema.xsd' into the Azure Integration Account 'my-integration-account'
# Schema 'dev-MySecondSchema.xsd' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
```


## Uploading maps into an Azure Integration Account

Upload/update a single, or multiple maps into an Azure Integration Account.

| Parameter              | Mandatory   | Description                                                                                                                            |
| ---------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`    | yes         | The name of the Azure resource group where the Azure Integration Account is located.                                                   |
| `Name`                 | yes         | The name of the Azure Integration Account into which the maps are to be uploaded/updated.                                              |
| `MapFilePath`          | conditional | The full path of a map that should be uploaded/updated. (_Mandatory if MapsFolder has not been specified_).                            |
| `MapsFolder`           | conditional | The path to a directory containing all maps that should be uploaded/updated. (_Mandatory if MapFilePath has not been specified_).      |
| `MapType`              | no          | The type of map to be created, default to 'Xslt'. See possible values [here](https://docs.microsoft.com/en-us/powershell/module/az.logicapp/get-azintegrationaccountmap?view=azps-6.2.1#parameters).  |
| `ArtifactsPrefix`      | no          | The prefix, if any, that should be added to the maps before uploading/updating.                                                        |
| `RemoveFileExtensions` | no          | Indicator (switch) whether the extension should be removed from the name before uploading/updating.                                    |

**Example**  

Uploading a *single map* into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountMaps -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -MapFilePath "C:\Maps\MyMap.xslt"
# Uploading map 'MyMap.xslt' into the Azure Integration Account 'my-integration-account'
# Map 'MyMap.xslt' has been uploaded into the Azure Integration Account 'my-integration-account'
```

Uploading a *single map* into an Integration Account and remove the file-extension.  
```powershell
PS> Set-AzIntegrationAccountMaps -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -MapFilePath "C:\Maps\MyMap.xslt" -RemoveFileExtensions
# Uploading map 'MyMap' into the Azure Integration Account 'my-integration-account'
# Map 'MyMap' has been uploaded into the Azure Integration Account 'my-integration-account'
```
Uploading a *single map* into an Integration Account and set add a prefix to the name of the schema within the Integration Account.  
```powershell
PS> Set-AzIntegrationAccountMaps -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -MapFilePath "C:\Maps\MyMap.xslt" -ArtifactsPrefix 'dev-'
# Uploading smapchema 'dev-MyMap.xsd' into the Azure Integration Account 'my-integration-account'
# Map 'dev-MyMap.xsd' has been uploaded into the Azure Integration Account 'my-integration-account'
```

Uploading *all maps* located in a specific folder into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountMaps -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -MapsFolder "C:\Maps"
# Uploading map 'MyFirstMap.xslt' into the Azure Integration Account 'my-integration-account'
# Map 'MyFirstMap.xslt' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
# Uploading map 'MySecondMap.xslt' into the Azure Integration Account 'my-integration-account'
# Map 'MySecondMap.xslt' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
```

Uploading *all maps* located in a specific folder into an Integration Account and remove the file-extension.  
```powershell
PS> Set-AzIntegrationAccountMaps -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -MapsFolder "C:\Maps" -RemoveFileExtensions
# Uploading map 'MyFirstMap' into the Azure Integration Account 'my-integration-account'
# Map 'MyFirstMap' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
# Uploading map 'MySecondMap' into the Azure Integration Account 'my-integration-account'
# Map 'MySecondMap' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
```

Uploading *all maps* located in a specific folder into an Integration Account and set add a prefix to the name of the maps.
```powershell
PS> Set-AzIntegrationAccountMaps -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -MapsFolder "C:\Maps" -ArtifactsPrefix 'dev-'
# Uploading map 'dev-MyFirstMap.xslt' into the Azure Integration Account 'my-integration-account'
# Map 'dev-MyFirstMap.xslt' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
# Uploading map 'dev-MySecondMap.xslt' into the Azure Integration Account 'my-integration-account'
# Map 'dev-MySecondMap.xslt' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
```

## Uploading assemblies into an Azure Integration Account

Upload/update a single, or multiple assemblies into an Azure Integration Account.

| Parameter              | Mandatory   | Description                                                                                                                                  |
| ---------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`    | yes         | The name of the Azure resource group where the Azure Integration Account is located.                                                         |
| `Name`                 | yes         | The name of the Azure Integration Account into which the assemblies are to be uploaded/updated.                                              |
| `AssemblyFilePath`     | conditional | The full path of an assembly that should be uploaded/updated. (_Mandatory if AssembliesFolder has not been specified_).                      |
| `AssembliesFolder`     | conditional | The path to a directory containing all assemblies that should be uploaded/updated. (_Mandatory if AssemblyFilePath has not been specified_). |
| `ArtifactsPrefix`      | no          | The prefix, if any, that should be added to the assemblies before uploading/updating.                                                        |

**Example**  

Uploading a *single assembly* into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountAssemblies -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -AssemblyFilePath "C:\Assemblies\MyAssembly.dll"
# Uploading assembly 'MyAssembly.dll' into the Azure Integration Account 'my-integration-account'
# Assembly 'MyAssembly.dll' has been uploaded into the Azure Integration Account 'my-integration-account'
```

Uploading a *single assembly* into an Integration Account and set add a prefix to the name of the assembly within the Integration Account.  
```powershell
PS> Set-AzIntegrationAccountAssemblies -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -AssemblyFilePath "C:\Assemblies\MyAssembly.dll" -ArtifactsPrefix 'dev-'
# Uploading assembly 'dev-MyAssembly.dll' into the Azure Integration Account 'my-integration-account'
# Assembly 'dev-MyAssembly.dll' has been uploaded into the Azure Integration Account 'my-integration-account'
```

Uploading *all assemblies* located in a specific folder into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountAssemblies -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -AssembliesFolder "C:\Assemblies"
# Uploading assembly 'MyFirstAssembly.dll' into the Azure Integration Account 'my-integration-account'
# Assembly 'MyFirstAssembly.dll' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
# Uploading assembly 'MySecondAssembly.dll' into the Azure Integration Account 'my-integration-account'
# Assembly 'MySecondAssembly.dll' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
```

Uploading *all assemblies* located in a specific folder into an Integration Account and set add a prefix to the name of the assemblies.
```powershell
PS> Set-AzIntegrationAccountAssemblies -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -AssembliesFolder "C:\Assemblies" -ArtifactsPrefix 'dev-'
# Uploading assembly 'dev-MyFirstAssembly.dll' into the Azure Integration Account 'my-integration-account'
# Assembly 'dev-MyFirstAssembly.dll' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
# Uploading assembly 'dev-MySecondAssembly.dll' into the Azure Integration Account 'my-integration-account'
# Assembly 'dev-MySecondAssembly.dll' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
```

## Uploading certificates into an Azure Integration Account

Upload/update a single, or multiple certificates into an Azure Integration Account.

| Parameter              | Mandatory   | Description                                                                                                                                                                                                            |
| ---------------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`    | yes         | The name of the Azure resource group where the Azure Integration Account is located.                                                                                                                                   |
| `Name`                 | yes         | The name of the Azure Integration Account into which the certificates are to be uploaded/updated.                                                                                                                      |
| `CertificateType`      | yes         | The type of certificate that will be uploaded, this can be either _Public_ or _Private_.                                                                                                                               |
| `CertificateFilePath`  | conditional | The full path of a certificate that should be uploaded/updated. (_Mandatory if CertificatesFolder has not been specified_).                                                                                            |
| `CertificatesFolder`   | conditional | The path to a directory containing all certificates that should be uploaded/updated. (_Mandatory if CertificateFilePath has not been specified_). This parameter is not supported when uploading Private certificates. |
| `KeyName`              | no          | The name of the key in Azure KeyVault that is used when uploading Private certificates. (_Mandatory if CertificateType is set to Private_)                                                                             |
| `KeyVersion`           | no          | The version of the key in Azure KeyVault that is used when uploading Private certificates. (_Mandatory if CertificateType is set to Private_)                                                                          |
| `KeyVaultId`           | no          | The id of the Azure KeyVault that is used when uploading Private certificates. (_Mandatory if CertificateType is set to Private_)                                                                                      |
| `ArtifactsPrefix`      | no          | The prefix, if any, that should be added to the certificates before uploading/updating.                                                                                                                                |

**Example**  

Uploading a *single public certificate* into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountCertificates -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -CertificateType 'Public' -CertificateFilePath "C:\Certificates\MyCertificate.cer"
# Uploading certificate 'MyCertificate.cer' into the Azure Integration Account 'my-integration-account'
# Certificate 'MyCertificate.cer' has been uploaded into the Azure Integration Account 'my-integration-account'
```

Uploading a *single public certificate* into an Integration Account and set add a prefix to the name of the certificate within the Integration Account.  
```powershell
PS> Set-AzIntegrationAccountCertificates -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -CertificateType 'Public' -CertificateFilePath "C:\Certificates\MyCertificate.cer" -ArtifactsPrefix 'dev-'
# Uploading certificate 'dev-MyCertificate.cer' into the Azure Integration Account 'my-integration-account'
# Certificate 'dev-MyCertificate.cer' has been uploaded into the Azure Integration Account 'my-integration-account'
```

Uploading *all public certificates* located in a specific folder into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountCertificates -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -CertificateType 'Public' -CertificatesFolder "C:\Certificates"
# Uploading certificate 'MyFirstCertificate.cer' into the Azure Integration Account 'my-integration-account'
# Certificate 'MyFirstCertificate.cer' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
# Uploading certificate 'MySecondCertificate.cer' into the Azure Integration Account 'my-integration-account'
# Certificate 'MySecondCertificate.cer' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
```

Uploading *all public assemblies* located in a specific folder into an Integration Account and set add a prefix to the name of the certificates.
```powershell
PS> Set-AzIntegrationAccountCertificates -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -CertificateType 'Public' -CertificatesFolder "C:\Certificates" -ArtifactsPrefix 'dev-'
# Uploading certificate 'dev-MyFirstCertificate.cer' into the Azure Integration Account 'my-integration-account'
# Certificate 'dev-MyFirstCertificate.cer' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
# Uploading certificate 'dev-MySecondCertificate.cer' into the Azure Integration Account 'my-integration-account'
# Certificate 'dev-MySecondCertificate.cer' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
```

Uploading a *single private certificate* into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountCertificates -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -CertificateType 'Private' -CertificateFilePath "C:\Certificates\MyCertificate.cer" -KeyName 'MyKey' -KeyVersion 'MyKeyVersion' -KeyVaultId '/subscriptions/<subscriptionId>/resourcegroups/<resourceGroup>/providers/microsoft.keyvault/vaults/<keyVault>'
# Uploading certificate 'MyCertificate.cer' into the Azure Integration Account 'my-integration-account'
# Certificate 'MyCertificate.cer' has been uploaded into the Azure Integration Account 'my-integration-account'
```

Uploading a *single private certificate* into an Integration Account and set add a prefix to the name of the certificate within the Integration Account.  
```powershell
PS> Set-AzIntegrationAccountCertificates -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -CertificateType 'Private' -CertificateFilePath "C:\Certificates\MyCertificate.cer" -ArtifactsPrefix 'dev-' -KeyName 'MyKey' -KeyVersion 'MyKeyVersion' -KeyVaultId '/subscriptions/<subscriptionId>/resourcegroups/<resourceGroup>/providers/microsoft.keyvault/vaults/<keyVault>'
# Uploading certificate 'dev-MyCertificate.cer' into the Azure Integration Account 'my-integration-account'
# Certificate 'dev-MyCertificate.cer' has been uploaded into the Azure Integration Account 'my-integration-account'
```

## Uploading partners into an Azure Integration Account

Upload/update a single, or multiple partners into an Azure Integration Account.

| Parameter              | Mandatory   | Description                                                                                                                                  |
| ---------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`    | yes         | The name of the Azure resource group where the Azure Integration Account is located.                                                         |
| `Name`                 | yes         | The name of the Azure Integration Account into which the partners are to be uploaded/updated.                                                |
| `PartnerFilePath`      | conditional | The full path of a partner that should be uploaded/updated. (_Mandatory if `PartnersFolder` has not been specified_).                          |
| `PartnersFolder`       | conditional | The path to a directory containing all partners that should be uploaded/updated. (_Mandatory if `PartnerFilePath` has not been specified_).    |
| `ArtifactsPrefix`      | no          | The prefix, if any, that should be added to the partners before uploading/updating.                                                          |

**Example**  

Uploading a *single partner* into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountPartners -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -PartnerFilePath "C:\Partners\MyPartner.json"
# Uploading partner 'MyPartner.json' into the Azure Integration Account 'my-integration-account'
# Partner 'MyPartner.json' has been uploaded into the Azure Integration Account 'my-integration-account'
```

Uploading a *single partner* into an Integration Account and set add a prefix to the name of the partner within the Integration Account.  
```powershell
PS> Set-AzIntegrationAccountPartners -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -PartnerFilePath "C:\Partners\MyPartner.json" -ArtifactsPrefix 'dev-'
# Uploading partner 'dev-MyPartner.json' into the Azure Integration Account 'my-integration-account'
# Partner 'dev-MyPartner.json' has been uploaded into the Azure Integration Account 'my-integration-account'
```

Uploading *all partners* located in a specific folder into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountPartners -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -PartnersFolder "C:\Partners"
# Uploading partner 'MyFirstPartner.json' into the Azure Integration Account 'my-integration-account'
# Partner 'MyFirstPartner.json' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
# Uploading partner 'MySecondPartner.json' into the Azure Integration Account 'my-integration-account'
# Partner 'MySecondPartner.json' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
```

Uploading *all partners* located in a specific folder into an Integration Account and set add a prefix to the name of the partners.
```powershell
PS> Set-AzIntegrationAccountPartners -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -PartnersFolder "C:\Partners" -ArtifactsPrefix 'dev-'
# Uploading partner 'dev-MyFirstPartner.json' into the Azure Integration Account 'my-integration-account'
# Partner 'dev-MyFirstPartner.json' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
# Uploading partner 'dev-MySecondPartner.json' into the Azure Integration Account 'my-integration-account'
# Partner 'dev-MySecondPartner.json' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
```

**Partner JSON Example**
The partner definition is the JSON representation of your partner, this JSON definition can also be viewed in the Azure Portal using https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-enterprise-integration-partners#edit-a-partner and clicking on `Edit as JSON`.
An example of this file:
```
{
  "name": "MyPartner",
  "properties": {
    "partnerType": "B2B",
    "content": {
      "b2b": {
        "businessIdentities": [
          {
            "qualifier": "1",
            "value": "12345"
          },
          {
            "qualifier": "1",
            "value": "54321"
          }
        ]
      }
    }
  }
}
```

## Uploading agreements into an Azure Integration Account

Upload/update a single, or multiple agreements into an Azure Integration Account.

| Parameter              | Mandatory   | Description                                                                                                                                  |
| ---------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`    | yes         | The name of the Azure resource group where the Azure Integration Account is located.                                                         |
| `Name`                 | yes         | The name of the Azure Integration Account into which the agreements are to be uploaded/updated.                                                |
| `AgreementFilePath`    | conditional | The full path of a agreement that should be uploaded/updated. (_Mandatory if `AgreementsFolder` has not been specified_).                          |
| `AgreementsFolder`     | conditional | The path to a directory containing all agreements that should be uploaded/updated. (_Mandatory if `AgreementFilePath` has not been specified_).    |
| `ArtifactsPrefix`      | no          | The prefix, if any, that should be added to the agreements before uploading/updating.                                                          |

**Example**  

Uploading a *single agreement* into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountAgreements -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -AgreementFilePath "C:\Agreements\MyAgreement.json"
# Uploading agreement 'MyAgreement' into the Azure Integration Account 'my-integration-account'
# Agreement 'MyAgreement' has been uploaded into the Azure Integration Account 'my-integration-account'
```

Uploading a *single agreement* into an Integration Account and set add a prefix to the name of the agreement within the Integration Account.  
```powershell
PS> Set-AzIntegrationAccountAgreements -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -AgreementFilePath "C:\Agreements\MyAgreement.json" -ArtifactsPrefix 'dev-'
# Uploading agreement 'dev-MyAgreement' into the Azure Integration Account 'my-integration-account'
# Agreement 'dev-MyAgreement' has been uploaded into the Azure Integration Account 'my-integration-account'
```

Uploading *all agreements* located in a specific folder into an Integration Account.  
```powershell
PS> Set-AzIntegrationAccountAgreements -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -AgreementsFolder "C:\Agreements"
# Uploading agreement 'MyFirstAgreement' into the Azure Integration Account 'my-integration-account'
# Agreement 'MyFirstAgreement' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
# Uploading agreement 'MySecondAgreement' into the Azure Integration Account 'my-integration-account'
# Agreement 'MySecondAgreement' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
```

Uploading *all agreements* located in a specific folder into an Integration Account and set add a prefix to the name of the agreements.
```powershell
PS> Set-AzIntegrationAccountAgreements -ResourceGroupName 'my-resource-group' -Name 'my-integration-account' -AgreementsFolder "C:\Agreements" -ArtifactsPrefix 'dev-'
# Uploading agreement 'dev-MyFirstAgreement' into the Azure Integration Account 'my-integration-account'
# Agreement 'dev-MyFirstAgreement' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
# Uploading agreement 'dev-MySecondAgreement' into the Azure Integration Account 'my-integration-account'
# Agreement 'dev-MySecondAgreement' has been uploaded into the Azure Integration Account 'my-integration-account'
# ----------
```

**Agreement JSON Example**
The agreement definition is the JSON representation of your agreement, this JSON definition can also be viewed in the Azure Portal using https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-enterprise-integration-agreements#edit-an-agreement and clicking on `Edit as JSON`.
An example of this file:
```
{
  "name": "MyAgreement",
  "properties": {
    "hostPartner": "Partner1",
    "guestPartner": "Partner2",
    "hostIdentity": {
      "qualifier": "1",
      "value": "12345"
    },
    "guestIdentity": {
      "qualifier": "1",
      "value": "98765"
    },
    "agreementType": "AS2",
    "content": {
      "aS2": {
        "receiveAgreement": {
          "protocolSettings": {
            "messageConnectionSettings": {
              "ignoreCertificateNameMismatch": false,
              "supportHttpStatusCodeContinue": true,
              "keepHttpConnectionAlive": true,
              "unfoldHttpHeaders": true
            },
            "acknowledgementConnectionSettings": {
              "ignoreCertificateNameMismatch": false,
              "supportHttpStatusCodeContinue": false,
              "keepHttpConnectionAlive": false,
              "unfoldHttpHeaders": false
            },
            "mdnSettings": {
              "needMDN": false,
              "signMDN": false,
              "sendMDNAsynchronously": false,
              "dispositionNotificationTo": "http://localhost",
              "signOutboundMDNIfOptional": false,
              "sendInboundMDNToMessageBox": true,
              "micHashingAlgorithm": "SHA1"
            },
            "securitySettings": {
              "overrideGroupSigningCertificate": false,
              "enableNRRForInboundEncodedMessages": false,
              "enableNRRForInboundDecodedMessages": false,
              "enableNRRForOutboundMDN": false,
              "enableNRRForOutboundEncodedMessages": false,
              "enableNRRForOutboundDecodedMessages": false,
              "enableNRRForInboundMDN": false
            },
            "validationSettings": {
              "overrideMessageProperties": false,
              "encryptMessage": false,
              "signMessage": false,
              "compressMessage": false,
              "checkDuplicateMessage": false,
              "interchangeDuplicatesValidityDays": 5,
              "checkCertificateRevocationListOnSend": false,
              "checkCertificateRevocationListOnReceive": false,
              "encryptionAlgorithm": "DES3",
              "signingAlgorithm": "Default"
            },
            "envelopeSettings": {
              "messageContentType": "text/plain",
              "transmitFileNameInMimeHeader": false,
              "fileNameTemplate": "%FILE().ReceivedFileName%",
              "suspendMessageOnFileNameGenerationError": true,
              "autogenerateFileName": false
            },
            "errorSettings": {
              "suspendDuplicateMessage": false,
              "resendIfMDNNotReceived": false
            }
          },
          "senderBusinessIdentity": {
            "qualifier": "1",
            "value": "9876"
          },
          "receiverBusinessIdentity": {
            "qualifier": "1",
            "value": "1234"
          }
        },
        "sendAgreement": {
          "protocolSettings": {
            "messageConnectionSettings": {
              "ignoreCertificateNameMismatch": false,
              "supportHttpStatusCodeContinue": true,
              "keepHttpConnectionAlive": true,
              "unfoldHttpHeaders": true
            },
            "acknowledgementConnectionSettings": {
              "ignoreCertificateNameMismatch": false,
              "supportHttpStatusCodeContinue": false,
              "keepHttpConnectionAlive": false,
              "unfoldHttpHeaders": false
            },
            "mdnSettings": {
              "needMDN": false,
              "signMDN": false,
              "sendMDNAsynchronously": false,
              "dispositionNotificationTo": "http://localhost",
              "signOutboundMDNIfOptional": false,
              "sendInboundMDNToMessageBox": true,
              "micHashingAlgorithm": "SHA1"
            },
            "securitySettings": {
              "overrideGroupSigningCertificate": false,
              "enableNRRForInboundEncodedMessages": false,
              "enableNRRForInboundDecodedMessages": false,
              "enableNRRForOutboundMDN": false,
              "enableNRRForOutboundEncodedMessages": false,
              "enableNRRForOutboundDecodedMessages": false,
              "enableNRRForInboundMDN": false
            },
            "validationSettings": {
              "overrideMessageProperties": false,
              "encryptMessage": false,
              "signMessage": false,
              "compressMessage": false,
              "checkDuplicateMessage": false,
              "interchangeDuplicatesValidityDays": 5,
              "checkCertificateRevocationListOnSend": false,
              "checkCertificateRevocationListOnReceive": false,
              "encryptionAlgorithm": "DES3",
              "signingAlgorithm": "Default"
            },
            "envelopeSettings": {
              "messageContentType": "text/plain",
              "transmitFileNameInMimeHeader": false,
              "fileNameTemplate": "%FILE().ReceivedFileName%",
              "suspendMessageOnFileNameGenerationError": true,
              "autogenerateFileName": false
            },
            "errorSettings": {
              "suspendDuplicateMessage": false,
              "resendIfMDNNotReceived": false
            }
          },
          "senderBusinessIdentity": {
            "qualifier": "1",
            "value": "1234"
          },
          "receiverBusinessIdentity": {
            "qualifier": "1",
            "value": "9876"
          }
        }
      }
    }
  }
}
```