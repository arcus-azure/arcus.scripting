param(
    [Parameter(Mandatory = $true)][string] $ClientId = $(throw "ClientId is required")
)

$adApplication = Get-AzADApplication -Filter "AppId eq '$ClientId'"
if (!$adApplication) { 
    throw "Active Directory Application for the ClientId $ClientId could not be found" 
}

$adServicePrincipal = Get-AzADServicePrincipal -Filter "AppId eq '$ClientId'"
if (!$adServicePrincipal) { 
    throw "Active Directory Service Principal for the ClientId $ClientId could not be found" 
}

try {
    foreach ($appRole in $adApplication.AppRole) {
        Write-Host "Found role '$($appRole.Value)' on Active Directory Application '$($adApplication.DisplayName)':" -ForegroundColor Green
        $serviceAppRoleAssignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $adServicePrincipal.Id  | Where-Object AppRoleId -eq $appRole.Id 

        foreach ($serviceAppRoleAssignment in $serviceAppRoleAssignments) {
            $servicePrincipal = Get-AzADServicePrincipal -ObjectId $serviceAppRoleAssignment.PrincipalId
            if ($servicePrincipal -ne $null) {
                Write-Host "Role '$($appRole.Value)' is assigned to the Active Directory Application '$($serviceAppRoleAssignment.PrincipalDisplayName)' with id '$($servicePrincipal.AppId)'" -ForegroundColor White        
            }
        }
    }
} catch {
    throw "Retrieving the roles for the Active Directory Application with ClientId '$ClientId' failed. Details: $($_.Exception.Message)"
}