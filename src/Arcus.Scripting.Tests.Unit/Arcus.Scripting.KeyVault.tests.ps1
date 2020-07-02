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
                $contents = "this is the raw secret certificate field contents"
                $file = New-Item -Path "test-file.txt" -ItemType File -Value $contents
                try {
                    # Arrange
                    $keyVault = "key vault"
                    $secretName = "secret name"
                
                    Mock Set-AzKeyVaultSecret {
                        ConvertFrom-SecureString -SecureString $SecretValue -AsPlainText | Should -Be $contents
                        $KeyVault | Should -Be $keyVault
                        $SecretName | Should -Be $secretName } -Verifiable

                    # Act
                    Set-AzKeyVaultSecretFromFile -KeyVaultName $keyVault -SecretName $secretName -FilePath $file.FullName

                    # Assert
                    Assert-VerifiableMock
                } catch {
                    Remove-Item -Path $file.FullName    
                }
            }
            It "Set secret in Key Vault with expiration date" {
                # Arrange
                $contents = "this is the raw secret certificate field contents"
                $keyVault = "key vault"
                $secretName = "secret name"
                $expirationDate = (Get-Date).AddDays(7).ToUniversalTime()
                
                Mock Test-Path { return $true }
                Mock Get-Content { return $contents }
                Mock Set-AzKeyVaultSecret {
                    ConvertFrom-SecureString -SecureString $SecretValue -AsPlainText | Should -Be $contents
                    $KeyVault | Should -Be $keyVault
                    $SecretName | Should -Be $secretName
                    $expirationDate | Should -Be $expirationDate } -Verifiable

                # Act
                Set-AzKeyVaultSecretFromFile -KeyVaultName $keyVault -SecretName $secretName -Expires $expirationDate -FilePath "/filepath"

                # Assert
                Assert-VerifiableMock
            }
            It "Set secret in Key Vault fails when file is not found" {
                # Arrange
                $contents = "this is the raw secret certificate field contents"
                $keyVault = "key vault"
                $secretName = "secret name"
                
                Mock Set-AzKeyVaultSecret { }
                
                # Act
                { Set-AzKeyVaultSecretFromFile -KeyVaultName $keyVault -SecretName $secretName -FilePath "/not-existing-filepath" } |
                    Should -Throw
                
                # Assert
                Assert-VerifiableMock
                Mock-Called Set-AzKeyVaultSecret -Times 0
            }
        }
    }
}
