param(
    [pscustomobject]$config
)

 $clientSecret = ConvertTo-SecureString $config.Arcus.ServicePrincipal.ClientSecret -AsPlainText -Force
 $pscredential = New-Object -TypeName System.Management.Automation.PSCredential($config.Arcus.ServicePrincipal.ClientId, $clientSecret)
 Disable-AzContextAutosave -Scope Process
 Connect-AzAccount -Credential $pscredential -TenantId $config.Arcus.TenantId -ServicePrincipal