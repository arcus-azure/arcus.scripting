param(
    [Parameter(Mandatory=$True)]
    [String]
    $ServerName=$(throw "Please provide the name of the SQL Server that hosts the SQL Database. (Do not include 'database.windows.net'"),
    
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

Import-Module SqlServer

Write-Host $PSScriptRoot
$scriptpath = "$PSScriptRoot/sqlScripts"

#Functions for repeated use
function QueryDatabase($params, [String]$query)
{
    $result = Invoke-Sqlcmd @params -Query $query -Verbose -QueryTimeout 180
    Write-Host "Result from querying $($result)"
}

function QueryDatabaseWithResult($params, [String]$query)
{
    $result = Invoke-Sqlcmd @params -Query $query -Verbose
    return $result
}

function CreateDbParams([String]$DatabaseName, [String]$serverInstance, [String]$UserName, [String]$Password)
{
    Write-Host "Database = $DatabaseName"
    Write-Host "ServerInstance = $serverInstance"
    Write-Host "UserName = $UserName"
    
    return $params = @{
      'Database' = $DatabaseName
      'ServerInstance' = "$serverInstance.database.windows.net"
      'Username' = $UserName
      'Password' = $Password
      'OutputSqlErrors' = $true
      'AbortOnError' = $True
    }
}

function GetScriptFileText([String]$scriptPath, [String]$fileName)
{
    $currentfilepath = "$scriptPath/$fileName.sql"
    return $query = [IO.File]::ReadAllText($currentfilepath)
}

#Group params needed to connect to database for ease of use
$params = CreateDbParams $DatabaseName $ServerName $UserName $Password

#Get all tables on the database
$query = 'SELECT TABLE_NAME FROM information_schema.tables'
$tables = QueryDatabaseWithResult $params $query

# Get script to determine DB version
$selectDbVersionScript = 'SELECT TOP 1 CurrentVersionNumber FROM DatabaseVersion ORDER BY CurrentVersionNumber DESC'

#Create a DatabaseVersion table if it doesn't exist
if(!$tables.ItemArray.Contains('DatabaseVersion'))
{
    Write-Host 'DatabaseVersion does not exist yet in this database.'
    Write-Host 'Creating DatabaseVersion Table...'
    $createDbQuery = GetScriptFileText $scriptpath 'CreateDatabaseVersionTable'
    QueryDatabase $params $createDbQuery
    Write-Host 'DatabaseVersion Table Created'

    $databaseVersionNumber = 0
}
else
{
    # Get database versionnumber
    Write-Host 'Getting Current Database Version Number...'
    $databaseVersionNumberDataRow = QueryDatabaseWithResult $params $selectDbVersionScript

    if ($databaseVersionNumberDataRow.ItemArray.Count -eq 0)
	{
		$databaseVersionNumber = 0;
	}
	else
	{
		$databaseVersionNumber = [convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[0])
	}
}


Write-Host "Current databaseVersionNumber : $databaseVersionNumber"

#Run all necessary scripts
$files = Get-ChildItem -Path $scriptPath -Filter "ITSME-Enroll_*.sql" | Sort-Object {$_.BaseName -replace "\D+" -as [Int]}

for ($i=0; $i -lt $files.Count; $i++) 
{
    $fileName = $files[$i].BaseName
    $fileNameSections = $fileName.Split('_');

    if ($fileNameSections.Length -lt 2)
    {
        Write-Host "File $fileName skipped for not having all required name sections (version and description)."
        continue;
    }

    $fileVersionStr = $fileNameSections[1];

    [int] $scriptVersionNumber = -1;

    if (-Not([int32]::TryParse($fileVersionStr, [ref]$scriptVersionNumber)))
    {
        Write-Host "File $fileName skipped because version is not valid."
        continue;
    }

	[string] $scriptVersionDescription = [convert]::ToString($fileNameSections[2])
    if($scriptVersionDescription.Length -gt 256)
    {
		Write-Host "Need to truncate the migration description because its size is" $scriptVersionDescription.Length "while the maximum size is 256"
        $scriptVersionDescription = $scriptVersionDescription.Substring(0,255)
    }
	
    Write-Host "Found migration #$scriptVersionNumber with description '$scriptVersionDescription'"

    if($scriptVersionNumber -eq ($databaseVersionNumber + 1))
	{
		Write-Host "Running script #$scriptVersionNumber"

        # Perform migration
		$currentfilepath = "$scriptPath/$fileName.sql"
		$query = [IO.File]::ReadAllText($currentfilepath)
		QueryDatabase $params $query

        # Append the new version and description in version table
        $updateVersionQuery = "INSERT INTO [dbo].[DatabaseVersion] ([CurrentVersionNumber], [MigrationDescription]) VALUES ($scriptVersionNumber, '$scriptVersionDescription')"
        QueryDatabase $params $updateVersionQuery

        # Update DB version to new version
        $databaseVersionNumber = $scriptVersionNumber

		Write-Host "Migration to version $scriptVersionNumber complete."
    }
    else {
        Write-Host "Migration #$scriptVersionNumber skipped"
    }
}

#Get New Database Version Number
$databaseVersionNumberDataRow = QueryDatabaseWithResult $params $selectDbVersionScript  
$databaseVersionNumber = [convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[0])
Write-Host "Done looping over scripts. Current Database version is $databaseVersionNumber."
