Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Sql -DisableNameChecking

function global:Get-TestSqlDataTable ($query, $schema, $existing = $true) {
    if ($query -eq 'SELECT TABLE_NAME FROM information_schema.tables') {
        $tableNamesDataTable = New-Object System.Data.DataTable
        $databaseTableNameColumn = New-Object System.Data.DataColumn
        $databaseTableNameColumn.ColumnName = "TableName"
        $databaseTableNameColumn.DataType = [System.Type]::GetType("System.String")
        $tableNamesDataTable.Columns.Add($databaseTableNameColumn)
        $databaseVersionRow = $tableNamesDataTable.NewRow()
        if ($existing) {
            $databaseVersionRow["TableName"] = "DatabaseVersion"
            $tableNamesDataTable.Rows.Add($databaseVersionRow)
        }
        return $tableNamesDataTable
    } elseif ($query -eq "SELECT TOP 1 CurrentVersionNumber FROM [$schema].[DatabaseVersion] ORDER BY CurrentVersionNumber DESC") {
        $databaseVersionDataTable = New-Object System.Data.DataTable
        $currentVersionNumberColumn = New-Object System.Data.DataColumn
        $currentVersionNumberColumn.ColumnName = "CurrentVersionNumber"
        $currentVersionNumberColumn.DataType = [System.Type]::GetType("System.Int32")
        $databaseVersionDataTable.Columns.Add($currentVersionNumberColumn)
        $currentVersionNumberRow = $databaseVersionDataTable.NewRow()
        $currentVersionNumberRow["CurrentVersionNumber"] = 1
        $databaseVersionDataTable.Rows.Add($currentVersionNumberRow)
        return $databaseVersionDataTable
    }
}

Describe "Arcus" {
    Context "Sql" {
        InModuleScope Arcus.Scripting.Sql {
            It "Invoking SQL migration using defaults with new found migration" {
                # Arrange
                $serverName = "my-server"
                $databaseName = "my-database"
                $username = "my-user"
                $password = "my-pass"
                Mock Invoke-Sqlcmd { 
                    $ServerInstance | Should -Be "$serverName.database.windows.net"
                    $Database | Should -Be $databaseName
                    $Username | Should -Be $username
                    $Password | Should -Be $password
                    $dataTable = Get-TestSqlDataTable $Query "dbo"
                    return $dataTable
                } -Verifiable

                $baseName = "Arcus_2_SampleMigration"
                $files = @( [pscustomobject]@{ BaseName = $baseName; FullName = "Container 1-full" } )
                Mock Get-ChildItem { 
                    $Path | Should -BeLike "*sqlScripts"
                    $Filter | Should -Be  "*.sql"
                    return $files 
                } -Verifiable

                $sampleMigration = "Some sample migration"
                Mock Get-Content {
                    $Path | Should -BeLike "*sqlScripts/$baseName.sql"
                    return $sampleMigration
                } -Verifiable

                # Act
                Invoke-AzSqlDatabaseMigration -ServerName $serverName -DatabaseName $databaseName -UserName $username -Password $password

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Invoke-SqlCmd
                Assert-MockCalled Get-Content
                Assert-MockCalled Get-ChildItem
            }
            It "Invoke SQL migration without exising migrations" {
                # Arrange
                $serverName = "my-server"
                $databaseName = "my-database"
                $username = "my-user"
                $password = "my-pass"
                Mock Invoke-Sqlcmd {
                    $ServerInstance | Should -Be "$serverName.database.windows.net"
                    $Database | Should -Be $databaseName
                    $Username | Should -Be $username
                    $Password | Should -Be $password
                    $dataTable = Get-TestSqlDataTable $Query "dbo" -existing $false
                    return $dataTable
                }

                $baseName = "Arcus_1_SampleMigration"
                $files = @( [pscustomobject]@{ BaseName = $baseName; FullName = "Container 1-full" } )
                Mock Get-ChildItem { 
                    $Path | Should -BeLike "*sqlScripts"
                    $Filter | Should -Be  "*.sql"
                    return $files 
                } -Verifiable

                $sampleMigration = "Some sample migration"
                Mock Get-Content {
                    $Path | Should -BeLike "*sqlScripts/$baseName.sql"
                    return $sampleMigration
                } -Verifiable

                # Act
                Invoke-AzSqlDatabaseMigration -ServerName $serverName -DatabaseName $databaseName -UserName $username -Password $password

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Invoke-SqlCmd
                Assert-MockCalled Get-Content
                Assert-MockCalled Get-ChildItem
            }
            It "Invoke SQL migration using custom values with new found migration" {
                # Arrange
                $serverName = "my-server"
                $databaseName = "my-database"
                $username = "my-user"
                $password = "my-pass"
                $databaseSchema = "custom"
                Mock Invoke-Sqlcmd { 
                    $ServerInstance | Should -Be "$serverName.database.windows.net"
                    $Database | Should -Be $databaseName
                    $Username | Should -Be $username
                    $Password | Should -Be $password
                    $dataTable = Get-TestSqlDataTable $Query $databaseSchema
                    if ($Query -like "INSERT *") {
                        $Query | Should -Match "INSERT INTO \[$databaseSchema\]*"
                    }
                    return $dataTable
                } -Verifiable

                $scriptsFolder = "sql-scripts"
                $scriptsFileFilter = "*.mysql"
                $baseName = "Arcus_2_SampleMigration"
                $files = @( [pscustomobject]@{ BaseName = $baseName; FullName = "Container 1-full" } )
                Mock Get-ChildItem { 
                    $Path | Should -BeLike "*$scriptsFolder"
                    $Filter | Should -Be  $scriptsFileFilter
                    return $files 
                } -Verifiable

                $sampleMigration = "Some sample migration"
                Mock Get-Content {
                    $Path | Should -BeLike "*$scriptsFolder/$baseName.sql"
                    return $sampleMigration
                } -Verifiable

                # Act
                Invoke-AzSqlDatabaseMigration -ServerName $serverName -DatabaseName $databaseName -UserName $username -Password $password -ScriptsFolder $scriptsFolder -ScriptsFileFilter $scriptsFileFilter -DatabaseSchema $databaseSchema

                # Assert
                Assert-VerifiableMock
                Assert-MockCalled Invoke-SqlCmd
                Assert-MockCalled Get-Content
                Assert-MockCalled Get-ChildItem
            }
        }
    }
}