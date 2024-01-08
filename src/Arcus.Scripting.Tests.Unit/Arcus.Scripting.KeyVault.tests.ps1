Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.KeyVault -ErrorAction Stop

InModuleScope Arcus.Scripting.KeyVault {
    Describe "Arcus Azure Key Vault unit tests" {
        Context "Getting Azure Key Vault access policies" {
            It "Get Key Vault access policies based on vault name and resource group name succeeds" {
                # Arrange
                $tenantId = "my tenant"
                $objectId = "my object"
                $keyPermissions = "my key permissions"
                $secretPermissions = "my secret permissions"
                $certificatePermissions = "my certificate permissions"
                $storagePermissions = "my storage permissions"
                $accessPolicy = [pscustomobject]@{
                    TenantId                  = $tenantId
                    ObjectId                  = $objectId
                    PermissionsToKeys         = $keyPermissions
                    PermissionsToSecrets      = $secretPermissions
                    PermissionsToCertificates = $certificatePermissions
                    PermissionsToStorage      = $storagePermissions 
                }
                
                Mock Get-AzKeyVault { return [pscustomobject]@{ accessPolicies = @($accessPolicy) } }
                
                # Act
                $accessPoliciesParameter = Get-AzKeyVaultAccessPolicies -KeyVaultName "key vault" -ResourceGroupName "resource group name" -verbose
                
                # Assert
                $accessPolicies = $accessPoliciesParameter.list
                $expected = $accessPolicies[0]

                $expected.tenantId | Should -Be $tenantId
                $expected.objectId | Should -Be $objectId
                $expected.permissions.keys | Should -Be $keyPermissions
                $expected.permissions.secrets | Should -Be $secretPermissions
                $expected.permissions.certificates | Should -Be $certificatePermissions
                $expected.permissions.storage | Should -Be $storagePermissions
            }
        }
    }
}
