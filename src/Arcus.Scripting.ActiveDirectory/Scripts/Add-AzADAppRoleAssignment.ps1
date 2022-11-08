param(
    [Parameter(Mandatory = $true)][string] $ClientId = $(throw "ClientId is required"),
    [Parameter(Mandatory = $true)][string] $Role = $(throw "Role is required"),
    [Parameter(Mandatory = $true)][string] $AssignRoleToClientId = $(throw "ClientId to assign the role to is required")
)

$adApplication = Get-AzADApplication -Filter "AppId eq '$ClientId'"
$adServicePrincipal = Get-AzADServicePrincipal -Filter "AppId eq '$ClientId'"
if (!$adApplication) { 
    throw "Active Directory Application for the ClientId '$ClientId' could not be found" 
}
if (!$adServicePrincipal) { 
    throw "Active Directory Service Principal for the ClientId '$ClientId' could not be found" 
}

$adApplicationRoleAssignTo = Get-AzADApplication -Filter "AppId eq '$AssignRoleToClientId'"
$adServicePrincipalRoleAssignTo = Get-AzADServicePrincipal -Filter "AppId eq '$AssignRoleToClientId'"
if (!$adApplicationRoleAssignTo) { 
    throw "Active Directory Application for the ClientId '$AssignRoleToClientId' could not be found" 
}
if (!$adServicePrincipalRoleAssignTo) { 
    throw "Active Directory Service Principal for the ClientId '$AssignRoleToClientId' could not be found" 
}

try {
    if (-not ($adApplication.AppRole.Value -contains $Role)) {
        Write-Host "Active Directory Application '$($adApplication.DisplayName)' does not contain the role '$Role', adding the role"

        $newRole = @{
          "DisplayName" = $Role
          "Description" = $Role
          "Value" = $Role
          "Id" = [Guid]::NewGuid().ToString()
          "IsEnabled" = $true
          "allowedMemberTypes" = @("User", "Application")
         }

        $adApplication.AppRole += $newRole

        Update-AzADApplication -ObjectId $adApplication.Id -AppRole $adApplication.AppRole
        Write-Host "Added Role '$Role' to Active Directory Application '$($adApplication.DisplayName)'"

        $currentAppRole = $newRole
    } else {
        Write-Host "Active Directory Application '$($adApplication.DisplayName)' already contains the role '$Role'"
        $currentAppRole = $adApplication.AppRole | Where-Object Value -eq $Role
    }

    $currentRoleAssignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $adServicePrincipal.Id | Where-Object AppRoleId -eq $currentAppRole.Id 
    if (-not ($currentRoleAssignments.AppRoleId -contains $currentAppRole.Id)) {
        $updatedAdServicePrincipal = Get-MgServicePrincipal -ServicePrincipalId $adServicePrincipal.Id

        while (-not ($updatedAdServicePrincipal.AppRoles.Value -contains $Role) -and $counter -lt 10) {
            Write-Host "Role '$Role' has been added to Active Directory Application '$($adApplication.DisplayName)' but not yet available for use, waiting 10 seconds to retry..."
            Start-Sleep -Seconds 10
            $counter++
            $updatedAdServicePrincipal = Get-MgServicePrincipal -ServicePrincipalId $adServicePrincipal.Id
        }

        if ($counter -eq 10) {
            throw "Exhausted the retries, the role '$Role' has been added to Active Directory Application '$($adApplication.DisplayName)' but not yet available for use"
        }

        $newRoleAssignment = New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $adServicePrincipalRoleAssignTo.Id -PrincipalId $adServicePrincipalRoleAssignTo.Id -ResourceId $adServicePrincipal.Id -AppRoleId $currentAppRole.Id
        Write-Host "Role Assignment for the '$Role' added to the Active Directory Application '$($adApplicationRoleAssignTo.DisplayName)'"
    } else {
         Write-Host "Active Directory Application '$($adApplicationRoleAssignTo.DisplayName)' already contains a role assignment for the '$Role'"
    }
} catch {
    throw "Adding the role '$Role' for the Active Directory Application with ClientId '$ClientId' failed. Details: $($_.Exception.Message)"
}