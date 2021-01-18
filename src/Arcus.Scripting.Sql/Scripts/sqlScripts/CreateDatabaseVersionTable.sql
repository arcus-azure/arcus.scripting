CREATE TABLE [dbo].[DatabaseVersion]
(
    [CurrentVersionNumber] INT NOT NULL,
    [MigrationDescription] [nvarchar](256) NOT NULL,
    CONSTRAINT [PKDatabaseVersion] PRIMARY KEY CLUSTERED
    ( 	
        [CurrentVersionNumber] ASC
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)