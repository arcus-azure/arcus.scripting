---
title: "Scripts related to interacting with Azure SQL"
layout: default
---

# Azure SQL

With these scripts you can perform database upgrades by providing/adding specific sqlscripts with the right version number.
Once a new version number is detected it will incrementally execute this.

While doing so it will create a table "DatabaseVersion".
If the DatabaseVersion table doesn't exist it will automatically create it.

This module provides the following capabilities:
- [Invoke a database migration](#invoke-a-database-migration)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.SQL
```

## Invoke a database migration
This function allows you to trigger a database migration, which will only execute the newly provided SQL scripts, based on the provided version number in each of the scripts. 
The current version is stored in a table "DatabaseVersion", which will be created if it doesn't exist yet.
| Parameter         | Mandatory | Description                                                                         |
| ----------------- | --------- | ----------------------------------------------------------------------------------- |
| `ServerName`      | yes       | The SQL Server that hosts the SQL Database. (Do not include 'database.windows.net') |
| `DatabaseName`    | yes       | The name of the SQL Database                                                        |
| `UserName`        | yes       | The UserName of the SQL Database                                                    |
| `Password`        | yes       | The Password of the SQL Database                                                    |


Make sure that the credentials that you provide are able to write tables to the database + any action that you specify in the sql scripts.

**Example**

```powershell
PS> RunDatabaseScript -ServerName "my-server-name" -DatabaseName "my-database-name" -Username "my-sql-username" -Password "my-sql-password"
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

3. Next to that you can add your own scripts which, in order to be recognized by the module, need to match the following naming convention:
`[Prefix]_[VersionNumber]_[DescriptionOfMigration].sql`

In practice this can look like this:
Arcus_001_AddIndexes.sql

When a new migration comes along, just create the new sql script with a version number one number higher than the previous one.
