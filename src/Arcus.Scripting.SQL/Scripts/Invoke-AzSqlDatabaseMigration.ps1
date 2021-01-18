param(
    [parameter(Mandatory=$true)][string] $ServerName = $(throw "Please provide the name of the SQL Server that hosts the SQL Database. (Do not include 'database.windows.net'"),
    [parameter(Mandatory=$true)][string] $DatabaseName = $(throw "Please provide the name of the SQL Database"),
    [parameter(Mandatory=$true)][string] $UserName = $(throw "Please provide the UserName of the SQL Database"),
    [parameter(Mandatory=$true)][string] $Password = $(throw "Please provide the Password of the SQL Database"),
    [parameter(Mandatory=$true)][string] $ScriptsFolder = "$PSScriptRoot/sqlScripts",
    [parameter(Mandatory=$true)][string] $ScriptsFileFilter = ".sql",
    [parameter(Mandatory=$true)][string] $DatabaseSchema = "dbo"
)

Write-Host "Looking for SQL scripts in folder: $ScriptsFolder"

#Functions for repeated use
function Execute-DbCommand($params, [string]$query)
{
    $result = Invoke-Sqlcmd @params -Query $query -Verbose -QueryTimeout 180
    Write-Host "Result from querying $($result)"
}

function Execute-DbCommandWithResult($params, [string] $query)
{
    $result = Invoke-Sqlcmd @params -Query $query -Verbose
    return $result
}

function Create-DbParams([string] $DatabaseName, [string] $serverInstance, [string] $UserName, [string] $Password)
{
    Write-Host "databasename = $DatabaseName"
    Write-Host "serverinstance = $serverInstance"
    Write-Host "username = $UserName"
    
    return $params = @{
      'Database' = $DatabaseName
      'ServerInstance' = "$serverInstance.database.windows.net"
      'Username' = $UserName
      'Password' = $Password
      'OutputSqlErrors' = $true
      'AbortOnError' = $True
    }
}

function Get-SqlScriptFileText([string] $scriptPath, [string] $fileName)
{
    $currentfilepath = "$scriptPath/$fileName.sql"
    return $query = [IO.File]::ReadAllText($currentfilepath)
}

function Get-CurrentDbVersionNumber () {
    $selectDbVersionScript = 'SELECT TOP 1 CurrentVersionNumber FROM DatabaseVersion ORDER BY CurrentVersionNumber DESC'
    $params = Create-DbParams $DatabaseName $ServerName $UserName $Password

     Write-Host 'Getting Current Database Version Number...'
    $databaseVersionNumberDataRow = Execute-DbCommandWithResult $params $selectDbVersionScript

     if ($databaseVersionNumberDataRow.ItemArray.Count -eq 0)
    {
        $databaseVersionNumber = 0;
    }
    else
    {
        $databaseVersionNumber = [Convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[0])
    }

    return $databaseVersionNumber
}

#Group params needed to connect to database for ease of use
$params = Create-DbParams $DatabaseName $ServerName $UserName $Password

#Get all tables on the database
$query = 'SELECT TABLE_NAME FROM information_schema.tables'
$tables = Execute-DbCommandWithResult $params $query

# Get script to determine DB version
$selectDbVersionScript = 'SELECT TOP 1 CurrentVersionNumber FROM DatabaseVersion ORDER BY CurrentVersionNumber DESC'

#Create a DatabaseVersion table if it doesn't exist
if(!$tables.ItemArray.Contains('DatabaseVersion'))
{
    Write-Host 'DatabaseVersion does not exist yet in this database.'
    Write-Host 'Creating DatabaseVersion Table...'
    $createDbCommand = Get-SqlScriptFileText $ScriptsFolder 'CreateDatabaseVersionTable'
    Execute-DbCommand $params $createDbCommand
    Write-Host 'DatabaseVersion Table Created'

    $databaseVersionNumber = 0
}
else
{
    # Get database versionnumber
    $databaseVersionNumber = Get-CurrentDbVersionNumber
}


Write-Host "Current databaseVersionNumber : $databaseVersionNumber"

#Run all necessary scripts
$files = Get-ChildItem -Path $ScriptsFolder -Filter $ScriptsFileFilter | Sort-Object {$_.BaseName -replace "\D+" -as [Int]}

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

    [string] $scriptVersionDescription = [convert]::Tostring($fileNameSections[2])
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
        $text = Get-SqlScriptFileText $ScriptsFolder $fileName
        Execute-DbCommand $params $text

        # Append the new version and description in version table
        $updateVersionQuery = "INSERT INTO [$DatabaseSchema].[DatabaseVersion] ([CurrentVersionNumber], [MigrationDescription]) VALUES ($scriptVersionNumber, '$scriptVersionDescription')"
        Execute-DbCommand $params $updateVersionQuery

        # Update DB version to new version
        $databaseVersionNumber = $scriptVersionNumber

        Write-Host "Migration to version $scriptVersionNumber complete."
    }
    else {
        Write-Host "Migration #$scriptVersionNumber skipped"
    }
}

#Get New Database Version Number
$databaseVersionNumber = Get-CurrentDbVersionNumber
Write-Host "Done looping over scripts. Current Database version is $databaseVersionNumber."