param(
    [pscustomobject]$config
)

$clientSecret = ConvertTo-SecureString $config.Arcus.ServicePrincipal.ClientSecret -AsPlainText -Force
$pscredential = New-Object -TypeName System.Management.Automation.PSCredential($config.Arcus.ServicePrincipal.ClientId, $clientSecret)
Disable-AzContextAutosave -Scope Process
Connect-AzAccount -Credential $pscredential -TenantId $config.Arcus.TenantId -ServicePrincipal

$tenantid = $config.Arcus.TenantId
$body =  @{
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

Connect-MgGraph -AccessToken $token 