---
title: " Azure SQL"
layout: default
---

# Azure SQL

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.SQL
```

## Invoke a database migration

With this script, you can perform database upgrades by providing/adding specific SQL scripts with the right version number.
Once a new version number is detected it will incrementally execute this.

While doing so it will create a table "DatabaseVersion" (unless overriden by specifying the `DatabaseVersionTable` parameter).
If the DatabaseVersion table doesn't exist it will automatically create it.

This function allows you to trigger a database migration, which will only execute the newly provided SQL scripts, based on the provided version number in each of the scripts. 
The current version is stored in a table "DatabaseVersion", which will be created if it doesn't exist yet.

| Parameter               | Mandatory                               | Description                                                                         |
| ------------------------| --------------------------------------- | ----------------------------------------------------------------------------------- |
| `ServerName`            | yes                                     | The full name of the SQL Server that hosts the SQL Database.                        |
| `DatabaseName`          | yes                                     | The name of the SQL Database                                                        |
| `UserName`              | no                                      | The UserName of the user that must be used to login to the SQL Database. Prefer AccessToken instead |
| `Password`              | no                                      | The Password of the user that must be used to login to the SQL Database. Prefer AccessToken instead |
| `AccessToken`           | no                                      | The access token used to authenticate to SQL Server, as an alternative to user/password or Windows Authentication. Do not specify UserName/Password when using this parameter. |
| `TrustServerCertificate`| no (default: `$false`)                  | Indicates whether the channel will be encrypted while bypassing walking the certificate chain to validate trust. |
| `ScriptsFolder`         | no (default: `$PSScriptRoot/sqlScripts` | The directory folder where the SQL migration scripts are located on the file system |
| `ScriptsFileFilter`     | no (default: `*.sql`)                   | The file filter to limit the SQL script files to use during the migrations          |
| `DatabaseSchema`        | no (default: `dbo`)                     | The database schema to use when running SQL commands on the target database         |
| `DatabaseVersionTable`  | no (default: `DatabaseVersion`)         | The name of the table that keeps track of the migration scripts that have been applied |

Make sure that the credentials that you provide can write tables to the database + any action that you specify in the SQL scripts. (If the user is a member of the `db_ddlamin` role, then that user should have the necessary rights)

**Example with defaults**

```powershell
PS> Invoke-AzSqlDatabaseMigration `
-ServerName "my-server-name.database.windows.net" `
-DatabaseName "my-database-name" `
-Username "my-sql-username" `
-Password "my-sql-password"
# DB migration 1.0.0 applied!
# Done migrating database. Current Database version is 1.0.0
```

**Example with custom values**

```powershell
PS> Invoke-AzSqlDatabaseMigration `
-ServerName "my-server-name.database.windows.net" `
-DatabaseName "my-database-name" `
-Username "my-sql-username" `
-Password "my-sql-password" `
-TrustServerCertificate `
-ScriptsFolder "$PSScriptRoot/sql-scripts" `
-ScriptsFileFilter "*.MyScript.sql" `
-DatabaseSchema "custom" `
-DatabaseVersionTable "MySpecificVersionTable"
# DB migration 1.0.0 applied!
# Done migrating database. Current Database version is 1.0.0
```

**Login using AccessToken**

```powershell
PS> Connect-AzAccount
PS> $access_token = (Get-AzAccessToken -ResourceUrl https://database.windows.net).Token

PS> Invoke-AzSqlDatabaseMigration `
-ServerName "my-server-name.database.windows.net" `
-DatabaseName "my-database-name" `
-AccessToken $access_token
# DB migration 1.0.0 applied!
# Done migrating database. Current Database version is 1.0.0
```

### Adding SQL scripts so they can be picked up by the script

1. In the location where you want to run the script add a folder where the migration scripts will be placed.  By default, we're looking in a folder called `SqlScripts`, but this can be any folder as it is configurable via the `ScriptsFolder` argument.

2. Add your database migration scripts in the folder that was created in the previous step.  To be recognized by the module, the files must match with the following naming convention:
`[MajorVersionNumber].[MinorVersionNumber].[PatchVersionNumber]_[DescriptionOfMigration].sql`

In practice this can look like this:
`1.0.0_Baseline.sql`
`1.1.0_AddIndexes.sql`
`1.1.1_PopulateCodetables.sql`

When a new migration comes along, just create the new SQL script with a version number one number higher than the previous one.

### Compatibility

Semantic versioning of database-migrations is supported since version v0.5.  Existing migration scripts that follow the old naming convention will be recognized and will be given this version-number: `[VersionNumber].0.0`.
