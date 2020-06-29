#
# Module manifest for module 'module'
#
# Generated by: Arcus
#
# Generated on: 5/29/2020 10:12:26 AM
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'Arcus.Scripting.ApiManagement.psm1'

# Version number of this module.
ModuleVersion = '#{Package.Version}#'

# ID used to uniquely identify this module
GUID = '4f659b73-9e1e-4085-8ed0-a5ae1e46c34a'

# Author of this module
Author = 'Arcus'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = '(c) 2020 Arcus. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Scripts related to Azure API Management'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @('Az.ApiManagement')

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport = @('Create-AzApiManagementApiOperation', 'Remove-AzApiManagementDefaults', 'Import-AzApiManagementOperationPolicy')

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess
# PrivateData = ''

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

