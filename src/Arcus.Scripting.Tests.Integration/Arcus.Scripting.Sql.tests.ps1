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

function global:VerifyDatabaseVersionRow ($row, $expectedMajorVersion, $expectedMinorVersion, $expectedPatchVersion) {
    [convert]::ToInt32($row.ItemArray[0]) | Should -Be $expectedMajorVersion
    [convert]::ToInt32($row.ItemArray[1]) | Should -Be $expectedMinorVersion
    [convert]::ToInt32($row.ItemArray[2]) | Should -Be $expectedPatchVersion
}

function global:Create-MigrationTable ($params) {
    $createTable =  "CREATE TABLE dbo.[DatabaseVersion] " +
                    "( " +
                    "   [MajorVersionNumber] INT NOT NULL, " +
                    "   [MinorVersionNumber] INT NOT NULL, " +
                    "   [PatchVersionNumber] INT NOT NULL, " +
                    "   [MigrationDescription] [nvarchar](256) NOT NULL, " +
                    "   [MigrationDate] DATETIME NOT NULL " +
                    "   CONSTRAINT [PK_DatabaseVersion] PRIMARY KEY CLUSTERED  ([MajorVersionNumber],[MinorVersionNumber],[PatchVersionNumber]) " +
                    "				WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) " +
                    ")"

    Run-AzSqlCommand $params $createTable
}

function global:TableExists($params, $tableName) {
    $result = Run-AzSqlQuery $params "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '$tableName' AND TABLE_CATALOG = '$($params.Database)'"

    if ($result.ItemArray[0] -eq 1) {
        return $True
    }

    return $False
}

function global:ColumnExists($params, $tableName, $columnName) {
    $result = Run-AzSqlQuery $params "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$tableName' AND COLUMN_NAME = '$columnName'"

    if ($result.ItemArray[0] -eq 1) {
        return $True
    }

    return $False
}


InModuleScope Arcus.Scripting.Sql {
    Describe "Arcus Azure SQL integration tests" {
        BeforeAll {
            
            $filePath = "$PSScriptRoot\appsettings.json"
            [string]$appsettings = Get-Content $filePath
            $config = ConvertFrom-Json $appsettings
            $params = @{
                'ServerInstance'  = $config.Arcus.Sql.ServerName
                'Database'        = $config.Arcus.Sql.DatabaseName
                'Username'        = $config.Arcus.Sql.UserName
                'Password'        = $config.Arcus.Sql.Password
                'OutputSqlErrors' = $true
                'AbortOnError'    = $true
            }

            & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config

            # Try to open a connection to the SQL database, so that the
            # Azure Database that can be paused, is starting up.  This should
            # avoid having timeout errors during the test themselves.
            try {
                Write-Host "Execute dummy SQL statement to make sure the Azure SQL DB is resumed."
                Invoke-Sqlcmd @params -Query "SELECT TOP 1 FROM INFORMATION_SCHEMA.TABLES" -ConnectionTimeout 60 -Verbose
            }
            catch {
                # We don't care if an exception is thrown; we just want to 'activate' the Azure SQL database
            }
        }
        # BeforeEach {
        #     $filePath = "$PSScriptRoot\appsettings.json"
        #     [string]$appsettings = Get-Content $filePath
        #     $config = ConvertFrom-Json $appsettings
        #     $params = @{
        #         'ServerInstance'  = $config.Arcus.Sql.ServerName
        #         'Database'        = $config.Arcus.Sql.DatabaseName
        #         'Username'        = $config.Arcus.Sql.UserName
        #         'Password'        = $config.Arcus.Sql.Password
        #         'OutputSqlErrors' = $true
        #         'AbortOnError'    = $true
        #     }

        #     & $PSScriptRoot\Connect-AzAccountFromConfig.ps1 -config $config
        # }
        Context "DatabaseVersion table" {
            It "Invoke first SQL migration on empty database creates new DatabaseVersion table" {
                # Arrange
                { Get-AzSqlDatabaseVersion $params } | Should -Throw
                
                try {
                    # Act
                    Invoke-AzSqlDatabaseMigration `
                        -ServerName $config.Arcus.Sql.ServerName `
                        -DatabaseName $config.Arcus.Sql.DatabaseName `
                        -Username $config.Arcus.Sql.Username `
                        -Password $config.Arcus.Sql.Password `
                        -ScriptsFolder "$PSScriptRoot\SqlScripts"

                    # Assert
                    $version = Get-AzSqlDatabaseVersion $params
                    $version.MajorVersionNumber | Should -Be 1
                    $version.MinorVersionNumber | Should -Be 0
                    $version.PatchVersionNumber | Should -Be 0
                }
                finally {
                    Drop-AzSqlDatabaseTable $params "DatabaseVersion"
                }
            }
            It "Invoke first SQL migration with custom schema on empty database creates new DataVersion table with custom schema" {
                # Arrange
                { Get-AzSqlDatabaseVersion $params } | Should -Throw
                $customSchema = "custom"
                Run-AzSqlCommand $params "CREATE SCHEMA $customSchema"

                try {
                    # Act
                    Invoke-AzSqlDatabaseMigration `
                        -ServerName $config.Arcus.Sql.ServerName `
                        -DatabaseName $config.Arcus.Sql.DatabaseName `
                        -Username $config.Arcus.Sql.Username `
                        -Password $config.Arcus.Sql.Password `
                        -DatabaseSchema $customSchema `
                        -ScriptsFolder "$PSScriptRoot\SqlScripts"

                    # Assert
                    $version = Get-AzSqlDatabaseVersion $params $customSchema
                    $version.MajorVersionNumber | Should -Be 1
                    $version.MinorVersionNumber | Should -Be 0
                    $version.PatchVersionNumber | Should -Be 0
                }
                finally {
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

                try {
                    # Act
                    Invoke-AzSqlDatabaseMigration `
                        -ServerName $config.Arcus.Sql.ServerName `
                        -DatabaseName $config.Arcus.Sql.DatabaseName `
                        -Username $config.Arcus.Sql.Username `
                        -Password $config.Arcus.Sql.Password `
                        -ScriptsFolder "$PSScriptRoot\SqlScripts"

                    # Assert
                    $result = Run-AzSqlQuery $params "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DatabaseVersion' AND COLUMN_NAME = 'MajorVersionNumber'" 
                    $result.ItemArray[0] | Should -Be 1
                    $result = Run-AzSqlQuery $params "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DatabaseVersion' AND COLUMN_NAME = 'MinorVersionNumber'"
                    $result.ItemArray[0] | Should -Be 1
                    $result = Run-AzSqlQuery $params "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DatabaseVersion' AND COLUMN_NAME = 'PatchVersionNumber'"
                    $result.ItemArray[0] | Should -Be 1
                    $result = Run-AzSqlQuery $params "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DatabaseVersion' AND COLUMN_NAME = 'CurrentVersionNumber'" 
                    $result.ItemArray[0] | Should -Be 0

                    $version = Get-AzSqlDatabaseVersion $params
                    $version.MajorVersionNumber | Should -Be 1
                    $version.MinorVersionNumber | Should -Be 0
                    $version.PatchVersionNumber | Should -Be 0
                }
                finally {
                    Drop-AzSqlDatabaseTable $params "DatabaseVersion"
                }
            }
            It "Migration scripts are correctly executed" {
                # Arrange: Create the DatabaseVersion table and pre-populate it
                Create-MigrationTable $params

                $addBaselineRecord = "INSERT INTO [DatabaseVersion] ([MajorVersionNumber], [MinorVersionNumber], [PatchVersionNumber], [MigrationDescription], [MigrationDate]) SELECT 0, 0, 1, 'Baseline', getdate()"

                Run-AzSqlCommand $params $addBaselineRecord

                try {
                    # Act: execute the specified migration-scripts
                    Invoke-AzSqlDatabaseMigration `
                        -ServerName $config.Arcus.Sql.ServerName `
                        -DatabaseName $config.Arcus.Sql.DatabaseName `
                        -Username $config.Arcus.Sql.Username `
                        -Password $config.Arcus.Sql.Password `
                        -ScriptsFolder "$PSScriptRoot\SqlScripts\MigrationScriptsAreSuccessfullyExecuted"

                    # Assert
                    # The 'NonExistingTable' should not exist, as we already had a record in DatabaseVersion for 0.0.1, so that 
                    # migration script should not have been executed.
                    $result = TableExists $params 'NonExistingTable'
                    $result | Should -Be $False -Because 'DatabaseVersion was initialized with version that introduced this table, so script should not have been executed'

                    # The 'Customer' table should not exist, as it should have been renamed by one of the migrationscripts
                    $result = TableExists $params 'Customer'
                    $result | Should -Be $False -Because 'Customer table should have been renamed'

                    # The Customer table was renamed to Person
                    $result = TableExists $params 'Person'
                    $result | Should -Be $True -Because 'migration-script renamed Customer table to Person table'

                    $result = ColumnExists $params 'Person' 'Address'
                    $result | Should -Be $True -Because 'Migration script added additional Address column to table'
                    
                    $version = Get-AzSqlDatabaseVersion $params
                    $version.MajorVersionNumber | Should -Be 1
                    $version.MinorVersionNumber | Should -Be 0
                    $version.PatchVersionNumber | Should -Be 0
                }
                finally {
                    Drop-AzSqlDatabaseTable $params "DatabaseVersion"
                    Drop-AzSqlDatabaseTable $params "Person"
                    Drop-AzSqlDatabaseTable $params "Customer"
                }
            }
            It "Old script naming convention is still supported" {
                try {
                    # Act and arrange: execute the specified migration-scripts
                    Invoke-AzSqlDatabaseMigration `
                        -ServerName $config.Arcus.Sql.ServerName `
                        -DatabaseName $config.Arcus.Sql.DatabaseName `
                        -Username $config.Arcus.Sql.Username `
                        -Password $config.Arcus.Sql.Password `
                        -ScriptsFolder "$PSScriptRoot\SqlScripts\OldMigrationScriptsAreStillSupported"
                    
                    $version = Get-AzSqlDatabaseVersion $params
                    $version.MajorVersionNumber | Should -Be 2 -Because "latest migration-script has version number 2"
                    $version.MinorVersionNumber | Should -Be 0 -Because "Old migration scripts are used that do not have a minor version number"
                    $version.PatchVersionNumber | Should -Be 0 -Because "Old migration scripts are used that do not have a patch version number"
                }
                finally {
                    Drop-AzSqlDatabaseTable $params "DatabaseVersion"                    
                }
            }
            It "Combination of old and new migration-script naming convention is supported" {
                try {
                    # Act and arrange: execute the specified migration-scripts
                    Invoke-AzSqlDatabaseMigration `
                        -ServerName $config.Arcus.Sql.ServerName `
                        -DatabaseName $config.Arcus.Sql.DatabaseName `
                        -Username $config.Arcus.Sql.Username `
                        -Password $config.Arcus.Sql.Password `
                        -ScriptsFolder "$PSScriptRoot\SqlScripts\OldAndNewNamingConventionSupported"
                    
                    $version = Get-AzSqlDatabaseVersion $params
                    $version.MajorVersionNumber | Should -Be 3 -Because "latest migration-script has version number 3"
                    $version.MinorVersionNumber | Should -Be 0 
                    $version.PatchVersionNumber | Should -Be 0

                    $versions = Run-AzSqlQuery $params "SELECT MajorVersionNumber, MinorVersionNumber, PatchVersionNumber FROM DatabaseVersion ORDER BY MigrationDate ASC"

                    $versions.Length | Should -Be 6

                    for ($i = 0; $i -lt $versions.Length; $i++) {

                        switch ($i) {
                            0 {
                                VerifyDatabaseVersionRow $versions[$i] 0 0 1
                            }
                            1 {
                                VerifyDatabaseVersionRow $versions[$i] 1 0 0 
                            }
                            2 {
                                VerifyDatabaseVersionRow $versions[$i] 2 0 0
                            }
                            3 {
                                VerifyDatabaseVersionRow $versions[$i] 2 0 1
                            }
                            4 {
                                VerifyDatabaseVersionRow $versions[$i] 2 1 0
                            }
                            5 {
                                VerifyDatabaseVersionRow $versions[$i] 3 0 0
                            }
                        }
                    } 
                }
                finally {
                    Drop-AzSqlDatabaseTable $params "DatabaseVersion"       
                    Drop-AzSqlDatabaseTable $params "Person"
                    Drop-AzSqlDatabaseTable $params "Customer"
                }
            }
            It "Migration Stops on Error" {
                try {
                    # Act and arrange: execute the specified migration-scripts
                    Invoke-AzSqlDatabaseMigration `
                        -ServerName $config.Arcus.Sql.ServerName `
                        -DatabaseName $config.Arcus.Sql.DatabaseName `
                        -Username $config.Arcus.Sql.Username `
                        -Password $config.Arcus.Sql.Password `
                        -ScriptsFolder "$PSScriptRoot\SqlScripts\MigrationStopsOnError" 
                }
                catch {
                    Write-Host "Expected migration error occured"
                }
                finally {
                    $version = Get-AzSqlDatabaseVersion $params
                    $version.MajorVersionNumber | Should -Be 1 -Because "latest successfull migration-script has major version number 1"
                    $version.MinorVersionNumber | Should -Be 0 -Because "latest successfull migration-script has major version number 0"
                    $version.PatchVersionNumber | Should -Be 0 -Because "latest successfull migration-script has major version number 0"

                    Drop-AzSqlDatabaseTable $params "DatabaseVersion"                    
                }
            }
        }
    }
}
