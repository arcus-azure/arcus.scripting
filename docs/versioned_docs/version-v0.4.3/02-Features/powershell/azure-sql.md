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
PS> Install-Module -Name Arcus.Scripting.SQL -MinimumVersion 0.4.3
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
| `ServerName`        | yes                                     | The SQL Server that hosts the SQL Database. (Do not include 'database.windows.net') |
| `DatabaseName`      | yes                                     | The name of the SQL Database                                                        |
| `UserName`          | yes                                     | The UserName of the SQL Database                                                    |
| `Password`          | yes                                     | The Password of the SQL Database                                                    |
| `ScriptsFolder`     | no (default: `$PSScriptRoot/sqlScripts` | The directory folder where the SQL migration scripts are located on the file system |
| `ScriptsFileFolder` | no (default: `*.sql`)                   | The file filter to limit the SQL script files to use during the migrations          |
| `DatabaseSchema`    | no (default: `dbo`)                     | The database schema to use when running SQL commands on the target database         |

Make sure that the credentials that you provide can write tables to the database + any action that you specify in the SQL scripts.

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

1. In the location where you want to run the script add the folder "sqlScripts".

2. Within this folder there should be by default the `CreateDatabaseVersionTable.sql`-file, containing the script to create the initial version table:

```sql
CREATE TABLE [dbo].[DatabaseVersion]
(
    [CurrentVersionNumber] INT NOT NULL,
    [MigrationDescription] [nvarchar](256) NOT NULL,
    CONSTRAINT [PKDatabaseVersion] PRIMARY KEY CLUSTERED
    ( 	
        [CurrentVersionNumber] ASC
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
```

3. Next to that you can add your scripts which, to be recognized by the module, need to match the following naming convention:
`[Prefix]_[VersionNumber]_[DescriptionOfMigration].sql`

In practice this can look like this:
Arcus_001_AddIndexes.sql

When a new migration comes along, just create the new SQL script with a version number one number higher than the previous one.
