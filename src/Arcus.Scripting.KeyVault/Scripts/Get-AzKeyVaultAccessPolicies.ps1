param(
   [Parameter(Mandatory = $true)][string] $KeyVaultName = $(throw "Name of the Azure Key Vault is required"),
   [Parameter(Mandatory = $false)][string] $ResourceGroupName = ""
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

$armAccessPolicies = @()

if($keyVault)
{	
	Write-Host "Key Vault '$keyVaultName' is found."

	$keyVaultAccessPolicies = $keyVault.accessPolicies

	if($keyVaultAccessPolicies)
	{	
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
}
else
{
	Write-Warning "KeyVault '$keyVaultName' could not be found."
}

$armAccessPoliciesParameter = [pscustomobject]@{
	list = $armAccessPolicies
}

Write-Host "Current access policies: $armAccessPoliciesParameter"
return $armAccessPoliciesParameter