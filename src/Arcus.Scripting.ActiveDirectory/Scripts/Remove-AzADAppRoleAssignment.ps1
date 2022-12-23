param(
    [Parameter(Mandatory = $true)][string] $ClientId = $(throw "ClientId is required"),
    [Parameter(Mandatory = $true)][string] $Role = $(throw "Role is required"),
    [Parameter(Mandatory = $true)][string] $RemoveRoleFromClientId = $(throw "ClientId to remove the role from is required"),
    [Parameter(Mandatory = $false)][switch] $RemoveRoleIfNoAssignmentsAreLeft = $false
)

$adApplication = Get-AzADApplication -Filter "AppId eq '$ClientId'"
if (!$adApplication) { 
    throw "Active Directory Application for the ClientId '$ClientId' could not be found" 
}
$adServicePrincipal = Get-AzADServicePrincipal -Filter "AppId eq '$ClientId'"
if (!$adServicePrincipal) { 
    throw "Active Directory Service Principal for the ClientId '$ClientId' could not be found" 
}

$adApplicationRoleRemoveFrom = Get-AzADApplication -Filter "AppId eq '$RemoveRoleFromClientId'"
if (!$adApplicationRoleRemoveFrom) { 
    throw "Active Directory Application for the ClientId '$RemoveRoleFromClientId' could not be found" 
}
$adServicePrincipalRoleRemoveFrom = Get-AzADServicePrincipal -Filter "AppId eq '$RemoveRoleFromClientId'"
if (!$adServicePrincipalRoleRemoveFrom) { 
    throw "Active Directory Service Principal for the ClientId '$RemoveRoleFromClientId' could not be found" 
}

try {
    if ($adApplication.AppRole.Value -notcontains $Role) {
        Write-Host "Active Directory Application '$($adApplication.DisplayName)' does not contain the role '$Role', skipping removal" -ForegroundColor Yellow
    } else {
        $appRole = $adApplication.AppRole | Where-Object {($_.DisplayName -eq $Role)}
        $appRoleAssignment = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $adServicePrincipal.Id | Where-Object {($_.AppRoleId -eq $appRole.Id) -and ($_.PrincipalId -eq $adServicePrincipalRoleRemoveFrom.Id)}

        if ($appRoleAssignment) {
            Remove-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $adServicePrincipalRoleRemoveFrom.Id -AppRoleAssignmentId $appRoleAssignment.Id
            Write-Host "Role assignment for '$Role' has been removed from Active Directory Application '$($adApplicationRoleRemoveFrom.DisplayName)'"
        } else {
            Write-Host "Role '$Role' is not assigned to Active Directory Application '$($adApplicationRoleRemoveFrom.DisplayName)', skipping role assignment removal" -ForegroundColor Yellow
        }

        if ($RemoveRoleIfNoAssignmentsAreLeft) {
            $appRoleAssignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $adServicePrincipal.Id | Where-Object AppRoleId -eq $appRole.Id 
            
            if (-not $appRoleAssignments) {
                ($adApplication.AppRole | Where-Object Id -eq $appRole.Id).IsEnabled = $false

                Update-AzADApplication -ObjectId $adApplication.Id -AppRole $adApplication.AppRole
                Write-Host "Role '$Role' on Active Directory Application '$($adApplication.DisplayName)' has been disabled as no more role assignments were left and the option 'RemoveRoleIfNoAssignmentsAreLeft' is set"

                $appRoles = $adApplication.AppRole | Where-Object Id -ne $appRole.Id
                if ($appRoles) {
                    Update-AzADApplication -ObjectId $adApplication.Id -AppRole $appRoles
                    Write-Host "Role '$Role' with App Role '$appRoles' removed from Active Directory Application '$($adApplication.DisplayName)' as no more role assignments were left and the option 'RemoveRoleIfNoAssignmentsAreLeft' is set"
                } else {
                    Update-AzADApplication -ObjectId $adApplication.Id -AppRole @()
                    Write-Host "Role '$Role' removed from Active Directory Application '$($adApplication.DisplayName)' as no more role assignments were left and the option 'RemoveRoleIfNoAssignmentsAreLeft' is set"
                }
            }
        }
    }
} catch {
    throw "Removing the role '$Role' for the Active Directory Application with ClientId '$ClientId' failed. Details: $($_.Exception.Message)"
}