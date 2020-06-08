Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.PS.KeyVault -ErrorAction Stop

Describe "Arcus" {
  Context "KeyVault" {
    InModuleScope Arcus.Scripting.PS.KeyVault {
      It "Get KeyVault access policies" {
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
        Mock Write-Host {
          # Assert
          $permissions = "{""keys"":""$keyPermissions"",""secrets"":""$secretPermissions"",""certificates"":""$certificatePermissions"",""storage"":""$storagePermissions""}"
          $Object | Should -Be "Current access policies: {""list"":[{""tenantId"":""$tenantId"",""objectId"":""$objectId"",""permissions"":$permissions}]}"
        } -Verifiable -ParameterFilter { $Object -match "Current access policies:" }
        
        # Act
        Get-KeyVaultAccessPolicies -KeyVaultName "key vault" -ResourceGroupName "resource group name" -OutputVariableName "accesspolicies"
        
        # Assert
        Assert-VerifiableMocks
      }
    }
  }
}