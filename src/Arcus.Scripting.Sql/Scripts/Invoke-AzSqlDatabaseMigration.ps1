param(
    [Parameter(Mandatory = $true)][string] $ServerName = $(throw "Please provide the name of the SQL Server that hosts the SQL Database. (Do not include 'database.windows.net'"),
    [Parameter(Mandatory = $true)][string] $DatabaseName = $(throw "Please provide the name of the SQL Database"),
    [Parameter(Mandatory = $false)][string] $UserName,
    [Parameter(Mandatory = $false)][string] $Password,
    [Parameter(Mandatory = $false)][string] $AccessToken,
    [Parameter(Mandatory = $false)][bool] $TrustServerCertificate = $false,
    [Parameter(Mandatory = $false)][string] $ScriptsFolder = "$PSScriptRoot/sqlScripts",
    [Parameter(Mandatory = $false)][string] $ScriptsFileFilter = "*.sql",
    [Parameter(Mandatory = $false)][string] $DatabaseSchema = "dbo",
    [Parameter(Mandatory = $false)][string] $DatabaseVersionTable = "DatabaseVersion"
)

Write-Verbose "Looking for SQL scripts in folder: $ScriptsFolder..."

function Execute-DbCommand($params, [string]$query) {
    $result = Invoke-Sqlcmd @params -Query $query -Verbose -QueryTimeout 180 -ErrorAction Stop -ErrorVariable err
    
    if ($err) {
        throw ($err)
    }
}

function Execute-DbCommandWithResult($params, [string] $query) {
    $result = Invoke-Sqlcmd @params -Query $query -Verbose -ErrorAction Stop -ErrorVariable err

    if ($err) {
        throw ($err)
    }
    return $result
}

function Create-DbParams([string] $DatabaseName, [string] $serverInstance, [string] $UserName = $null, [string] $Password = $null, [string] $AccessToken = $null, [bool] $TrustServerCertificate) {
    Write-Debug "databasename = $DatabaseName"
    Write-Debug "serverinstance = $serverInstance"
    Write-Debug "username = $UserName"
    
    $params = @{
        'Database'               = $DatabaseName
        'ServerInstance'         = $serverInstance        
        'TrustServerCertificate' = $TrustServerCertificate
        'OutputSqlErrors'        = $true
        'AbortOnError'           = $true
    }

    if ($UserName) {        
        $params['UserName'] = $UserName
    }

    if ($Password) {
        $params['Password'] = $Password
    }

    if ($AccessToken) {
        $params['AccessToken'] = $AccessToken
    }

    return $params
}

function Get-SqlScriptFileText([string] $scriptPath, [string] $fileName) {
    $currentfilepath = "$scriptPath/$fileName.sql"
    return $query = Get-Content $currentfilepath
}

$params = Create-DbParams $DatabaseName $ServerName $UserName $Password $AccessToken $TrustServerCertificate

$createDatabaseVersionTable = "IF NOT EXISTS ( SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '$DatabaseVersionTable' AND TABLE_SCHEMA = '$DatabaseSchema' ) " +
"BEGIN " +
"CREATE TABLE [$DatabaseSchema].[$DatabaseVersionTable] " +
"( " +
"   [MajorVersionNumber] INT NOT NULL, " +
"   [MinorVersionNumber] INT NOT NULL, " +
"   [PatchVersionNumber] INT NOT NULL, " +
"   [MigrationDescription] [nvarchar](256) NOT NULL, " +
"   [MigrationDate] DATETIME NOT NULL " +
"   CONSTRAINT [PK_$DatabaseVersionTable] PRIMARY KEY CLUSTERED  ([MajorVersionNumber],[MinorVersionNumber],[PatchVersionNumber]) " +
"                WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) " +
") " +
"END " +
"ELSE " +
"BEGIN " +
"   IF EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$DatabaseVersionTable' AND COLUMN_NAME = 'CurrentVersionNumber' ) " +
"   BEGIN " +
"     ALTER TABLE [$DatabaseSchema].[$DatabaseVersionTable] " +
"         ADD [MajorVersionNumber] INT NULL, " +
"             [MinorVersionNumber] INT NULL, " +
"             [PatchVersionNumber] INT NULL, " +
"             [MigrationDate] DATETIME NULL " +                                                         
"     ALTER TABLE [$DatabaseSchema].[$DatabaseVersionTable] DROP CONSTRAINT [PKDatabaseVersion] " +
"     EXEC ('UPDATE [$DatabaseSchema].[$DatabaseVersionTable] SET MajorVersionNumber = CurrentVersionNumber, MinorVersionNumber = 0, PatchVersionNumber = 0') " +
"     ALTER TABLE [$DatabaseSchema].[$DatabaseVersionTable] ALTER COLUMN [MajorVersionNumber] INT NOT NULL " +
"     ALTER TABLE [$DatabaseSchema].[$DatabaseVersionTable] ALTER COLUMN [MinorVersionNumber] INT NOT NULL " +
"     ALTER TABLE [$DatabaseSchema].[$DatabaseVersionTable] ALTER COLUMN [PatchVersionNumber] INT NOT NULL " +
"     ALTER TABLE [$DatabaseSchema].[$DatabaseVersionTable] DROP COLUMN [CurrentVersionNumber] " +                              
"     ALTER TABLE [$DatabaseSchema].[$DatabaseVersionTable] ADD CONSTRAINT [PK_$DatabaseVersionTable] PRIMARY KEY CLUSTERED ([MajorVersionNumber],[MinorVersionNumber],[PatchVersionNumber]) " +
"   END " +
"END"

Execute-DbCommand $params $createDatabaseVersionTable

$getCurrentDbVersionQuery = "SELECT TOP 1 MajorVersionNumber, MinorVersionNumber, PatchVersionNumber FROM [$DatabaseSchema].[$DatabaseVersionTable] ORDER BY MajorVersionNumber DESC, MinorVersionNumber DESC, PatchVersionNumber DESC"

$databaseVersionNumberDataRow = Execute-DbCommandWithResult $params $getCurrentDbVersionQuery

$databaseVersion = [DatabaseVersion]::new()

if ($null -ne $databaseVersionNumberDataRow) {
    $databaseVersion = [DatabaseVersion]::new([convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[0]), [convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[1]), [convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[2]))    
}

Write-Host "Current database-version number: " $databaseVersion

$files = Get-ChildItem -Path $ScriptsFolder -Filter $ScriptsFileFilter | Sort-Object { ($_.BaseName -split '_')[0] -as [DatabaseVersion] }

# Execute each migration file who's versionnumber is higher then the current DB version
for ($i = 0; $i -lt $files.Count; $i++) {
    $fileName = $files[$i].BaseName

    $fileNameParts = $fileName.Split('_')

    if ($fileNameParts.Length -lt 2) {
        Write-Warning "File $fileName skipped for not having all required name sections (version and description)"
        continue;
    }

    # The version number in the 'version' part of the filename should be one integer number or a semantic version number.
    if ( ($fileNameParts[0] -match "^\d+.\d+.\d+$" -eq $false) -and ($fileNameParts[0] -match "^\d+$" -eq $false)) {
        Write-Warning "File $fileName skipped because version is not valid"
        continue;
    }

    if ($fileNameParts[0] -match "^\d+$") {
        Write-Warning "File $fileName is still using the old naming convention.  Rename the file to $($fileNameParts[0]).0.0_$($fileNameParts[1])$($files[$i].Extension)"
    }

    [DatabaseVersion] $scriptVersionNumber = [DatabaseVersion]::new($fileNameParts[0])
    [string] $migrationDescription = $fileNameParts[1]

    if ($scriptVersionNumber -le $databaseVersion) {
        Write-Verbose "Skipped Migration $scriptVersionNumber as it has already been applied"
        continue
    }

    Write-Host "Executing DB migration " $scriptVersionNumber ": " $migrationDescription "... "

    $migrationScript = [IO.File]::ReadAllText($files[$i].FullName)

    Execute-DbCommand $params $migrationScript

    if ($migrationDescription.Length -gt 256) {
        Write-Warning "Need to truncate the migration description because its size is" $scriptVersionDescription.Length "while the maximum size is 256"
        $migrationDescription = $migrationDescription.Substring(0, 256)
    }
    
    $updateVersionQuery = "INSERT INTO [$DatabaseSchema].[$DatabaseVersionTable] ([MajorVersionNumber], [MinorVersionNumber], [PatchVersionNumber], [MigrationDescription], [MigrationDate]) " +
    "SELECT $($scriptVersionNumber.MajorVersionNumber), $($scriptVersionNumber.MinorVersionNumber), $($scriptVersionNumber.PatchVersionNumber), '$migrationDescription', getdate()"
    
    Execute-DbCommand $params $updateVersionQuery

    Write-Host "DB migration " $scriptVersionNumber " applied!" -ForegroundColor Green

    $databaseVersion = $scriptVersionNumber    
}

# Get New Database Version Number
$databaseVersionNumberDataRow = Execute-DbCommandWithResult $params $getCurrentDbVersionQuery  
$databaseVersionNumber = [DatabaseVersion]::new([convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[0]), [convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[1]), [convert]::ToInt32($databaseVersionNumberDataRow.ItemArray[2]))    
Write-Host "Done migrating database. Current Database version is $databaseVersionNumber" -ForegroundColor Green