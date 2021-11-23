---
title: " Azure SQL"
layout: default
---

# Azure SQL

This module provides the following capabilities:
- [Invoke a database migration](#invoke-a-database-migration)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.SQL -RequiredVersion 0.5.0
```

## Invoke a database migration

With this script, you can perform database upgrades by providing/adding specific SQL scripts with the right version number.
Once a new version number is detected it will incrementally execute this.

While doing so it will create a table "DatabaseVersion".
If the DatabaseVersion table doesn't exist it will automatically create it.

This function allows you to trigger a database migration, which will only execute the newly provided SQL scripts, based on the provided version number in each of the scripts. 
The current version is stored in a table "DatabaseVersion", which will be created if it doesn't exist yet.

| Parameter           | Mandatory                               | Description                                                                         |
| ------------------- | --------------------------------------- | ----------------------------------------------------------------------------------- |
| `ServerName`        | yes                                     | The full name of the SQL Server that hosts the SQL Database.                        |
| `DatabaseName`      | yes                                     | The name of the SQL Database                                                        |
| `UserName`          | yes                                     | The UserName of the SQL Database                                                    |
| `Password`          | yes                                     | The Password of the SQL Database                                                    |
| `ScriptsFolder`     | no (default: `$PSScriptRoot/sqlScripts` | The directory folder where the SQL migration scripts are located on the file system |
| `ScriptsFileFilter` | no (default: `*.sql`)                   | The file filter to limit the SQL script files to use during the migrations          |
| `DatabaseSchema`    | no (default: `dbo`)                     | The database schema to use when running SQL commands on the target database         |

Make sure that the credentials that you provide can write tables to the database + any action that you specify in the SQL scripts. (If the user is a member of the `db_ddlamin` role, then that user should have the necessary rights)

**Example with defaults**

```powershell
PS> RunDatabaseScript -ServerName "my-server-name" -DatabaseName "my-database-name" -Username "my-sql-username" -Password "my-sql-password"
# Looking for SQL scripts in folder: ./sqlScripts
```

**Example with custom values**

```powershell
PS> RunDatabaseScript -ServerName "my-server-name" -DatabaseName "my-database-name" -Username "my-sql-username" -Password "my-sql-password" -ScriptsFolder "$PSScriptRoot/sql-scripts" -ScriptsFileFilter "*.MyScript.sql" -DatabaseSchema "custom"
# Looking for SQL scripts in folder: ./sql-scripts
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
