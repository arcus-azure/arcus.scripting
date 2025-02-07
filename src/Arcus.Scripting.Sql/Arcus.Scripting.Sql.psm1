class DatabaseVersion : System.IComparable {
    [int] $MajorVersionNumber
    [int] $MinorVersionNumber
    [int] $PatchVersionNumber

    DatabaseVersion([int] $major, [int] $minor, [int] $patch) {
        $this.MajorVersionNumber = $major;
        $this.MinorVersionNumber = $minor;
        $this.PatchVersionNumber = $patch;
    }

    DatabaseVersion([string] $version) {
        $items = $version -split '\.'
        
        if ( $items.length -eq 3 ) {
            $this.MajorVersionNumber = $items[0];
            $this.MinorVersionNumber = $items[1];
            $this.PatchVersionNumber = $items[2];
        } elseif ( $items.length -eq 1 ) {
            $this.MajorVersionNumber = $items[0];
            $this.MinorVersionNumber = 0;
            $this.PatchVersionNumber = 0;
        } else {
            Throw "$version is not a valid or supported version number." 
        }
    }

    DatabaseVersion() {
        $this.MajorVersionNumber = 0;
        $this.MinorVersionNumber = 0;
        $this.PatchVersionNumber = 0;
    }

    [int] CompareTo($other) {
        $result = $this.MajorVersionNumber.CompareTo($other.MajorVersionNumber)

        if ($result -eq 0) {
            $result = $this.MinorVersionNumber.CompareTo($other.MinorVersionNumber)

            if ($result -eq 0) {
                return $this.PatchVersionNumber.CompareTo($other.PatchVersionNumber)
            }            
        }

        return $result;
    }

    [bool] Equals($other) {
        return $this.MajorVersionNumber -eq $other.MajorVersionNumber -and $this.MinorVersionNumber -eq $other.MinorVersionNumber -and $this.PatchVersionNumber -eq $other.PatchVersionNumber
    }

    [string] ToString() {
        return $this.MajorVersionNumber.ToString() + "." + $this.MinorVersionNumber.ToString() + "." + $this.PatchVersionNumber.ToString()
    }
}

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
  The password to be used to connect to the Azure SQL Database for the specified UserName. Prefer connecting via AccessToken instead.

 .Parameter AccessToken
  The access token used to authenticate to SQL Server.  Do not specify UserName/Password when using this parameter.

 .Parameter TrustServerCertificate
  Indicates whether the channel will be encrypted while bypassing walking the certificate chain to validate trust.

 .Parameter ScriptsFolder
  The directory folder where the SQL migration scripts are located on the file system.

 .Parameter ScriptsFileFilter
  The file filter to limited the SQL script files to use during the migrations.

 .Parameter DatabaseSchema
  The database schema to use when running SQL commands on the target database.

 .Parameter DatabaseVersionTable
  The name of the table in the database that keeps track of the applied database-migrations.
#>
function Invoke-AzSqlDatabaseMigration {
    param(
        [Parameter(Mandatory = $true)][string] $ServerName = $(throw "Please provide the name of the SQL Server that hosts the SQL Database. (Do not include 'database.windows.net'"),
        [Parameter(Mandatory = $true)][string] $DatabaseName = $(throw "Please provide the name of the SQL Database"),
        [Parameter(Mandatory = $false)][string] $UserName,
        [Parameter(Mandatory = $false)][string] $Password,
        [Parameter(Mandatory = $false)][string] $AccessToken,
        [Parameter(Mandatory = $false)][switch] $TrustServerCertificate,
        [Parameter(Mandatory = $false)][string] $ScriptsFolder = "$PSScriptRoot/sqlScripts",
        [Parameter(Mandatory = $false)][string] $ScriptsFileFilter = "*.sql",
        [Parameter(Mandatory = $false)][string] $DatabaseSchema = "dbo",
        [Parameter(Mandatory = $false)][string] $DatabaseVersionTable = "DatabaseVersion"
    )

    . $PSScriptRoot\Scripts\Invoke-AzSqlDatabaseMigration.ps1 -ServerName $ServerName -DatabaseName $DatabaseName -UserName $UserName -Password $Password -AccessToken $AccessToken -TrustServerCertificate $TrustServerCertificate -ScriptsFolder $ScriptsFolder -ScriptsFileFilter $ScriptsFileFilter -DatabaseSchema $DatabaseSchema -DatabaseVersionTable $DatabaseVersionTable
}

Export-ModuleMember -Function Invoke-AzSqlDatabaseMigration
