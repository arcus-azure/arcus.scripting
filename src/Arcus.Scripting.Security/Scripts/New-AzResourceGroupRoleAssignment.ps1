param (
    [Parameter(Mandatory = $true)][string] $TargetResourceGroupName = $(throw "Target resource group name to which access should be granted is required"),
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Resource group name where the resource is located which should be granted access is required"),
    [Parameter(Mandatory = $true)][string] $ResourceName = $(throw "Name of the resource which should be granted access is required"),
    [Parameter(Mandatory = $true)][string] $RoleDefinitionName = $(throw "Name of the role definition is required")
)

Write-Host "Assigning $RoleDefinitionName-rights to the '$ResourceName' in the resource group '$ResourceGroupName' to gain access to the '$TargetResourceGroupName'"

try {
    $resource = Get-AzResource -ResourceGroupName $ResourceGroupName -Name $ResourceName
    [guid] $resourcePrincipalId = $resource.identity.PrincipalId
    
    New-AzRoleAssignment -ObjectId $resourcePrincipalId -RoleDefinitionName $RoleDefinitionName -ResourceGroupName $TargetResourceGroupName -ErrorAction Stop
    Write-Host "$RoleDefinitionName access granted!"
} catch {
    $ErrorMessage = $_.Exception.Message
    if ($ErrorMessage.Contains("already exists")) {
        Write-Host "Access has already been granted"
    } else {
        Write-Warning "Failed to grant access!"
        Write-Warning $ErrorMessage
    }
}