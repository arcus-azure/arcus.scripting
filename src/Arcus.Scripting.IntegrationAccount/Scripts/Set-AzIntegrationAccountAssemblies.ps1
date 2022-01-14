Param(
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name is required"),
    [Parameter(Mandatory = $true)][string] $Name = $(throw "Name of the Integration Account is required"),
    [parameter(Mandatory = $false)][string] $AssemblyFilePath = $(if ($AssembliesFolder -eq '') { throw "Either the file path of a specific assembly or the file path of a folder containing multiple assemblies is required, e.g.: -AssemblyFilePath 'C:\Assemblies\assembly.dll' or -AssembliesFolder 'C:\Assemblies'" }),
    [parameter(Mandatory = $false)][string] $AssembliesFolder = $(if ($AssemblyFilePath -eq '') { throw "Either the file path of a specific assembly or the file path of a folder containing multiple assemblies is required, e.g.: -AssemblyFilePath 'C:\Assemblies\assembly.dll' or -AssembliesFolder 'C:\Assemblies'" }),
    [Parameter(Mandatory = $false)][string] $ArtifactsPrefix = ''
)

if ($AssemblyFilePath -ne '' -and $AssembliesFolder -ne '') {
    throw "Either the file path of a specific assembly or the file path of a folder containing multiple assemblies is required, e.g.: -AssemblyFilePath 'C:\Assemblies\assembly.dll' or -AssembliesFolder 'C:\Assemblies'"
}

function UploadAssembly {
    param
    (
        [Parameter(Mandatory = $true)][System.IO.FileInfo] $Assembly
    )

    $assemblyName = $Assembly.BaseName
    if ($ArtifactsPrefix -ne '') {
        $assemblyName = $ArtifactsPrefix + $assemblyName
    }
    Write-Host "Uploading assembly '$assemblyName' into the Azure Integration Account '$Name'"

    $existingAssembly = $null
    try {
        Write-Verbose "Checking if the assembly '$assemblyName' already exists in the Azure Integration Account '$Name'"
        $existingAssembly = Get-AzIntegrationAccountAssembly -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -Name $assemblyName -ErrorAction Stop
    }
    catch {
        if ($_.Exception.Message.Contains('could not be found')) {
            Write-Verbose "No assembly '$assemblyName' could not be found in Azure Integration Account '$Name'"
        }
        else {
            throw $_.Exception
        }
    }
        
    try {
        if ($existingAssembly -eq $null) {
            Write-Verbose "Creating assembly '$assemblyName' in Azure Integration Account '$Name'"
            $createdAssembly = New-AzIntegrationAccountAssembly -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -Name $assemblyName -AssemblyFilePath $Assembly.FullName -ErrorAction Stop
            Write-Verbose ($createdAssembly | Format-List -Force | Out-String)
        }
        else {
            Write-Verbose "Updating assembly '$assemblyName' in Azure Integration Account '$Name'"
            $updatedAssembly = Set-AzIntegrationAccountAssembly -ResourceGroupName $ResourceGroupName -IntegrationAccount $Name -Name $assemblyName -AssemblyFilePath $Assembly.FullName -ErrorAction Stop
            Write-Verbose ($updatedAssembly | Format-List -Force | Out-String)
        }
        Write-Host "Assembly '$assemblyName' has been uploaded into the Azure Integration Account '$Name'"
    }
    catch {
        Write-Error "Failed to upload assembly '$assemblyName' in Azure Integration Account '$Name': '$($_.Exception.Message)'"
    }
}

$integrationAccount = Get-AzIntegrationAccount -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction SilentlyContinue
if ($integrationAccount -eq $null) {
    Write-Error "Unable to find the Azure Integration Account with name '$Name' in resource group '$ResourceGroupName'"
}
else {
    if ($AssembliesFolder -ne '' -and $AssemblyFilePath -eq '') {
        foreach ($assembly in Get-ChildItem($AssembliesFolder) -File) {
            UploadAssembly -Assembly $assembly
            Write-Host '----------'
        }
    }
    elseif ($AssembliesFolder -eq '' -and $AssemblyFilePath -ne '') {
        [System.IO.FileInfo]$assembly = New-Object System.IO.FileInfo($AssemblyFilePath)
        UploadAssembly -Assembly $assembly
    }
}