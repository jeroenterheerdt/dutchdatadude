CREATE TABLE [dbo].[Translations]
(
	[Id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [Item] INT NOT NULL, 
    [Language] VARCHAR(50) NOT NULL, 
    [Value] NVARCHAR(MAX) NOT NULL, 
    CONSTRAINT [FK_Translations_ToTable] FOREIGN KEY ([Item]) REFERENCES [Items]([Id]), 
    
    
)
