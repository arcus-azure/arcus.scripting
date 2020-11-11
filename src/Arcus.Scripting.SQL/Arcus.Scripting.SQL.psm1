<#
 .Synopsis
  Upgrades the version of the database to a newer version defined in the sqlScript folder.
 
 .Description
  Upgrades the version of the database to a newer version defined in the sqlScript folder.

 .Parameter ServerName
  The name of the SQL Server that hosts the SQL Database. (Do not include 'database.windows.net'.

 .Parameter DatabaseName
  The name of the SQL Database.

 .Parameter UserName
  The name of the table to add on the Azure Storage Account.

 .Parameter Password
  The Password of the SQL Database.
#>
function RunDatabaseScript {
	param(
        [Parameter(Mandatory=$True)]
        [String]
        $ServerName=$(throw "Please provide the name of the SQL Server that hosts the SQL Database. (Do not include 'database.windows.net')"),
    
        [Parameter(Mandatory=$True)]
        [String]
        $DatabaseName=$(throw "Please provide the name of the SQL Database"),
    
        [Parameter(Mandatory=$True)]
        [String]
        $UserName=$(throw "Please provide the UserName of the SQL Database"),
    
        [Parameter(Mandatory=$True)]
        [String]
        $Password=$(throw "Please provide the Password of the SQL Database")
    )

    $PSScriptRoot\Scripts\RunDatabaseScript.ps1 -ServerName $ServerName -DatabaseName $DatabaseName -Username $UserName -Password $Password
}