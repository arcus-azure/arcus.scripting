param(
   [string][parameter(Mandatory = $true)] $keyVaultName,
   [string][parameter(Mandatory = $false)] $resourceGroupName = ""
)

$keyVault = $null
if($resourceGroupName -eq '')
{
	Write-Host "Looking for the Key Vault with name '$keyVaultName'."
	$keyVault = Get-AzKeyVault -VaultName $keyVaultName
}
else
{
	Write-Host "Looking for the Key Vault with name '$keyVaultName' in resourcegroup '$resourceGroupName'"
	$keyVault = Get-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName
}

if($keyVault)
{
	$armAccessPolicies = @()
	$keyVaultAccessPolicies = $keyVault.accessPolicies

	if($keyVaultAccessPolicies)
	{
	   Write-Host "Key Vault '$keyVaultName' is found."

	   foreach($keyVaultAccessPolicy in $keyVaultAccessPolicies)
	   {
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

	Write-Host "Current access policies: $armAccessPoliciesParameter"
	return $armAccessPoliciesParameter
}
else
{
	Write-Host "KeyVault '$keyVaultName' could not be found."
}