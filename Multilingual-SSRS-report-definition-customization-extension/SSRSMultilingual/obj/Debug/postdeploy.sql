/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
USE [SSRSMultilingual]
GO

INSERT INTO [dbo].[UserConfiguration]
           ([UserName]
           ,[Language])
     VALUES
           ('MARSDEMO\Administrator', 'en-us'),('MARSDEMO\jterh','nl-nl')

INSERT INTO [dbo].[Items]
           ([Name])
     VALUES
           ('Products'),('Departments')

INSERT INTO [dbo].[Translations]
           ([Item]
           ,[Language]
           ,[Value])
     VALUES
            (1, 'en-us','Products')
		   ,(1,'nl-nl','Producten')
		   ,(2,'en-us','Departments')
		   ,(2,'nl-nl','Afdelingen')
GO
