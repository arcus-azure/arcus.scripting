---
title: "Azure Active Directory"
layout: default
---

# Azure Active Directory

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.ActiveDirectory
```

## Access Rights to Azure Active Directory

To interact with Azure Active Directory these scripts use the [Microsoft.Graph.Applications](https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.applications/) module, import this module:

```powershell
PS> Install-Module -Name Microsoft.Graph.Applications
```

After importing this module, make sure you are connected to Microsoft Graph with the following scopes:

```powershell
PS> Connect-MgGraph -Scopes "Application.ReadWrite.All,AppRoleAssignment.ReadWrite.All"
```

## Listing the Roles and Role Assignments for an Azure Active Directory Application

Lists the roles and role assignments for an Azure Active Directory Application.

| Parameter                 | Mandatory | Description                                                                                                                                                                                |
| ------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `ClientId`                | yes       | The client ID of the Azure Active Directory Application Registration for which the roles and assignments are retrieved.                                                                    |
| `RolesAssignedToClientId` | no        | The client ID of the Azure Active Directory Application Registration to which roles have been assigned, used when you only want to retrieve the assignments for this specific application. |

**Example**

Retrieving all information for a Client Id.

```powershell
PS> List-AzADAppRoleAssignments `
-ClientId "b885c208-6067-44bd-aba9-4010c62b7d85"
#Found role 'FirstRole' on Active Directory Application 'main-application'
#Role 'FirstRole' is assigned to the Active Directory Application 'client-application-one' with ID '6ea09bbd-c21c-460c-b58a-f4a720f51826'
#Role 'FirstRole' is assigned to the Active Directory Application 'client-application-two' with ID 'ebafc99d-cbf4-4bd2-9295-f2b785cfc1a1'
#Found role 'SecondRole' on Active Directory Application 'arcus-scripting-test-main'
#Role 'SecondRole' is assigned to the Active Directory Application 'client-application-one' with ID '6ea09bbd-c21c-460c-b58a-f4a720f51826'
```

Retrieving all information for a Client Id and a specific role.

```powershell
PS> List-AzADAppRoleAssignments `
-ClientId 'b885c208-6067-44bd-aba9-4010c62b7d85' `
-RolesAssignedToClientId '6ea09bbd-c21c-460c-b58a-f4a720f51826'
#Found role 'FirstRole' on Active Directory Application 'main-application'
#Role 'FirstRole' is assigned to the Active Directory Application 'client-application-one' with id '6ea09bbd-c21c-460c-b58a-f4a720f51826'
#Found role 'SecondRole' on Active Directory Application 'main-application'
#Role 'SecondRole' is assigned to the Active Directory Application 'client-application-one' with id '6ea09bbd-c21c-460c-b58a-f4a720f51826'
```

## Add a Role and Assignment for an Azure Active Directory Application

Adds a role assignment for an Azure Active Directory Application. The role will be added to the Azure Active Directory Application Registration defined by the `ClientId` parameter, and a role assignment for this role will be added to the Azure Active Directory Application Registration defined by the `AssignRoleToClientId` parameter.

| Parameter              | Mandatory | Description                                                                                                                                                                                                                                                       |
| ---------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ClientId`             | yes       | The client ID of the Azure Active Directory Application Registration to which the role will be added if not present.                                                                                                                                              |
| `Role`                 | yes       | The name of the role.                                                                                                                                                                                                                                             |
| `AssignRoleToClientId` | yes       | The client ID of the Azure Active Directory Application Registration for which the role assignment will be created. The role assignment will be created based on the role added to the Azure Active Directory Application Registration defined by the `ClientId`. |

**Example**

```powershell
PS> Add-AzADAppRoleAssignment `
-ClientId "b885c208-6067-44bd-aba9-4010c62b7d85" `
-Role "DummyRole" `
-AssignRoleToClientId "6ea09bbd-c21c-460c-b58a-f4a720f51826"
#Active Directory Application 'main-application' does not contain the role 'DummyRole', adding the role
#Added Role 'DummyRole' to Active Directory Application 'main-application'
#Role Assignment for the role 'DummyRole' added to the Active Directory Application 'client-application-one'
```

## Remove a Role and Assignment from an Azure Active Directory Application

Removes a role assignment for an Azure Active Directory Application.

| Parameter                          | Mandatory | Description                                                                                                                                                                         |
| ---------------------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ClientId`                         | yes       | The client ID of the Azure Active Directory Application Registration containing the role for which the assignment must be removed.                                                  |
| `Role`                             | yes       | The name of the role.                                                                                                                                                               |
| `RemoveRoleFromClientId`           | yes       | The client ID of the Azure Active Directory Application Registration for which the role assignment will be removed.                                                                 |
| `RemoveRoleIfNoAssignmentsAreLeft` | no        | Indicate whether to remove the role from the Azure Active Directory Application Registration defined by the `ClientId` parameter when no more role assignments remain for the role. |

**Example**

Removes a role assignment.

```powershell
PS> Remove-AzADAppRoleAssignment `
-ClientId "b885c208-6067-44bd-aba9-4010c62b7d85" `
-Role "DummyRole" `
-RemoveRoleFromClientId "6ea09bbd-c21c-460c-b58a-f4a720f51826" `
#Role assignment for 'DummyRole' has been removed from Active Directory Application 'client-application-one'
```

Removes a role assignment and removes the fole if no assignments are left on the role.

```powershell
PS> Remove-AzADAppRoleAssignment `
-ClientId "b885c208-6067-44bd-aba9-4010c62b7d85" `
-Role "DummyRole" `
-RemoveRoleFromClientId "6ea09bbd-c21c-460c-b58a-f4a720f51826" `
-RemoveRoleIfNoAssignmentsAreLeft
#Role assignment for 'DummyRole' has been removed from Active Directory Application 'client-application-one'
#Role 'DummyRole' on Active Directory Application 'main-application' has been disabled as no more role assignments were left and the option 'RemoveRoleIfNoAssignmentsAreLeft' is set
#Role 'DummyRole' removed from Active Directory Application 'main-application' as no more role assignments were left and the option 'RemoveRoleIfNoAssignmentsAreLeft' is set
```

