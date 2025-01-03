Import-Module Az.KeyVault
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.KeyVault -ErrorAction Stop

InModuleScope Arcus.Scripting.KeyVault {
    Describe "Arcus Azure Key Vault integration tests" {
        BeforeEach {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1 
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
        }
        Context "Set secret from file" {
            It "Set secret in Key Vault" {
                # Arrange
                $expected = [System.Guid]::NewGuid().ToString()
                $file = New-Item -Path "test-file.txt" -ItemType File -Value $expected
                $secretName = "Arcus-Scripting-KeyVault-MySecret-$([System.Guid]::NewGuid())"
                try {
                    # Act
                    Set-AzKeyVaultSecretFromFile -KeyVaultName $config.Arcus.KeyVault.VaultName -SecretName $secretName -FilePath $file.FullName

                    # Assert
                    $actual = Get-AzKeyVaultSecret -VaultName $config.Arcus.KeyVault.VaultName -Name $secretName -AsPlainText
                    $actual | Should -Be $expected

                } finally {
                    Remove-Item -Path $file.FullName
                    Remove-AzKeyVaultSecret -VaultName $config.Arcus.KeyVault.VaultName -Name $secretName -PassThru -Force
                }
            }
            It "Set secret as BASE64 in Key Vault" {
                # Arrange
                $expected = [System.Guid]::NewGuid().ToString()
                $file = New-Item -Path "test-base64-file.txt" -ItemType File -Value $expected
                $secretName = "Arcus-Scripting-KeyVault-MySecret-$([System.Guid]::NewGuid())"
                try {
                    # Act
                    Set-AzKeyVaultSecretAsBase64FromFile -KeyVaultName $config.Arcus.KeyVault.VaultName -SecretName $secretName -FilePath $file.FullName

                    # Assert
                    $actual = Get-AzKeyVaultSecret -VaultName $config.Arcus.KeyVault.VaultName -Name $secretName -AsPlainText
                    [System.Convert]::FromBase64String($actual) |
                    ForEach-Object { [System.Text.Encoding]::UTF8.GetString($_) } |
                    Should -Be $expected.ToCharArray()
                } finally {
                    Remove-Item -Path $file.FullName
                    Remove-AzKeyVaultSecret -VaultName $config.Arcus.KeyVault.VaultName -Name $secretName -PassThru -Force
                }
            }
            It "Set secret in Key Vault with expiration date" {
                # Arrange
                $expected = [System.Guid]::NewGuid().ToString()
                $file = New-Item -Path "test-file.txt" -ItemType File -Value $expected
                $secretName = "Arcus-Scripting-KeyVault-MySecret-$([System.Guid]::NewGuid())"
                $expirationDate = (Get-Date).AddDays(7).ToUniversalTime()
                $expirationDate = $expirationDate.AddTicks(-$expirationDate.Ticks)

                try {
                    # Act
                    Set-AzKeyVaultSecretFromFile -KeyVaultName $config.Arcus.KeyVault.VaultName -SecretName $secretName -Expires $expirationDate -FilePath $file.FullName

                    # Assert
                    $actual = Get-AzKeyVaultSecret -VaultName $config.Arcus.KeyVault.VaultName -Name $secretName
                    $actual.Expires | Should -Be $expirationDate
                } finally {
                    Remove-Item -Path $file.FullName
                    Remove-AzKeyVaultSecret -VaultName $config.Arcus.KeyVault.VaultName -Name $secretName -PassThru -Force
                }
            }
            It "Set secret as BASE64 in Key Vault with expiration date" {
                # Arrange
                $expected = [System.Guid]::NewGuid().ToString()
                $file = New-Item -Path "test-base64-file.txt" -ItemType File -Value $expected
                $secretName = "Arcus-Scripting-KeyVault-MySecret-$([System.Guid]::NewGuid())"
                $expirationDate = (Get-Date).AddDays(7).ToUniversalTime()
                $expirationDate = $expirationDate.AddTicks(-$expirationDate.Ticks)

                try {
                    # Act
                    Set-AzKeyVaultSecretAsBase64FromFile -KeyVaultName $config.Arcus.KeyVault.VaultName -SecretName $secretName -Expires $expirationDate -FilePath $file.FullName
                
                    # Assert
                    $actual = Get-AzKeyVaultSecret -VaultName $config.Arcus.KeyVault.VaultName -Name $secretName
                    $actual.Expires | Should -Be $expirationDate
                    $actual = Get-AzKeyVaultSecret -VaultName $config.Arcus.KeyVault.VaultName -Name $secretName -AsPlainText
                    [System.Convert]::FromBase64String($actual) |
                    ForEach-Object { [System.Text.Encoding]::UTF8.GetString($_) } |
                    Should -Be $expected.ToCharArray()

                } finally {
                    Remove-Item -Path $file.FullName
                    Remove-AzKeyVaultSecret -VaultName $config.Arcus.KeyVault.VaultName -Name $secretName -PassThru -Force
                }
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
        Context "Get access policies" {
            It "Get access policies with resource group" {
                # Act
                $policies = Get-AzKeyVaultAccessPolicies -KeyVaultName $config.Arcus.KeyVault.VaultName -ResourceGroupName $config.Arcus.ResourceGroupName

                # Assert
                $policies.list | Should -Not -BeNullOrEmpty
            }
            It "Get access policies without resource group" {
                # Act
                $policies = Get-AzKeyVaultAccessPolicies -KeyVaultName $config.Arcus.KeyVault.VaultName

                # Assert
                $policies.list | Should -Not -BeNullOrEmpty
            }
        }
    }
}