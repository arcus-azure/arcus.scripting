param(
    [Parameter(Mandatory = $true)][string] $ClientId = $(throw "ClientId is required"),
    [Parameter(Mandatory = $false)][string] $RolesAssignedToClientId
)

$adApplication = Get-AzADApplication -Filter "AppId eq '$ClientId'"
$adServicePrincipal = Get-AzADServicePrincipal -Filter "AppId eq '$ClientId'"
if (!$adApplication) { 
    throw "Active Directory Application for the ClientId '$ClientId' could not be found" 
}
if (!$adServicePrincipal) { 
    throw "Active Directory Service Principal for the ClientId '$ClientId' could not be found" 
}

if ($RolesAssignedToClientId -ne '') {
    $adApplicationRolesAssignedTo = Get-AzADApplication -Filter "AppId eq '$RolesAssignedToClientId'"
    $adServicePrincipalRolesAssignedTo = Get-AzADServicePrincipal -Filter "AppId eq '$RolesAssignedToClientId'"
    if (!$adApplicationRolesAssignedTo) { 
        throw "Active Directory Application for the ClientId '$RolesAssignedToClientId' could not be found" 
    }
    if (!$adServicePrincipalRolesAssignedTo) { 
        throw "Active Directory Service Principal for the ClientId '$RolesAssignedToClientId' could not be found" 
    }
}

try {
    foreach ($appRole in $adApplication.AppRole) {
        Write-Host "Found role '$($appRole.Value)' on Active Directory Application '$($adApplication.DisplayName)':" -ForegroundColor Green
        if ($RolesAssignedToClientId -ne '') {
            $serviceAppRoleAssignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $adServicePrincipal.Id | Where-Object {($_.AppRoleId -eq $appRole.Id) -and ($_.PrincipalId -eq $adServicePrincipalRolesAssignedTo.Id)}
        } else {
            $serviceAppRoleAssignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $adServicePrincipal.Id | Where-Object AppRoleId -eq $appRole.Id 
        }

        if ($serviceAppRoleAssignments) {
            foreach ($serviceAppRoleAssignment in $serviceAppRoleAssignments) {
                $servicePrincipal = Get-AzADServicePrincipal -ObjectId $serviceAppRoleAssignment.PrincipalId
                if ($servicePrincipal -ne $null) {
                    Write-Host "Role '$($appRole.Value)' is assigned to the Active Directory Application '$($serviceAppRoleAssignment.PrincipalDisplayName)' with id '$($servicePrincipal.AppId)'" -ForegroundColor White        
                }
            }
        } else {
            Write-Host "No role assignments found"
        }
    }
} catch {
    throw "Retrieving the roles for the Active Directory Application with ClientId '$ClientId' failed. Details: $($_.Exception.Message)"
}