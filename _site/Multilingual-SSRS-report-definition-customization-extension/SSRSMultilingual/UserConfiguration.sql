CREATE TABLE [dbo].[UserConfiguration]
(
    [UserName] VARCHAR(MAX) NOT NULL, 
    [Language] VARCHAR(50) NOT NULL, 
    [Id] INT NOT NULL IDENTITY, 
    CONSTRAINT [PK_UserConfiguration] PRIMARY KEY ([Id]) 
)
