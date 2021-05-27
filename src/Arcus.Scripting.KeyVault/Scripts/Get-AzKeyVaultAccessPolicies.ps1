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

          $armAccessPolicy | Add-Member -MemberType NoteProperty -Name permissions -Value $armAccessPolicyPermissions
          $armAccessPolicies += $armAccessPolicy
       }   
    }    
} else {
    Write-Warning "Azure Key Vault '$keyVaultName' could not be found, please check if the vault has the correct name and is located in the resource group you specified"
}

$armAccessPoliciesParameter = [pscustomobject]@{
    list = $armAccessPolicies
}

Write-Host "Current access policies: $armAccessPoliciesParameter"
return $armAccessPoliciesParameter
