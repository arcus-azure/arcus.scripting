param(
  [pscustomobject]$config
)

$tenantid = $config.Arcus.TenantId
$body = @{
  Grant_Type    = "client_credentials"
  Scope         = "https://graph.microsoft.com/.default"
  Client_Id     = $config.Arcus.ServicePrincipal.ClientId
  Client_Secret = $config.Arcus.ServicePrincipal.ClientSecret
}

$connection = Invoke-RestMethod `
  -Uri https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token `
  -Method POST `
  -Body $body
 
$token = $connection.access_token

$targetParameter = (Get-Command Connect-MgGraph).Parameters['AccessToken']

if ($targetParameter.ParameterType -eq [securestring]) {
  Connect-MgGraph -AccessToken ($token | ConvertTo-SecureString -AsPlainText -Force)
} else {
  Connect-MgGraph -AccessToken $token
}

return $token | ConvertFrom-SecureString -AsPlainText -Force