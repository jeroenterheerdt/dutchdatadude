﻿/*
Deployment script for SSRSMultilingual

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "SSRSMultilingual"
:setvar DefaultFilePrefix "SSRSMultilingual"
:setvar DefaultDataPath "C:\Users\Administrator\AppData\Local\Microsoft\VisualStudio\SSDT\SSRSMultilingualRDCE\"
:setvar DefaultLogPath "C:\Users\Administrator\AppData\Local\Microsoft\VisualStudio\SSDT\SSRSMultilingualRDCE\"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
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
           ('Administrator', 'en-us'),('jterh','nl-nl')

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

GO
PRINT N'Update complete.';


GO
