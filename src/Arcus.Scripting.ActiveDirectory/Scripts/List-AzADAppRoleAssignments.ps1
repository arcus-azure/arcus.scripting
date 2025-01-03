param(
    [Parameter(Mandatory = $true)][string] $ClientId = $(throw "ClientId is required"),
    [Parameter(Mandatory = $false)][string] $RolesAssignedToClientId
)

$adApplication = Get-AzADApplication -Filter "AppId eq '$ClientId'"
if (!$adApplication) { 
    throw "Active Directory Application for the ClientId '$ClientId' could not be found"
}
$adServicePrincipal = Get-AzADServicePrincipal -Filter "AppId eq '$ClientId'"
if (!$adServicePrincipal) { 
    throw "Active Directory Service Principal for the ClientId '$ClientId' could not be found"
}

if ($RolesAssignedToClientId -ne '') {
    $adApplicationRolesAssignedTo = Get-AzADApplication -Filter "AppId eq '$RolesAssignedToClientId'"
    if (!$adApplicationRolesAssignedTo) { 
        throw "Active Directory Application for the ClientId '$RolesAssignedToClientId' could not be found"
    }
    $adServicePrincipalRolesAssignedTo = Get-AzADServicePrincipal -Filter "AppId eq '$RolesAssignedToClientId'"
    if (!$adServicePrincipalRolesAssignedTo) { 
        throw "Active Directory Service Principal for the ClientId '$RolesAssignedToClientId' could not be found"
    }
}

try {
    if ($adApplication.AppRole.Count -eq 0) {
        Write-Warning "No roles found in Active Directory Application '$($adApplication.DisplayName)'"
    }

    foreach ($appRole in $adApplication.AppRole) {
        Write-Host "Found role '$($appRole.Value)' on Active Directory Application '$($adApplication.DisplayName)'" -ForegroundColor Green
        if ($RolesAssignedToClientId -ne '') {
            $appRoleAssignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $adServicePrincipal.Id | Where-Object { ($_.AppRoleId -eq $appRole.Id) -and ($_.PrincipalId -eq $adServicePrincipalRolesAssignedTo.Id) }
        } else {
            $appRoleAssignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $adServicePrincipal.Id | Where-Object AppRoleId -eq $appRole.Id 
        }

        if ($appRoleAssignments) {
            foreach ($serviceAppRoleAssignment in $appRoleAssignments) {
                $servicePrincipal = Get-AzADServicePrincipal -ObjectId $serviceAppRoleAssignment.PrincipalId
                if ($null -ne $servicePrincipal) {
                    Write-Host "Role '$($appRole.Value)' is assigned to the Active Directory Application '$($serviceAppRoleAssignment.PrincipalDisplayName)' with ID '$($servicePrincipal.AppId)'" -ForegroundColor Green
                }
            }
        } else {
            Write-Warning "No role assignments found in Active Directory Application '$($adApplication.DisplayName)'"
        }
    }
} catch {
    throw "Retrieving the roles for the Active Directory Application with ClientId '$ClientId' failed. Details: $($_.Exception.Message)"
}