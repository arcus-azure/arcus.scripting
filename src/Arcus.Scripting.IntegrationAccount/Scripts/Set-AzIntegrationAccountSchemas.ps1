Param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
    [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the Integration Account is required"),
    [parameter(Mandatory = $false)][string] $SchemaFilePath = $(if ($SchemasFolder -eq '') { throw "Either the file path of a specific schema or the file path of a folder containing multiple schemas is required, e.g.: -SchemaFilePath 'C:\Schemas\Schema.xsd' or -SchemasFolder 'C:\Schemas'" }),
    [parameter(Mandatory = $false)][string] $SchemasFolder = $(if ($SchemaFilePath -eq '') { throw "Either the file path of a specific schema or the file path of a folder containing multiple schemas is required, e.g.: -SchemaFilePath 'C:\Schemas\Schema.xsd' or -SchemasFolder 'C:\Schemas'" }),
    [Parameter(Mandatory = $false)][string] $ArtifactsPrefix = '',
    [Parameter(Mandatory = $false)][switch] $RemoveFileExtensions = $false
)

if ($SchemaFilePath -ne '' -and $SchemasFolder -ne '') {
    throw "Either the file path of a specific schema or the file path of a folder containing multiple schemas is required, e.g.: -SchemaFilePath 'C:\Schemas\Schema.xsd' or -SchemasFolder 'C:\Schemas'"
}

function UploadSchema {
    param
    (
        [System.IO.FileInfo][parameter(Mandatory = $true)]$Schema
    )

    $schemaName = $Schema.Name
    if ($RemoveFileExtensions) {
        $schemaName = $Schema.BaseName
    }
    if ($ArtifactsPrefix -ne '') {
        $schemaName = $ArtifactsPrefix + $schemaName
    }
    Write-Host "Uploading schema '$schemaName' into the Integration Account '$Name'"

    ## Check if the schema already exists
    $existingSchema = $null
    try {
        Write-Verbose "Checking if the schema '$schemaName' already exists in the Integration Account '$Name'"
        $existingSchema = Get-AzIntegrationAccountSchema -ResourceGroupName $ResourceGroupName -Name $Name -SchemaName $schemaName -ErrorAction Stop
    }
    catch {
        if ($_.Exception.Message.Contains('could not be found')) {
            Write-Verbose "No schema '$schemaName' could not be found in Azure Integration Account '$Name'"
        }
        else {
            throw $_.Exception
        }
    }
        
    try {
        if ($existingSchema -eq $null) {
            # Create the schema
            Write-Verbose "Creating schema '$schemaName' in Azure Integration Account '$Name'"
            $createdSchema = New-AzIntegrationAccountSchema -ResourceGroupName $ResourceGroupName -Name $Name -SchemaName $schemaName -SchemaFilePath $schema.FullName -ErrorAction Stop
            Write-Verbose ($createdSchema | Format-List -Force | Out-String)
        }
        else {
            # Update the schema
            Write-Verbose "Updating schema '$schemaName' in Azure Integration Account '$Name'"
            $updatedSchema = Set-AzIntegrationAccountSchema -ResourceGroupName $ResourceGroupName -Name $Name -SchemaName $schemaName -SchemaFilePath $schema.FullName -ErrorAction Stop -Force
            Write-Verbose ($updatedSchema | Format-List -Force | Out-String)
        }
        Write-Host "Schema '$schemaName' has been uploaded into the Azure Integration Account '$Name'"
    }
    catch {
        Write-Error "Failed to upload schema '$schemaName' in Azure Integration Account '$Name': '$($_.Exception.Message)_'"
    }
}

# Verify if Integration Account can be found based on the given information
$integrationAccount = Get-AzIntegrationAccount -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction SilentlyContinue
if ($integrationAccount -eq $null) {
    Write-Error "Unable to find the Azure Integration Account with name '$Name' in resource group '$ResourceGroupName'"
}
else {
    if ($SchemasFolder -ne '' -and $SchemaFilePath -eq '') {
        foreach ($schema in Get-ChildItem($schemasFolder) -File) {
            UploadSchema -Schema $schema
            Write-Host '----------'
        }
    }
    elseif ($schemasFolder -eq '' -and $SchemaFilePath -ne '') {
        [System.IO.FileInfo]$schema = New-Object System.IO.FileInfo("$SchemaFilePath")
        UploadSchema -Schema $schema
    }
}

