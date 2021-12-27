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

    if($RemoveFileExtensions) {
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

    if($RemoveFileExtensions) {
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