#ConfigureMDS

#source: 
Function ConfigureMDS
{
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Password
    )
    Write-Log -Verbose  "Step 10: Configure MDS"    try {    $mdsAccount = "MasterDataServices"    $mdsAccountFQ = $global:domainpart+"\"+$mdsAccount    CreateServiceAccount -AccountName $mdsAccount -DisplayName "Master Data Services" -Description "Account for Master Data Services" -Path $global:path -Password $Password -Delete $true    Write-Log -Verbose  "Now launching MDS Config tool, since there is no command line version available. Please set up MDS and MDS database connection."    Write-Log -Verbose  "Advice: use MasterDataServices as database name"    Write-Log -Verbose  "Use port 81 for the web application and use the following credential as application identity:"    Write-Log -Verbose  "Username: $mdsAccountFQ"    Write-Log -Verbose  "Password: $Password"    Start-Process "C:\Program Files\Microsoft SQL Server\120\Master Data Services\Configuration\MDSConfigTool.exe" -Wait    Write-Log -Verbose  "MDS Configured."
    if ($global:DoAllTasks) {
        Set-Restart-AndResume $global:script "12"
        }
    }
    catch {
        Write-Log -Verbose  "Failed to configure MDS. Error: $_.Exception.Message"
    }
}
