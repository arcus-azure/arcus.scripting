Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Sql -DisableNameChecking

Describe "Arcus" {
    Context "Sql" {
        InModuleScope Arcus.Scripting.Sql {
            It "Invoking SQL migration with defaults" {
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

                    if ($query -eq 'SELECT TABLE_NAME FROM information_schema.tables') {
                        $tableNamesDataTable = New-Object System.Data.DataTable
                        $databaseTableNameColumn = New-Object System.Data.DataColumn
                        $databaseTableNameColumn.ColumnName = "TableName"
                        $databaseTableNameColumn.DataType = [System.Type]::GetType("System.String")
                        $tableNamesDataTable.Columns.Add($databaseTableNameColumn)
                        $databaseVersionRow = $tableNamesDataTable.NewRow()
                        $databaseVersionRow["TableName"] = "DatabaseVersion"
                        $tableNamesDataTable.Rows.Add($databaseVersionRow)
                        return $tableNamesDataTable
                    } elseif ($query -eq 'SELECT TOP 1 CurrentVersionNumber FROM DatabaseVersion ORDER BY CurrentVersionNumber DESC') {
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
                } -Verifiable

                $baseName = "Arcus_2_SampleMigration"
                $files = @( [pscustomobject]@{ BaseName = $baseName; FullName = "Container 1-full" } )
                Mock Get-ChildItem { 
                    $Path | Should -BeLike "*sqlScripts"
                    $Filter | Should -Be  ".sql"
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
        }
    }
}