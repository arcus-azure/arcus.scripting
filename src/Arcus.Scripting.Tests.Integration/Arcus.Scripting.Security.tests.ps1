Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Security -ErrorAction Stop

function global:Load-AppSettings {
    $filePath = "$PSScriptRoot\appsettings.json"
    [string]$appsettings = Get-Content $filePath
    return ConvertFrom-Json $appsettings
}

function global:Connect-AzAccountFromConfig ($config) {
    & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
}

InModuleScope Arcus.Scripting.Security {
    Describe "Arcus Azure security integration tests" {
        Context "Get cached access token" {
            It "Get cached access token from current active authenticated Azure session succeeds" {
                # Arrange
                $config = Load-AppSettings
                Connect-AzAccountFromConfig $config

                # Act
                $token = Get-AzCachedAccessToken

                # Assert
                $token | Should -Not -Be $null
                $token.SubscriptionId | Should -Be $config.Arcus.SubscriptionId
                $token.AccessToken | Should -Not -BeNullOrEmpty
            }
              It "Get cached access token from current unative authenticated Azure session fails" {
                # Arrange
                $config = Load-AppSettings
                Disconnect-AzAccount -TenantId $config.Arcus.TenantId -ApplicationId $config.Arcus.ServicePrincipal.ClientId

                # Act
                { Get-AzCachedAccessToken } | Should -Throw
            }
        }
    }
}
