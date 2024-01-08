param(
    [Parameter(Mandatory = $true)][string] $TargetResourceGroupName = $(throw "Target resource group name to which access should be granted is required"),
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name where the resource is located which should be granted access is required"),
    [Parameter(Mandatory = $true)][string] $ResourceName = $(throw "Name of the resource which should be granted access is required"),
    [Parameter(Mandatory = $true)][string] $RoleDefinitionName = $(throw "Name of the role definition is required")
)

Write-Verbose "Assigning $RoleDefinitionName-rights to the '$ResourceName' in the resource group '$ResourceGroupName' to gain access to the resource group '$TargetResourceGroupName'..."

try {
    $resource = Get-AzResource -ResourceGroupName $ResourceGroupName -Name $ResourceName
    [guid] $resourcePrincipalId = $resource.identity.PrincipalId
    
    New-AzRoleAssignment -ObjectId $resourcePrincipalId -RoleDefinitionName $RoleDefinitionName -ResourceGroupName $TargetResourceGroupName -ErrorAction Stop
    Write-Host "Granted $RoleDefinitionName-rights to the '$ResourceName' in the resource group '$ResourceGroupName' to gain access to the resource group '$TargetResourceGroupName'" -ForegroundColor Green
} catch {
    $ErrorMessage = $_.Exception.Message
    if ($ErrorMessage.Contains("already exists")) {
        Write-Warning "Access of $RoleDefinition-rights has already been granted to the '$ResourceName' in the resource group '$ResourceGroupName' to gain access to the resource group '$TargetResourceGroupName'"
    } else {
        Write-Warning "Failed to grant access of $RoleDefinition-rights to the '$ResourceName' in the resource group '$ResourceGroupName' to gain access to the resource group '$TargetResourceGroupName'"
        Write-Debug $ErrorMessage
    }
}