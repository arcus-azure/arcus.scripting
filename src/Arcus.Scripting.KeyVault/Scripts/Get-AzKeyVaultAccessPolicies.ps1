param(
   [Parameter(Mandatory = $true)][string] $KeyVaultName = $(throw "Name of the Azure Key Vault is required"),
   [Parameter(Mandatory = $false)][string] $ResourceGroupName = ""
)

$keyVault = $null
if($resourceGroupName -eq '') {
    Write-Verbose "Looking for the Azure Key Vault with name '$keyVaultName'..."
    $keyVault = Get-AzKeyVault -VaultName $keyVaultName
} else {
    Write-Verbose "Looking for the Azure Key Vault with name '$keyVaultName' in resourcegroup '$resourceGroupName'.."
    $keyVault = Get-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName
}

$armAccessPolicies = @()
if($keyVault) {    
    Write-Verbose "Found Azure Key Vault '$keyVaultName'"
    
    $keyVaultAccessPolicies = $keyVault.accessPolicies
    if($keyVaultAccessPolicies)
    {    
       foreach($keyVaultAccessPolicy in $keyVaultAccessPolicies) {
          $armAccessPolicy = [pscustomobject]@{
             tenantId = $keyVaultAccessPolicy.TenantId
             objectId = $keyVaultAccessPolicy.ObjectId
          }

          $armAccessPolicyPermissions = [pscustomobject]@{
             keys =  $keyVaultAccessPolicy.PermissionsToKeys
             secrets = $keyVaultAccessPolicy.PermissionsToSecrets
             certificates = $keyVaultAccessPolicy.PermissionsToCertificates
             storage = $keyVaultAccessPolicy.PermissionsToStorage
          }

          Write-Verbose "Azure Key Vault access policy successfully retrieved for TenantId: $($armAccessPolicy.tenantId) and ObjectId: $($armAccessPolicy.ObjectId)"
          Write-Verbose ($armAccessPolicyPermissions | Format-list | Out-String) 

          $armAccessPolicy | Add-Member -MemberType NoteProperty -Name permissions -Value $armAccessPolicyPermissions
          $armAccessPolicies += $armAccessPolicy
       }       
       
        Write-Host "Successfully retrieved Access Policies"
    }    
} else {
    Write-Warning "Azure Key Vault '$keyVaultName' could not be found, please check if the provided vault name and/or resource group name is correct."
}

$armAccessPoliciesParameter = [pscustomobject]@{
    list = $armAccessPolicies
}

return $armAccessPoliciesParameter
