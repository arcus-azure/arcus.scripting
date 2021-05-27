param(
   [string][parameter(Mandatory = $true)] $keyVaultName,
   [string][parameter(Mandatory = $false)] $resourceGroupName = ""
)

$keyVault = $null
if($resourceGroupName -eq '') {
    Write-Verbose "Looking for the Azure Key Vault with name '$keyVaultName'..."
    $keyVault = Get-AzKeyVault -VaultName $keyVaultName
} else {
    Write-Verbose "Looking for the Azure Key Vault with name '$keyVaultName' in resourcegroup '$resourceGroupName'.."
    $keyVault = Get-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName
}

if($keyVault) {
    $armAccessPolicies = @()
    $keyVaultAccessPolicies = $keyVault.accessPolicies

    if($keyVaultAccessPolicies) {
       Write-Verbose "Found Azure Key Vault '$keyVaultName'"

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

          $armAccessPolicy | Add-Member -MemberType NoteProperty -Name permissions -Value $armAccessPolicyPermissions
          $armAccessPolicies += $armAccessPolicy
       }   
    }

    $armAccessPoliciesParameter = [pscustomobject]@{
        list = $armAccessPolicies
    }

    Write-Host "Current Azure Key Vault access policies: $armAccessPoliciesParameter"
    return $armAccessPoliciesParameter
} else {
    Write-Warning "Azure Key Vault '$keyVaultName' could not be found, please check if the vault has the correct name and is located in the resource group you specified"
}
