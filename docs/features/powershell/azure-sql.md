---
title: "Scripts related to interacting with Azure SQL"
layout: default
---

# Azure SQL

With these scripts you can perform database upgrades by providing/adding specific sqlscripts with the right version number.
Once a new version number is detected it will incrementally execute this.

While doing so it will create a table "DatabaseVersion".
If the DatabaseVersion table doesn't exist it will automatically create it.

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.SQL
```

## Run the database migration script

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

## Adding SQL scripts so they can be picked up by the script

In the location where you want to run the script add the folder "sqlScripts".

Within this folder there should be by default the "CreateDatabaseVersionTable.sql" file.

Next to that you can add your own scripts. In order to make sure the scripts are red by the database script, make sure it has the following filename:
[Prefix]_[VersionNumber]_[DescriptionOfMigration].sql

In practice this can look like this:
Arcus_001_AddIndexes.ps1

When a new migration comes along, just create the new sql script with a version number one number higher than the previous one.
