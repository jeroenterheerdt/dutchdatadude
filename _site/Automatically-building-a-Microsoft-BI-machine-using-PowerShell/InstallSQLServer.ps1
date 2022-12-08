#Install SQL Server
#source: http://msdn.microsoft.com/en-us/library/ms144259.aspx
Function InstallSQLServer
{
Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Password
)
    Write-Log -Verbose  "Step 5: Install SQL Server"
   
    #Remove Service Accounts for SQL in case they already exist
    Get-ADServiceAccount -Filter {DisplayName -like 'SQL Server*'} | Remove-ADServiceAccount
    #Create accounts
    $sqlagentAccountName = "SQLAgent"
    $ssasAccountName = "SSAS"
    $sqldbAccountName = "SQLDB"
    $ssisAccountName = "SSIS"
    $ssrsAccountName = "SSRS"
    $sqlagentAccountNameFQ = $global:domainpart+"\"+$sqlagentAccountName
    $ssasAccountNameFQ = $global:domainpart+"\"+$ssasAccountName
    $sqldbAccountNameFQ = $global:domainpart+"\"+$sqldbAccountName
    $ssisAccountNameFQ = $global:domainpart+"\"+$ssisAccountName
    $ssrsAccountNameFQ = $global:domainpart+"\"+$ssrsAccountName
        
    CreateServiceAccount -AccountName $sqlagentAccountName -DisplayName "SQL Server Agent" -Description "Service Account for SQL Server Agent" -Path $global:path -Password $password
    CreateServiceAccount -AccountName $ssasAccountName -DisplayName "SQL Server Analysis Services" -Description "Service Account for SQL Server Analysis Services" -Path $global:path -Password $password
    CreateServiceAccount -AccountName $sqldbAccountName -DisplayName "SQL Server Database Engine" -Description "Service Account for SQL Server Database Engine" -Path $global:path -Password $password
    CreateServiceAccount -AccountName $ssisAccountName -DisplayName "SQL Server Integration Services" -Description "Service Account for SQL Server Integration Services" -Path $global:path -Password $password
    CreateServiceAccount -AccountName $ssrsAccountName -DisplayName "SQL Server Reporting Services" -Description "Service Account for SQL Server Reporting Services" -Path $global:path -Password $password

    #Make sure the .Net 3.5 feature is enabled
    Install-WindowsFeature –name NET-Framework-Core

    #Mount and Install SQL
    
    $mountresult = Mount-DiskImage -ImagePath $global:pathToSQLISO -PassThru
    $driveLetter = ($mountresult | Get-Volume).DriveLetter
    $setupFile = $driveLetter+":\setup.exe"
    #Run first pass of SQL Install: SQLDB,DQ,FullText,FileStreaming,AS,RSNative,DataQualityCLient,IS,MDS,Tools
    $featuresPass1 = "SQL,AS,RS,DQC,IS,MDS,TOOLS"
    $featuresPass2 = "AS,RS_SHP,RS_SHPWFE"
    
    Start-Process $setupFile -NoNewWindow -Wait -ArgumentList "/ACTION=INSTALL /IACCEPTSQLSERVERLICENSETERMS /Q /INSTANCENAME=MSSQLSERVER /ERRORREPORTING=1 /SQMREPORTING=1 /AGTSVCACCOUNT=$sqlagentAccountNameFQ /AGTSVCPASSWORD=$Password /ASSVCACCOUNT=$ssasAccountNameFQ /ASSVCPASSWORD=$Password /ASSERVERMODE=MULTIDIMENSIONAL /ASSYSADMINACCOUNTS=$global:currentUserName /SQLSVCACCOUNT=$sqldbAccountNameFQ /SQLSVCPASSWORD=$Password /SQLSYSADMINACCOUNTS=$global:currentUserName /FILESTREAMLEVEL=1 /ISSVCACCOUNT=$ssisAccountNameFQ /ISSVCPASSWORD=$Password /RSINSTALLMODE=DefaultNativeMode /RSSVCACCOUNT=$ssrsAccountNameFQ /RSSVCPASSWORD=$Password /FEATURES=$featuresPass1"
    Write-Log -Verbose  "SQL Server Installation Pass 1 completed: SQL, AS Multidimensional, RS Native, Data QUality Client, DQS IS, MDS, TOOLS, FullText, FileStreaming"
    Start-Process $setupFile -NoNewWindow -Wait -ArgumentList "/ACTION=INSTALL /IACCEPTSQLSERVERLICENSETERMS /Q /INSTANCENAME=TABULAR /ERRORREPORTING=1 /SQMREPORTING=1 /ASSVCACCOUNT=$ssasAccountNameFQ /ASSVCPASSWORD=$Password /ASSERVERMODE=TABULAR /ASSYSADMINACCOUNTS=$global:currentUserName /FEATURES=$featuresPass2"
    Write-Log -Verbose  "SQL Server Installation Pass 2 completed: RS SharePoint, AS Tabular"
    Dismount-DiskImage -ImagePath $global:pathToSQLISO
    Write-Log -Verbose  "SQL Server Installed"
    if ($global:DoAllTasks) {
        Set-Restart-AndResume $global:script "7"
        }
}