Import-Module SqlServer
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Sql -ErrorAction Stop

function global:Run-AzSqlCommand ($params, $command) {
    Invoke-Sqlcmd @params -Query $command -Verbose -QueryTimeout 180 -ConnectionTimeout 60 -ErrorAction Stop -ErrorVariable err
    if ($err) {
        throw ($err)
    }
}

function global:Run-AzSqlQuery ($params, $query) {
    $result = Invoke-Sqlcmd @params -Query $query -Verbose -ConnectionTimeout 60 -ErrorAction Stop -ErrorVariable err
    if ($err) {
        throw ($err)
    }
    return $result
}

function global:Drop-AzSqlDatabaseTable ($params, $databaseTable, $schema = "dbo") {
    Run-AzSqlCommand $params "DROP TABLE IF EXISTS [$schema].[$databaseTable]"
}

function global:Get-AzSqlDatabaseVersion ($params, $schema = "dbo") {
    $row = Run-AzSqlQuery $params "SELECT TOP 1 MajorVersionNumber, MinorVersionNumber, PatchVersionNumber FROM [$schema].[DatabaseVersion] ORDER BY MajorVersionNumber DESC, MinorVersionNumber DESC, PatchVersionNumber DESC"

    $version = [DatabaseVersion]::new()
    if (($null -ne $row) -and ($null -ne $row.ItemArray) -and ($row.ItemArray.Length -ge 3) ) {
        $version = [DatabaseVersion]::new(
            [convert]::ToInt32($row.ItemArray[0]),
            [convert]::ToInt32($row.ItemArray[1]),
            [convert]::ToInt32($row.ItemArray[2]))
    }

    return $version
}

function global:AssertDatabaseVersion ($row, [DatabaseVersion] $expectedVersion) {
    [convert]::ToInt32($row.ItemArray[0]) | Should -Be $expectedVersion.MajorVersionNumber
    [convert]::ToInt32($row.ItemArray[1]) | Should -Be $expectedVersion.MinorVersionNumber
    [convert]::ToInt32($row.ItemArray[2]) | Should -Be $expectedVersion.PatchVersionNumber
}

function global:Create-MigrationTable ($params) {
    $createTable = "CREATE TABLE dbo.[DatabaseVersion] " +
    "( " +
    "   [MajorVersionNumber] INT NOT NULL, " +
    "   [MinorVersionNumber] INT NOT NULL, " +
    "   [PatchVersionNumber] INT NOT NULL, " +
    "   [MigrationDescription] [nvarchar](256) NOT NULL, " +
    "   [MigrationDate] DATETIME NOT NULL " +
    "   CONSTRAINT [PK_DatabaseVersion] PRIMARY KEY CLUSTERED  ([MajorVersionNumber],[MinorVersionNumber],[PatchVersionNumber]) " +
    "       WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) " +
    ")"

    Run-AzSqlCommand $params $createTable
}

function global:TableExists ($params, $tableName) {
    $result = Run-AzSqlQuery $params "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '$tableName' AND TABLE_CATALOG = '$($params.Database)'"

    if ($result.ItemArray[0] -eq 1) {
        return $true
    }

    return $false
}

function global:ColumnExists ($params, $tableName, $columnName) {
    $result = Run-AzSqlQuery $params "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$tableName' AND COLUMN_NAME = '$columnName'"

    if ($result.ItemArray[0] -eq 1) {
        return $true
    }

    return $false
}

function global:Retry-Function ($func, $retryCount = 5, $retryIntervalSeconds = 1) {
    $attempt = 0
    $success = $false
    $result = $null
    do {
        try {
            $result = & $func
            $success = $true
        } catch {
            if (++$attempt -eq $retryCount) {
                Write-Error "Task failed. With all $attempt attempts. Error: $($_.Exception.ToString()) $($Error[0])"
                throw
            }

            Write-Host "Task failed. Attempt $attempt. Will retry in next $retryIntervalSeconds seconds. Error: $($Error[0])" -ForegroundColor Yellow
            Start-Sleep -Seconds $retryIntervalSeconds
        }
    } until ($success)
    return $result
}


InModuleScope Arcus.Scripting.Sql {
    Describe "Arcus Azure SQL integration tests" {
        BeforeAll {
            $config = & $PSScriptRoot\Load-JsonAppsettings.ps1
            $serverInstance = If($config.Arcus.Sql.UseLocalDb) { $config.Arcus.Sql.ServerName } Else { $config.Arcus.Sql.ServerName + '.database.windows.net' }
            $params = @{
                'ServerInstance'         = $serverInstance
                'Database'               = $config.Arcus.Sql.DatabaseName
                'Username'               = $config.Arcus.Sql.UserName
                'Password'               = $config.Arcus.Sql.Password
                'TrustServerCertificate' = $config.Arcus.Sql.TrustServerCertificate
                'OutputSqlErrors'        = $true
                'AbortOnError'           = $true
            }

            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config

            # Try to open a connection to the SQL database, 
            # so that the Azure Database that can be paused, is starting up.  
            # This should avoid having timeout errors during the test themselves.
            try {
                Write-Host "Execute dummy SQL statement to make sure the Azure SQL DB is resumed."
                Invoke-Sqlcmd @params -Query "SELECT TOP 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES" -ConnectionTimeout 60 -Verbose -ErrorAction SilentlyContinue
            } catch {
                # We don't care if an exception is thrown; we just want to 'activate' the Azure SQL database.
                Write-Debug "We don't care if an exception is thrown; we just want to 'activate' the Azure SQL database."
            }

            $tables = Retry-Function { Run-AzSqlQuery $params "SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES" }
            foreach ($table in $tables) {
                try {
                    Write-Verbose "Drop table $($table.TABLE_NAME) in SQL database"
                    Drop-AzSqlDatabaseTable $params $table.TABLE_NAME $table.TABLE_SCHEMA
                } catch {
                    Write-Warning "Could not drop table '$($table.TABLE_NAME)' due to an exception: $($_.Exception.Message)"
                }
            }
        }
        AfterEach {
            Drop-AzSqlDatabaseTable $params "DatabaseVersion"
        }
        Context "DatabaseVersion table" {
            It "Invoke first SQL migration on empty database creates new DatabaseVersion table" {
                # Arrange
                { Get-AzSqlDatabaseVersion $params } | Should -Throw
                
                # Act
                Invoke-AzSqlDatabaseMigration `
                    -ServerName $serverInstance `
                    -DatabaseName $config.Arcus.Sql.DatabaseName `
                    -Username $config.Arcus.Sql.Username `
                    -Password $config.Arcus.Sql.Password `
                    -TrustServerCertificate:([bool]::Parse($config.Arcus.Sql.TrustServerCertificate)) `
                    -ScriptsFolder "$PSScriptRoot\SqlScripts"

                # Assert
                $version = Get-AzSqlDatabaseVersion $params
                $version.MajorVersionNumber | Should -Be 1
                $version.MinorVersionNumber | Should -Be 0
                $version.PatchVersionNumber | Should -Be 0
            }
            It "Invoke first SQL migration with custom schema on empty database creates new DataVersion table with custom schema" {
                # Arrange
                { Get-AzSqlDatabaseVersion $params } | Should -Throw

                try {
                    $customSchema = "custom"
                    Run-AzSqlCommand $params "CREATE SCHEMA $customSchema"

                    # Act
                    Invoke-AzSqlDatabaseMigration `
                        -ServerName $serverInstance `
                        -DatabaseName $config.Arcus.Sql.DatabaseName `
                        -Username $config.Arcus.Sql.Username `
                        -Password $config.Arcus.Sql.Password `
                        -TrustServerCertificate:([bool]::Parse($config.Arcus.Sql.TrustServerCertificate)) `
                        -DatabaseSchema $customSchema `
                        -ScriptsFolder "$PSScriptRoot\SqlScripts"

                    # Assert
                    $version = Get-AzSqlDatabaseVersion $params $customSchema
                    $version.MajorVersionNumber | Should -Be 1
                    $version.MinorVersionNumber | Should -Be 0
                    $version.PatchVersionNumber | Should -Be 0
                } finally {      
                    Drop-AzSqlDatabaseTable $params "DatabaseVersion" $customSchema
                    Run-AzSqlCommand $params "DROP SCHEMA $customSchema"
                }
            }
            It "Old DatabaseVersion table is converted to new table structure" {
                # Arrange
                $createOldDatabaseVersionTable = "CREATE TABLE [dbo].[DatabaseVersion] ( `
                    [CurrentVersionNumber] INT NOT NULL, `
                    [MigrationDescription] [nvarchar](256) NOT NULL, `
                    CONSTRAINT [PKDatabaseVersion] PRIMARY KEY CLUSTERED `
                    ( `
                        [CurrentVersionNumber] ASC `
                    ) `
                    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) `
                ) "
                Run-AzSqlCommand $params $createOldDatabaseVersionTable
                
                # Act
                Invoke-AzSqlDatabaseMigration `
                    -ServerName $serverInstance `
                    -DatabaseName $config.Arcus.Sql.DatabaseName `
                    -Username $config.Arcus.Sql.Username `
                    -Password $config.Arcus.Sql.Password `
                    -TrustServerCertificate:([bool]::Parse($config.Arcus.Sql.TrustServerCertificate)) `
                    -ScriptsFolder "$PSScriptRoot\SqlScripts"

                # Assert
                $result = Run-AzSqlQuery $params "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DatabaseVersion' AND COLUMN_NAME = 'MajorVersionNumber' AND TABLE_SCHEMA = 'dbo'" 
                $result.ItemArray[0] | Should -Be 1 -Because "MajorVersionNumber column should be present"
                $result = Run-AzSqlQuery $params "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DatabaseVersion' AND COLUMN_NAME = 'MinorVersionNumber' AND TABLE_SCHEMA = 'dbo'"
                $result.ItemArray[0] | Should -Be 1 -Because "MinorVersionNumber column should be present"
                $result = Run-AzSqlQuery $params "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DatabaseVersion' AND COLUMN_NAME = 'PatchVersionNumber' AND TABLE_SCHEMA = 'dbo'"
                $result.ItemArray[0] | Should -Be 1 -Because "PatchVersionNumber column should be present"
                $result = Run-AzSqlQuery $params "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DatabaseVersion' AND COLUMN_NAME = 'CurrentVersionNumber' AND TABLE_SCHEMA = 'dbo'" 
                $result.ItemArray[0] | Should -Be 0 -Because "CurrentVersionNumber column should no longer be present with new table-structure"

                $version = Get-AzSqlDatabaseVersion $params
                $version.MajorVersionNumber | Should -Be 1
                $version.MinorVersionNumber | Should -Be 0
                $version.PatchVersionNumber | Should -Be 0
            }
        }
        Context "Migrations - Happy Path" {
            It "Multiple migrations are invoked in the correct order, ignoring lower version migrations" {
                # Arrange: Create the DatabaseVersion table and pre-populate it
                Create-MigrationTable $params

                $addBaselineRecord = "INSERT INTO [DatabaseVersion] ([MajorVersionNumber], [MinorVersionNumber], [PatchVersionNumber], [MigrationDescription], [MigrationDate]) SELECT 0, 0, 1, 'Baseline', getdate()"

                Run-AzSqlCommand $params $addBaselineRecord

                try {
                    # Act: execute the specified migration-scripts
                    Invoke-AzSqlDatabaseMigration `
                        -ServerName $serverInstance `
                        -DatabaseName $config.Arcus.Sql.DatabaseName `
                        -Username $config.Arcus.Sql.Username `
                        -Password $config.Arcus.Sql.Password `
                        -TrustServerCertificate:([bool]::Parse($config.Arcus.Sql.TrustServerCertificate)) `
                        -ScriptsFolder "$PSScriptRoot\SqlScripts\MigrationScriptsAreSuccessfullyExecuted"

                    # Assert
                    # The MigrationScriptsAreSuccessfullyExecuted folder contains a file which has version-number 0.0.1
                    # That migration-file creates the table 'NonExistingTable', however, when setting up this testcase
                    # we have inserted a record in the DatabaseVersion-table which indicates that this version/migration-file was already
                    # executed. If the Invoke-AzSqlDatabaseMigration script runs correctly, it should skip the migration-file with version 0.0.1
                    # which means that the table 'NonExistingTable' should not exist in the DB.
                    # If it does exist in the DB, then it means that the 0.0.1 migration-script was executed anyway.
                    $result = TableExists $params 'NonExistingTable'
                    $result | Should -Be $false -Because 'DatabaseVersion was initialized with version that introduced this table, so script should not have been executed'

                    # A migration-script in the MigrationScriptsAreSuccessfullyExecuted folder contains a migration-file
                    # that creates the Customer table.
                    # However, there also exists a migration-script with a higher version in that folder which renames the
                    # Customer table to 'Person'.  This means that the Customer table should not exist anymore.
                    $result = TableExists $params 'Customer'
                    $result | Should -Be $false -Because 'Customer table should have been renamed'

                    # The Customer table was renamed to Person
                    $result = TableExists $params 'Person'
                    $result | Should -Be $true -Because 'migration-script renamed Customer table to Person table'

                    # After the Customer table has been renamed to Person, another migration-script
                    # should have added a new column (Address) to the Person table.
                    $result = ColumnExists $params 'Person' 'Address'
                    $result | Should -Be $true -Because 'Migration script added additional Address column to table'
                    
                    $version = Get-AzSqlDatabaseVersion $params
                    $version.MajorVersionNumber | Should -Be 1
                    $version.MinorVersionNumber | Should -Be 0
                    $version.PatchVersionNumber | Should -Be 0
                } finally {                    
                    Drop-AzSqlDatabaseTable $params "Person"
                    Drop-AzSqlDatabaseTable $params "Customer"
                }
            }
        }
        Context "Migrations - Unhappy path" {
            It "Multiple migrations are invoked until error encountered" {
                
                # Act and arrange: execute the specified migration-scripts
                { Invoke-AzSqlDatabaseMigration `
                        -ServerName $serverInstance `
                        -DatabaseName $config.Arcus.Sql.DatabaseName `
                        -Username $config.Arcus.Sql.Username `
                        -Password $config.Arcus.Sql.Password `
                        -TrustServerCertificate:([bool]::Parse($config.Arcus.Sql.TrustServerCertificate)) `
                        -ScriptsFolder "$PSScriptRoot\SqlScripts\MigrationStopsOnError" } | Should -Throw

                $version = Get-AzSqlDatabaseVersion $params
                $version.MajorVersionNumber | Should -Be 1 -Because "latest successfull migration-script has major version number 1"
                $version.MinorVersionNumber | Should -Be 0 -Because "latest successfull migration-script has major version number 0"
                $version.PatchVersionNumber | Should -Be 0 -Because "latest successfull migration-script has major version number 0"                                                 
            }
        }
        Context "MigrationScripts - naming convention" {
            It "Old script naming convention is still supported" {
                
                # Act: execute migration-scripts where the naming convention of those files
                #      is a mix between the old (versionnumber_description.sql) naming convention
                #      and the new (major.minor.patch_description.sql) naming convention.
                Invoke-AzSqlDatabaseMigration `
                    -ServerName $serverInstance `
                    -DatabaseName $config.Arcus.Sql.DatabaseName `
                    -Username $config.Arcus.Sql.Username `
                    -Password $config.Arcus.Sql.Password `
                    -TrustServerCertificate:([bool]::Parse($config.Arcus.Sql.TrustServerCertificate)) `
                    -ScriptsFolder "$PSScriptRoot\SqlScripts\OldMigrationScriptsAreStillSupported"
                    
                $version = Get-AzSqlDatabaseVersion $params
                $version.MajorVersionNumber | Should -Be 2 -Because "latest migration-script has version number 2"
                $version.MinorVersionNumber | Should -Be 0 -Because "Old migration scripts are used that do not have a minor version number"
                $version.PatchVersionNumber | Should -Be 0 -Because "Old migration scripts are used that do not have a patch version number"                
            }
            It "Combination of old and new migration-script naming convention is supported" {
                try {
                    # Act and arrange: execute the specified migration-scripts
                    Invoke-AzSqlDatabaseMigration `
                        -ServerName $serverInstance `
                        -DatabaseName $config.Arcus.Sql.DatabaseName `
                        -Username $config.Arcus.Sql.Username `
                        -Password $config.Arcus.Sql.Password `
                        -TrustServerCertificate:([bool]::Parse($config.Arcus.Sql.TrustServerCertificate)) `
                        -ScriptsFolder "$PSScriptRoot\SqlScripts\OldAndNewNamingConventionSupported"
                    
                    $version = Get-AzSqlDatabaseVersion $params
                    $version.MajorVersionNumber | Should -Be 3 -Because "latest migration-script has version number 3"
                    $version.MinorVersionNumber | Should -Be 0 
                    $version.PatchVersionNumber | Should -Be 0

                    $versions = Run-AzSqlQuery $params "SELECT MajorVersionNumber, MinorVersionNumber, PatchVersionNumber FROM DatabaseVersion ORDER BY MigrationDate ASC"

                    $versions.Length | Should -Be 6

                    $expectedVersions = @(
                        [DatabaseVersion]::new(0, 0, 1),
                        [DatabaseVersion]::new(1, 0, 0),
                        [DatabaseVersion]::new(2, 0, 0),
                        [DatabaseVersion]::new(2, 0, 1),
                        [DatabaseVersion]::new(2, 1, 0),
                        [DatabaseVersion]::new(3, 0, 0)
                    )

                    for ($i = 0; $i -lt $versions.Length; $i++) {
                        AssertDatabaseVersion $versions[$i] $expectedVersions[$i]
                    }
                } finally {
                    Drop-AzSqlDatabaseTable $params "Person"
                    Drop-AzSqlDatabaseTable $params "Customer"
                }
            }
        }
    }
}
