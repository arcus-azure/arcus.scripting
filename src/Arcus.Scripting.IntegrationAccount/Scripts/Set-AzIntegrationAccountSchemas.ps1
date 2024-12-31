param(
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
    param(
        [Parameter(Mandatory = $true)][System.IO.FileInfo] $Schema
    )

    $schemaName = $Schema.Name
    if ($RemoveFileExtensions) {
        $schemaName = $Schema.BaseName
    }
    if ($ArtifactsPrefix -ne '') {
        $schemaName = $ArtifactsPrefix + $schemaName
    }
    Write-Verbose "Uploading schema '$schemaName' into the Azure Integration Account '$Name'..."

    $existingSchema = $null
    try {
        Write-Verbose "Checking if the schema '$schemaName' already exists in the Azure Integration Account '$Name'"
        $existingSchema = Get-AzIntegrationAccountSchema -ResourceGroupName $ResourceGroupName -Name $Name -SchemaName $schemaName -ErrorAction Stop
    } catch {
        if ($_.Exception.Message.Contains('could not be found')) {
            Write-Warning "No schema '$schemaName' could not be found in Azure Integration Account '$Name'"
        } else {
            throw $_.Exception
        }
    }
        
    try {
        if ($null -eq $existingSchema) {
            Write-Verbose "Creating schema '$schemaName' in Azure Integration Account '$Name'..."
            $createdSchema = New-AzIntegrationAccountSchema -ResourceGroupName $ResourceGroupName -Name $Name -SchemaName $schemaName -SchemaFilePath $schema.FullName -ErrorAction Stop
            Write-Debug ($createdSchema | Format-List -Force | Out-String)
        } else {
            Write-Verbose "Updating schema '$schemaName' in Azure Integration Account '$Name'..."
            $updatedSchema = Set-AzIntegrationAccountSchema -ResourceGroupName $ResourceGroupName -Name $Name -SchemaName $schemaName -SchemaFilePath $schema.FullName -ErrorAction Stop -Force
            Write-Debug ($updatedSchema | Format-List -Force | Out-String)
        }
        Write-Host "Schema '$schemaName' has been uploaded into the Azure Integration Account '$Name'" -ForegroundColor Green
    } catch {
        Write-Error "Failed to upload schema '$schemaName' in Azure Integration Account '$Name'. Details: '$($_.Exception.Message)'"
    }
}

$integrationAccount = Get-AzIntegrationAccount -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction SilentlyContinue
if ($null -eq $integrationAccount) {
    Write-Error "Unable to find the Azure Integration Account with name '$Name' in resource group '$ResourceGroupName'"
} else {
    if ($SchemasFolder -ne '' -and $SchemaFilePath -eq '') {
        foreach ($schema in Get-ChildItem($schemasFolder) -File) {
            UploadSchema -Schema $schema
        }
    } elseif ($schemasFolder -eq '' -and $SchemaFilePath -ne '') {
        [System.IO.FileInfo]$schema = New-Object System.IO.FileInfo("$SchemaFilePath")
        UploadSchema -Schema $schema
    }
}

