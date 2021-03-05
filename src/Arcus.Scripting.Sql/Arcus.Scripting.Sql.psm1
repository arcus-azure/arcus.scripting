<#
 .Synopsis
  Upgrades the version of the database to a newer version defined in the 'sqlScript'-folder.
 
 .Description
  Upgrades the version of the database to a newer version defined in the 'sqlScript'-folder.

 .Parameter ServerName
  The name of the Azure SQL Server that hosts the SQL Database. (Do not include the suffix 'database.windows.net'.)

 .Parameter DatabaseName
  The name of the SQL Database.

 .Parameter UserName
  The name of the user to be used to connect to the Azure SQL Database.

 .Parameter Password
  The password to be used to connect to the Azure SQL Database.

 .Parameter ScriptsFolder
  The directory folder where the SQL migration scripts are located on the file system.

 .Parameter ScriptsFileFilter
  The file filter to limited the SQL script files to use during the migrations.

 .Parameter DatabaseSchema
  The database schema to use when running SQL commands on the target database.
#>
function Invoke-AzSqlDatabaseMigration {
    param(
        [parameter(Mandatory=$true)][string] $ServerName = $(throw "Please provide the name of the SQL Server that hosts the SQL Database. (Do not include 'database.windows.net'"),
        [parameter(Mandatory=$true)][string] $DatabaseName = $(throw "Please provide the name of the SQL Database"),
        [parameter(Mandatory=$true)][string] $UserName = $(throw "Please provide the UserName of the SQL Database"),
        [parameter(Mandatory=$true)][string] $Password = $(throw "Please provide the Password of the SQL Database"),
        [parameter(Mandatory=$false)][string] $ScriptsFolder = "$PSScriptRoot/sqlScripts",
        [parameter(Mandatory=$false)][string] $ScriptsFileFilter = "*.sql",
        [parameter(Mandatory=$false)][string] $DatabaseSchema = "dbo"
    )

    . $PSScriptRoot\Scripts\Invoke-AzSqlDatabaseMigration.ps1 -ServerName $ServerName -DatabaseName $DatabaseName -UserName $UserName -Password $Password -ScriptsFolder $ScriptsFolder -ScriptsFileFilter $ScriptsFileFilter -DatabaseSchema $DatabaseSchema
}

Export-ModuleMember -Function Invoke-AzSqlDatabaseMigration
