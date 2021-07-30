Import-Module Az.ApiManagement
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.ApiManagement -ErrorAction Stop

InModuleScope Arcus.Scripting.ApiManagement {
    Describe "Arcus Azure API Management integration tests" {
        BeforeEach {
            $filePath = "$PSScriptRoot\appsettings.json"
            [string]$appsettings = Get-Content $filePath
            $config = ConvertFrom-Json $appsettings
            
            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
            $serviceName = "arcus-scripting-apimanagement"
            New-AzApiManagement `
                -ResourceGroupName $config.Arcus.ResourceGroupName `
                -Name $serviceName `
                -Location "West Europe" `
                -Organization "Arcus" `
                -AdminEmail "automation@arcus.com" `
                -Sku Developer
        }
        Context "Upload public CA certificate to Azure API Management" {
            It "Uploads new public CA certificate to Azure API Management succeeds" {
                # Arrange
                $certificate = New-SelfSignedCertificate -DnsName "www.arcus-azure.com"
                $certificateFilePath = $PSScriptRoot\Files\apim-certificate.cer
                New-Item -Path $certificateFilePath -ItemType File -Force

                 # Act
                 Upload-AzApiManagementSystemCertificate `
                     -ResourceGroupName $config.Arcus.ResourceGroupName `
                     -ServiceName $serviceName `
                     -CertificateFilePath $certificateFilePath

                # Assert
                $apimContext = Get-AzApiManagement -ResourceGroupName $config.Arcus.ResourceGroupName -Name $serviceName
                $apimContext.SystemCertificates.CertificateInformation.Thumbprint | Should -Be $certificate.Thumbprint
            }
        }
        AfterEach {
            Remove-AzApiManagement -ResourceGroupName $config.Arcus.ResourceGroupName -Name $serviceName
        }
    }
}