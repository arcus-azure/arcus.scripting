Param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
    [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the Integration Account is required"),
    [parameter(Mandatory = $false)][string] $MapFilePath = $(if ($MapsFolder -eq '') { throw "Either the file path of a specific map or the file path of a folder containing multiple maps is required, e.g.: -MapFilePath 'C:\Maps\map.xslt' or -MapsFolder 'C:\Maps'" }),
    [parameter(Mandatory = $false)][string] $MapsFolder = $(if ($MapFilePath -eq '') { throw "Either the file path of a specific map or the file path of a folder containing multiple maps is required, e.g.: -MapFilePath 'C:\Maps\map.xslt' or -MapsFolder 'C:\Maps'" }),
    [Parameter(Mandatory = $false)][string] $MapType = 'Xslt',
    [Parameter(Mandatory = $false)][string] $ArtifactsPrefix = '',
    [Parameter(Mandatory = $false)][switch] $RemoveFileExtensions = $false
)

if ($MapFilePath -ne '' -and $MapsFolder -ne '') {
    throw "Either the file path of a specific map or the file path of a folder containing multiple maps is required, e.g.: -MapFilePath 'C:\Maps\map.xslt' or -MapsFolder 'C:\Maps'"
}

function UploadMap {
    param
    (
        [System.IO.FileInfo][parameter(Mandatory = $true)]$Map
    )

    $mapName = $Map.Name
    if ($RemoveFileExtensions) {
        $mapName = $Map.BaseName
    }
    if ($ArtifactsPrefix -ne '') {
        $mapName = $ArtifactsPrefix + $mapName
    }
    Write-Host "Uploading map '$mapName' into the Integration Account '$Name'."

    $existingMap = $null
    try {
        Write-Verbose "Checking if the map '$mapName' already exists in the Integration Account '$Name'."
        $existingMap = Get-AzIntegrationAccountMap -ResourceGroupName $ResourceGroupName -Name $Name -MapName $mapName -ErrorAction Stop
    }
    catch {
        if ($_.Exception.Message.Contains('could not be found')) {
            Write-Verbose "No map '$mapName' could not be found in Azure Integration Account '$Name'."
        }
        else {
            throw $_.Exception
        }
    }
        
    try {
        if ($existingMap -eq $null) {
            Write-Verbose "Creating map '$mapName' in Azure Integration Account '$Name'"
            $createdMap = New-AzIntegrationAccountMap -ResourceGroupName $ResourceGroupName -Name $Name -MapName $mapName -MapType $MapType -MapFilePath $Map.FullName -ErrorAction Stop
            Write-Verbose ($createdMap | Format-List -Force | Out-String)
        }
        else {
            Write-Verbose "Updating map '$mapName' in Azure Integration Account '$Name'"
            $updatedMap = Set-AzIntegrationAccountMap -ResourceGroupName $ResourceGroupName -Name $Name -MapName $mapName -MapFilePath $Map.FullName -ErrorAction Stop -Force
            Write-Verbose ($updatedMap | Format-List -Force | Out-String)
        }
        Write-Host "Map '$mapName' has been uploaded into the Azure Integration Account '$Name'."
    }
    catch {
        Write-Error "Failed to upload map '$mapName' in Azure Integration Account '$Name': '$($_.Exception.Message)_'"
    }
}

# Verify if Integration Account can be found based on the given information
$integrationAccount = Get-AzIntegrationAccount -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction SilentlyContinue
if ($integrationAccount -eq $null) {
    Write-Error "Unable to find the Azure Integration Account with name '$Name' in resource group '$ResourceGroupName'"
}
else {
    if ($MapsFolder -ne '' -and $MapFilePath -eq '') {
        foreach ($map in Get-ChildItem($MapsFolder) -File) {
            UploadMap -Map $map
            Write-Host '----------'
        }
    }
    elseif ($MapsFolder -eq '' -and $MapFilePath -ne '') {
        [System.IO.FileInfo]$map = New-Object System.IO.FileInfo($MapFilePath)
        UploadMap -Map $map
    }
}