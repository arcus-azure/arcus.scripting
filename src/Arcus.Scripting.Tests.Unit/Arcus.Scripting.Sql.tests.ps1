using module .\..\Arcus.Scripting.Sql\Arcus.Scripting.Sql.psd1
Import-Module -Name $PSScriptRoot\..\Arcus.Scripting.Sql -ErrorAction Stop

InModuleScope Arcus.Scripting.Sql {
    Describe "Arcus Azure SQL unit tests" {
        Context "Azure SQL database version" {
            It "Passing major minor patch seperatly to string" {
                # Arrange
                $major = 2
                $minor = 4
                $patch = 12
                $version = [DatabaseVersion]::new($major, $minor, $patch)

                # Act
                $versionString = $version.ToString()

                # Assert
                $versionString | Should -Be "$major.$minor.$patch"
            }
            It "Passing major minor patch version string gets splitted in properties" {
                # Arrange
                $major = 2
                $minor = 4
                $patch = 12
                $versionString = "$major.$minor.$patch"

                # Act
                $version = [DatabaseVersion]::new($versionString)

                # Assert
                $version.MajorVersionNumber | Should -Be $major
                $version.MinorVersionNumber | Should -Be $minor
                $version.PatchVersionNumber | Should -Be $patch
            }
            It "Passing old version string results in major version" {
                # Arrange
                $major = 2
                $versionString = $major.ToString()

                # Act
                $version = [DatabaseVersion]::new($versionString)

                # Assert
                $version.MajorVersionNumber | Should -Be $major
                $version.MinorVersionNumber | Should -Be 0
                $version.PatchVersionNumber | Should -Be 0
                $version.ToString() | Should -Be "$major.0.0"
            }
            It "Database version with higher major is greater than other" {
                # Arrange
                $higherVersion = [DatabaseVersion]::new(2, 1, 3)
                $lowerVersion = [DatabaseVersion]::new(1, 9, 2)

                # Act
                $result = $higherVersion.CompareTo($lowerVersion)

                # Assert
                $result | Should -Be 1
                $lowerVersion.CompareTo($higherVersion) | Should -Be -1
            }
            It "Database version with higher minor is greater than other" {
                # Arrange
                $higherVersion = [DatabaseVersion]::new(3, 4, 1)
                $lowerVersion = [DatabaseVersion]::new(3, 3, 6)

                # Act
                $result = $higherVersion.CompareTo($lowerVersion)

                # Assert
                $result | Should -Be 1
                $lowerVersion.CompareTo($higherVersion) | Should -Be -1
            }
            It "Database version with higher patch is greater than other" {
                # Arrange
                $higherVersion = [DatabaseVersion]::new(4, 9, 2)
                $lowerVersion = [DatabaseVersion]::new(4, 9, 1)

                # Act
                $result = $higherVersion.CompareTo($lowerVersion)

                # Assert
                $result | Should -Be 1
                $lowerVersion.CompareTo($higherVersion) | Should -Be -1
            }
            It "Database version with different major is not equal to other" {
                # Arrange
                $thisVersion = [DatabaseVersion]::new(2, 9, 4)
                $otherVersion = [DatabaseVersion]::new(3, 9, 4)

                # Act
                $result = $thisVersion.Equals($otherVersion)

                # Assert
                $result | Should -Be $false
            }
            It "Database version with different minor is not equal to other" {
                # Arrange
                $thisVersion = [DatabaseVersion]::new(2, 10, 4)
                $otherVersion = [DatabaseVersion]::new(2, 11, 4)

                # Act
                $result = $thisVersion.Equals($otherVersion)

                # Assert
                $result | Should -Be $false
            }
            It "Database version with different patch is not equal to other" {
                # Arrange
                $thisVersion = [DatabaseVersion]::new(2, 6, 3)
                $otherVersion = [DatabaseVersion]::new(2, 6, 2)

                # Act
                $result = $thisVersion.Equals($otherVersion)

                # Assert
                $result | Should -Be $false
            }
            It "Database version with same major minor patch is equal to other" {
                # Arrange
                $thisVersion = [DatabaseVersion]::new(1, 2, 3)
                $otherVersion = [DatabaseVersion]::new(1, 2, 3)

                # Act
                $result = $thisVersion.Equals($otherVersion)

                # Assert
                $result | Should -Be $true
            }
            It "Passing invalid version throws exception" {
                { [DatabaseVersion]::new("1.0") } | Should-Throw
                { [DatabaseVersion]::new("1.") } | Should-Throw
                { [DatabaseVersion]::new("1.1.1.") } | Should-Throw
                { [DatabaseVersion]::new("1.1.1.1") } | Should-Throw
            }
        }
        Context "Invoke Azure SQL database migration" {
            It "Invoking SQL migration without server name fails" {
                # Arrange
                $serverName = $null
                $databaseName = "my-database"
                $username = "my-user"
                $password = "my-pass"

                # Act / Assert
                { Invoke-AzSqlDatabaseMigration -ServerName $serverName -DatabaseName $databaseName -UserName $username -Password $password } |
                    Should -Throw
            }
            It "Invoke SQL migration without database name fails" {
                # Arrange
                $serverName = "my-server"
                $database = $null
                $username = "my-user"
                $password = "my-pass"

                # Act / Assert
                 { Invoke-AzSqlDatabaseMigration -ServerName $serverName -DatabaseName $databaseName -UserName $username -Password $password } |
                    Should -Throw
            }
            It "Invoke SQL migration without username fails" {
                # Arrange
                $serverName = "my-server"
                $database = "my-database"
                $username = $null
                $password = "my-pass"

                # Act / Assert
                 { Invoke-AzSqlDatabaseMigration -ServerName $serverName -DatabaseName $databaseName -UserName $username -Password $password } |
                    Should -Throw
            }
            It "Invoke SQL migration without password fails" {
                # Arrange
                $serverName = "my-server"
                $database = "my-database"
                $username = "my-user"
                $password = $null

                # Act / Assert
                 { Invoke-AzSqlDatabaseMigration -ServerName $serverName -DatabaseName $databaseName -UserName $username -Password $password } |
                    Should -Throw
            }
        }
    }
}