#ConfigureDQS

#source: http://msdn.microsoft.com/en-us/library/hh231682.aspx#CommandPrompt
#source: http://dutchdatadude.com/mds-dqs-integration-on-a-domain-controller/
Function ConfigureDQS
{
    Write-Log -Verbose  "Step 11: Configure DQS"    try {    Start-Process "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Binn\DQSInstaller.exe" -Wait -NoNewWindow -ArgumentList "-install -instance MSSQLSERVER"
    Write-Log -Verbose  "DQS Configured."

    #fix some problems with enabling DQS/MDS configuration on a domain controller
    #create a windows user login
    Invoke-Sqlcmd -ServerInstance "." -Query "USE [master] CREATE LOGIN [JTERHDEMO\MDS_ServiceAccounts] FROM WINDOWS WITH DEFAULT_DATABASE=[DQS_MAIN]"
    #add roles
    Invoke-Sqlcmd -ServerInstance "." -Query "use [DQS_MAIN] IF NOT EXISTS (SELECT * FROM SYS.SYSUSERS WHERE NAME = 'MDS_ServiceAccounts') CREATE USER [MDS_ServiceAccounts] FOR LOGIN [$global:domainpart\MDS_ServiceAccounts] exec sp_addrolemember @rolename=N'dqs_administrator',@membername=N'MDS_ServiceAccounts'"    Write-Log -Verbose  "Now that DQS has been installed, lets open up the Master Data Services configuration and make sure the integration with DQS is enabled."
    Start-Process "C:\Program Files\Microsoft SQL Server\120\Master Data Services\Configuration\MDSConfigTool.exe" -Wait
    Write-Log -Verbose  "DQS Configured and MDS integration has been set up"
    if ($global:DoAllTasks) {
        Set-Restart-AndResume $global:script "13"
        }

    }
    catch {
        Write-Log -Verbose  "Failed to configure DQS. Error: $_.Exception.Message"
    }
}
