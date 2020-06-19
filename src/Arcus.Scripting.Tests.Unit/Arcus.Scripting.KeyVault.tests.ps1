Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.KeyVault -ErrorAction Stop

Describe "Arcus" {
    Context "KeyVault" {
        InModuleScope Arcus.Scripting.KeyVault {
            It "Get Key Vault access policies" {
                # Arrange
                $tenantId = "my tenant"
                $objectId = "my object"
                $keyPermissions = "my key permissions"
                $secretPermissions = "my secret permissions"
                $certificatePermissions = "my certificate permissions"
                $storagePermissions = "my storage permissions"
                $accessPolicy = [pscustomobject]@{
                  TenantId = $tenantId
                  ObjectId = $objectId
                  PermissionsToKeys = $keyPermissions
                  PermissionsToSecrets = $secretPermissions
                  PermissionsToCertificates = $certificatePermissions
                  PermissionsToStorage = $storagePermissions }
                
                Mock Get-AzKeyVault { return [pscustomobject]@{ accessPolicies = @($accessPolicy) }  }
                
                # Act
                $accessPoliciesParameter = Get-AzKeyVaultAccessPolicies -KeyVaultName "key vault" -ResourceGroupName "resource group name"
                
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
            It "Set secret in Key Vault" {
                # Arrange
                $contents = "this is the raw secret certificate field contents"
                $expectedSecretValue = ConvertTo-SecureString -AsPlainText -Force $contents
                $keyVault = "key vault"
                $secretName = "secret name"

                Mock Get-Content { return $contents }
                Mock Set-AzKeyVaultSecret {
                    $SecretValue | Should -Be $expectedSecretValue 
                    $KeyVault | Should -Be $keyVault
                    $SecretName | Should -Be $secretName } -Verifiable

                # Act
                Set-AzKeyVaultSecretFromFile -FilePath "/filepath" -KeyVaultName $keyVault -SecretName $secretName

                # Assert
                Assert-VerifiableMock
            }
        }
    }
}