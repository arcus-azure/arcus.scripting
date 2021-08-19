param (
    [Parameter(ParameterSetName = "Resource", Mandatory = $true)]
    [Parameter(ParameterSetName = "Object", Mandatory = $true)]
    [string] $TargetResourceGroupName = $(throw "Target resource group name to which access should be granted is required"),
    
    [Parameter(ParameterSetName = "Resource", Mandatory = $true)]
    #[ValidateScript({ if ($_) { return $true } else { throw "Resource group name where the resource is located which should be granted access is required" } })]
    [string] $ResourceGroupName,
    
    [Parameter(ParameterSetName = "Resource", Mandatory = $true)]
    #[ValidateScript({ if ($_) { return $true } else { throw "Name of the resource which should be granted access is required" } })]
    [string] $ResourceName,
    
    [Parameter(ParameterSetName = "Object", Mandatory = $true)]
    #[ValidateScript({ if ($_) { return $true } else { throw "ObjectId of the resource that needs to get a role assigned" }  })] 
    [string] $ObjectId,

    [Parameter(ParameterSetName = "Resource", Mandatory = $true)]
    [Parameter(ParameterSetName = "Object", Mandatory = $true)]
    [string] $RoleDefinitionName = $(throw "Name of the role definition is required")
)

$resourcePrincipalId = $null
if ($PSCmdlet.ParameterSetName -eq "Resource") {
    Write-Host "Assigning $RoleDefinitionName-rights to the '$ResourceName' in the resource group '$ResourceGroupName' to gain access to the '$TargetResourceGroupName'"
    $resource = Get-AzResource -ResourceGroupName $ResourceGroupName -Name $ResourceName
    [guid] $resourcePrincipalId = $resource.identity.PrincipalId
}
if ($PSCmdlet.ParameterSetName -eq "Object") {
    Write-Host "Assigning $RoleDefinitionName-rights for the identity '$ObjectId' to gain access to the '$TargetResourceGroupName'"
    $resourcePrincipalId = $ObjectId
}

try {
    New-AzRoleAssignment -ObjectId $resourcePrincipalId -RoleDefinitionName $RoleDefinitionName -ResourceGroupName $TargetResourceGroupName -ErrorAction Stop -Verbose
    Write-Host "$RoleDefinitionName access granted!"
} catch {
    $ErrorMessage = $_.Exception.Message
    if ($ErrorMessage.Contains("already exists")) {
        Write-Host "Access has already been granted"
    } else {
        Write-Warning "Failed to grant access: $($_.Exception)"
        throw "Failed to graint $RoleDefinitionName-rights to the '$ResourceName' in the '$ResourceGroupName' to gain access to the '$TargetResourceGroupName'"
    }
}