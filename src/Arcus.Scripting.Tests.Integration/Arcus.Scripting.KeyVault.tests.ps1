Import-Module Az.KeyVault
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.KeyVault -ErrorAction Stop

Describe "Arcus" {
    Context "KeyVault" {
        InModuleScope Arcus.Scripting.KeyVault {
            BeforeAll {
                [string]$appsettings = Get-Content "$PSScriptRoot\appsettings.local.json"
                $config = ConvertFrom-Json $appsettings

                $clientSecret = ConvertTo-SecureString $config.Arcus.ServicePrincipal.ClientSecret -AsPlainText
                $pscredential = New-Object -TypeName System.Management.Automation.PSCredential($config.Arcus.ServicePrincipal.ClientId, $clientSecret)
                Connect-AzAccount -Credential $pscredential -TenantId $config.Arcus.TenantId -ServicePrincipal
            }
            It "Set secret in Key Vault" {
                # Arrange
                $expected = [System.Guid]::NewGuid().ToString()
                $file = New-Item -Path "test-file.txt" -ItemType File -Value $expected
                $secretName = "Arcus-Scripting-KeyVault-MySecret"
                try {
                    # Act
                    Set-AzKeyVaultSecretFromFile -KeyVaultName $config.Arcus.KeyVault.VaultName -SecretName $secretName -FilePath $file.FullName

                    # Assert
                    $actual = Get-AzureKeyVaultSecret -VaultName $config.Arcus.KeyVault.VaultName -Name $secretName -AsPlainText
                    $actual | Should -Be $expected

                } finally {
                    Remove-Item -Path $file.FullName
                    Remove-AzKeyVaultSecret -VaultName $config.Arcus.KeyVault.VaultName -Name $secretName -PassThru -Force
                }
            }
            It "Set secret as BASE64 in Key Vault" {
                $contents = "this is the base64 secret certificate field contents"
                $file = New-Item -Path "test-base64-file.txt" -ItemType File -Value $contents
                try {
                    # Arrange
                    $keyVault = "key vault"
                    $secretName = "secret name"

                    Mock Set-AzKeyvaultSecret {
                        ConvertFrom-SecureString -SecureString $SecretValue -AsPlainText |
                            % { [System.Convert]::FromBase64String($_) } |
                            Should -Be ([System.Text.Encoding]::UTF8.GetBytes($contents))
                        $KeyVault | Should -Be $keyVault
                        $SecretName | Should -Be $secretName } -Verifiable

                    # Act
                    Set-AzKeyVaultSecretAsBase64FromFile -KeyVaultName $keyVault -SecretName $secretName -FilePath $file.FullName

                    # Assert
                    Assert-VerifiableMock
                } finally {
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
                    $ExpirationDate | Should -Be $expirationDate } -Verifiable

                # Act
                Set-AzKeyVaultSecretFromFile -KeyVaultName $keyVault -SecretName $secretName -Expires $expirationDate -FilePath "/filepath"

                # Assert
                Assert-VerifiableMock
            }
            It "Set secret as BASE64 in Key Vault with expiration date" {
                # Arrange
                $contents = [System.Text.Encoding]::UTF8.GetBytes("this is the BASE64 secret certificate field contents")
                $keyVault = "key vault"
                $secretName = "secret name"
                $expirationDate = (Get-Date).AddDays(5).ToUniversalTime()

                Mock Test-Path { return $true }
                Mock Get-Content { return $contents }
                Mock Set-AzKeyvaultSecret {
                    ConvertFrom-SecureString -SecureString $SecretValue -AsPlainText |
                        % { [System.Convert]::FromBase64String($_) } |
                        Should -Be $contents
                    $KeyVault | Should -Be $keyVault
                    $SecretName | Should -Be $secretName
                    $ExpirationDate | Should -Be $expirationDate } -Verifiable

                # Act
                Set-AzKeyVaultSecretAsBase64FromFile -KeyVaultName $keyVault -SecretName $secretName -Expires $expirationDate -FilePath "/filepath"

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
                Assert-MockCalled Set-AzKeyVaultSecret -Times 0
            }
            It "Set secret as BASE64 in Key Vault fails when file is not found" {
                # Arrange
                $contents = "this is the BASE64 secret certificate field contents"
                $keyVault = "key vault"
                $secretName = "secret name"

                Mock Set-AzKeyVaultSecret { }

                # Act
                { Set-AzKeyVaultSecretAsBase64FromFile -KeyVaultName $keyVault -SecretName $secretName -FilePath "/not-existing-filepath" } |
                    Should -Throw

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Set-AzKeyVaultSecret -Times 0
            }
        }
    }
}