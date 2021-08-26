param(
    [Parameter(Mandatory=$true)][string] $ServerName = $(throw "Please provide the name of the SQL Server that hosts the SQL Database. (Do not include 'database.windows.net'"),
    [Parameter(Mandatory=$true)][string] $DatabaseName = $(throw "Please provide the name of the SQL Database"),
    [Parameter(Mandatory=$true)][string] $UserName = $(throw "Please provide the UserName of the User that must be used to perform the update"),
    [Parameter(Mandatory=$true)][string] $Password = $(throw "Please provide the Password of the User that must be used to perform the update"),
    [Parameter(Mandatory=$false)][string] $ScriptsFolder = "$PSScriptRoot/sqlScripts",
    [Parameter(Mandatory=$false)][string] $ScriptsFileFilter = "*.sql",
    [Parameter(Mandatory=$false)][string] $DatabaseSchema = "dbo"
)

#Import needed for Azure Powershell Release Step
Import-Module SqlServer

Write-Host "Looking for SQL scripts in folder: $ScriptsFolder"

#Functions for repeated use
function Execute-DbCommand($params, [string]$query)
{
    $result = Invoke-Sqlcmd @params -Query $query -Verbose -QueryTimeout 180 -ErrorAction Stop -ErrorVariable err
    
    if( $err )
    {
        throw ($err)
    }
}

function Execute-DbCommandWithResult($params, [string] $query)
{
    $result = Invoke-Sqlcmd @params -Query $query -Verbose -ErrorAction Stop -ErrorVariable err
    if ($err)
    {
        throw ($err)
    }
    return $result
}

function Create-DbParams([string] $DatabaseName, [string] $serverInstance, [string] $UserName, [string] $Password)
{
    Write-Host "databasename = $DatabaseName"
    Write-Host "serverinstance = $serverInstance"
    Write-Host "username = $UserName"
    
    return $params = @{
      'Database' = $DatabaseName
      'ServerInstance' = $serverInstance
      'Username' = $UserName
      'Password' = $Password
      'OutputSqlErrors' = $true
      'AbortOnError' = $true
    }
}

function Get-SqlScriptFileText([string] $scriptPath, [string] $fileName)
{
    $currentfilepath = "$scriptPath/$fileName.sql"
    return $query = Get-Content $currentfilepath
}

Class DatabaseVersion : System.IComparable
{
    [int] $MajorVersionNumber
    [int] $MinorVersionNumber
    [int] $PatchVersionNumber

    DatabaseVersion([int] $major, [int] $minor, [int] $patch)
    {
        $this.MajorVersionNumber = $major;
        $this.MinorVersionNumber = $minor;
        $this.PatchVersionNumber = $patch;
    }

    DatabaseVersion([string] $version)
    {
        $items = $version -split '\.'

        $this.MajorVersionNumber = $items[0];
        $this.MinorVersionNumber = $items[1];
        $this.PatchVersionNumber = $items[2];
    }

    DatabaseVersion()  
    {
        $this.MajorVersionNumber = 0;
        $this.MinorVersionNumber = 0;
        $this.PatchVersionNumber = 0;
    }

    [int] CompareTo($other)
    {
        $result = $this.MajorVersionNumber.CompareTo($other.MajorVersionNumber)

        if( $result -eq 0 )
        {
            $result = $this.MinorVersionNumber.CompareTo($other.MinorVersionNumber)

            if( $result -eq 0 )
            {
                return $this.PatchVersionNumber.CompareTo($other.PatchVersionNumber)
            }            
        }

        return $result;                
    }

    [bool] Equals($other)
    {
        return $this.MajorVersionNumber -eq $other.MajorVersionNumber -and $this.MinorVersionNumber -eq $other.MinorVersionNumber -and $this.PatchVersionNumber -eq $other.PatchVersionNumber
    }

    [string] ToString()
    {
        return $this.MajorVersionNumber.ToString() + "." + $this.MinorVersionNumber.ToString() + "." + $this.PatchVersionNumber.ToString()
    }
}

#Group params needed to connect to database for ease of use
$params = Create-DbParams $DatabaseName $ServerName $UserName $Password

# Create the DatabaseVersion table if it doesn't exist yet
$createDatabaseVersionTable = "IF NOT EXISTS ( SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DatabaseVersion' AND TABLE_SCHEMA = '$DatabaseSchema' ) " +
                              "BEGIN " +
	                          "CREATE TABLE [$DatabaseSchema].[DatabaseVersion] " +
	                          "( " +
	                          "   [MajorVersionNumber] INT NOT NULL, " +
		                      "   [MinorVersionNumber] INT NOT NULL, " +
		                      "   [PatchVersionNumber] INT NOT NULL, " +
		                      "   [MigrationDescription] [nvarchar](256) NOT NULL, " +
                              "   [MigrationDate] DATETIME NOT NULL " +
		                      "   CONSTRAINT [PK_DatabaseVersion] PRIMARY KEY CLUSTERED  ([MajorVersionNumber],[MinorVersionNumber],[PatchVersionNumber]) " +
                              "				WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) " +
	                          ") " +
                              "END "

Execute-DbCommand $params $createDatabaseVersionTable

$getCurrentDbVersionQuery = "SELECT TOP 1 MajorVersionNumber, MinorVersionNumber, PatchVersionNumber FROM DatabaseVersion ORDER BY MajorVersionNumber DESC, MinorVersionNumber DESC, PatchVersionNumber DESC"

$databaseVersionNumberDataRow = Execute-DbCommandWithResult $params $getCurrentDbVersionQuery

$databaseVersion = [DatabaseVersion]::new()

if( !($null -eq $databaseVersionNumberDataRow ) )
{
    $databaseVersion = [DatabaseVersion]::new([convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[0]), [convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[1]), [convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[2]))    
}

Write-Host "Current database-version number: " $databaseVersion

$files = Get-ChildItem -Path $ScriptsFolder -Filter $ScriptsFileFilter | Sort-Object {($_.BaseName -split '_')[0] -as [DatabaseVersion]}

# Execute each migration file who's versionnumber is higher then the current DB version
for ($i = 0; $i -lt $files.Count; $i++) 
{
    $fileName = $files[$i].BaseName

    $fileNameParts = $fileName.Split('_')

    if ($fileNameParts.Length -lt 2)
    {
        Write-Host "File $fileName skipped for not having all required name sections (version and description)."
        continue;
    }

    if ($fileNameParts[0] -match "\d.\d.\d" -eq $False )
    {
        Write-Host "File $fileName skipped because version is not valid."
        continue;
    }

    [DatabaseVersion] $scriptVersionNumber = [DatabaseVersion]::new($fileNameParts[0])
    [string] $migrationDescription = $fileNameParts[1]

    if( $scriptVersionNumber -le $databaseVersion )
    {
        Write-Verbose "Skipped Migration $scriptVersionNumber as it has already been applied"
        continue
    }

    Write-Host "Executing DB migration " $scriptVersionNumber ": " $migrationDescription "... "

    $migrationScript = [IO.File]::ReadAllText($files[$i].FullName)

    Execute-DbCommand $params $migrationScript

    if($migrationDescription.Length -gt 256)
    {
		Write-Host "Need to truncate the migration description because its size is" $scriptVersionDescription.Length "while the maximum size is 256"
        $migrationDescription = $migrationDescription.Substring(0, 256)
    }
	
    $updateVersionQuery =   "INSERT INTO [$DatabaseSchema].[DatabaseVersion] ([MajorVersionNumber], [MinorVersionNumber], [PatchVersionNumber], [MigrationDescription], [MigrationDate]) " +
                            "SELECT $($scriptVersionNumber.MajorVersionNumber), $($scriptVersionNumber.MinorVersionNumber), $($scriptVersionNumber.PatchVersionNumber), '$migrationDescription', getdate()"
    
    Execute-DbCommand $params $updateVersionQuery

    Write-Host "DB migration " $scriptVersionNumber " applied!"

    $databaseVersion = $scriptVersionNumber    
}

#Get New Database Version Number
$databaseVersionNumberDataRow = Execute-DbCommandWithResult $params $getCurrentDbVersionQuery  
$databaseVersionNumber = [DatabaseVersion]::new([convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[0]), [convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[1]), [convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[2]))    
Write-Host "Done migrating database. Current Database version is $databaseVersionNumber."