#Install SharePoint
#source: http://social.technet.microsoft.com/wiki/contents/articles/14582.sharepoint-2013-install-prerequisites-offline-or-manually-on-windows-server-2012-a-comprehensive-guide.aspx#Installing_the_Roles_and_Features_for_SharePoint_2013_on_Windows_Server_2012_Offline_with_PowerShell
#source: http://blogs.msdn.com/b/uksharepoint/archive/2013/03/18/scripted-installation-of-sharepoint-2013-and-office-web-apps-server-from-the-field-part-2.aspx
Function InstallSharePoint
{
    Write-Log -Verbose  "Step 6: Install SharePoint"
    Import-Module ServerManager
    #Add .Net 4.5 features
    Add-WindowsFeature NET-WCF-HTTP-Activation45,NET-WCF-TCP-Activation45,NET-WCF-Pipe-Activation45
    #Add the rest of the needed features for IIS role
    $result = Add-WindowsFeature Net-Framework-Features,Web-Server,Web-WebServer,Web-Common-Http,Web-Static-Content,Web-Default-Doc,Web-Dir-Browsing,Web-Http-Errors,Web-App-Dev,Web-Asp-Net,Web-Net-Ext,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Health,Web-Http-Logging,Web-Log-Libraries,Web-Request-Monitor,Web-Http-Tracing,Web-Security,Web-Basic-Auth,Web-Windows-Auth,Web-Filtering,Web-Digest-Auth,Web-Performance,Web-Stat-Compression,Web-Dyn-Compression,Web-Mgmt-Tools,Web-Mgmt-Console,Web-Mgmt-Compat,Web-Metabase,Application-Server,AS-Web-Support,AS-TCP-Port-Sharing,AS-WAS-Support, AS-HTTP-Activation,AS-TCP-Activation,AS-Named-Pipes,AS-Net-Framework,WAS,WAS-Process-Model,WAS-NET-Environment,WAS-Config-APIs,Web-Lgcy-Scripting,Windows-Identity-Foundation,Server-Media-Foundation,Xps-Viewer
    if($result.RestartNeeded -eq "Yes")
    {
        Set-Restart-AndResume $global:script "7"
    }

    #Mount SharePoint iso
    $mountresult = Mount-DiskImage -ImagePath $global:pathToSharePointISO -PassThru
    $driveLetter = ($mountresult | Get-Volume).DriveLetter
    Write-Log -Verbose  "Installing SharePoint PreReqs...."
    $setupFile = $driveLetter+":\prerequisiteinstaller.exe"
    $process = Start-Process $setupFile -PassThru -Wait -ArgumentList "/unattended /SQLNCli:$global:SharePoint2013Path\PrerequisiteInstallerFiles\sqlncli.msi /IDFX:$global:SharePoint2013Path\PrerequisiteInstallerFiles\Windows6.1-KB974405-x64.msu /IDFX11:$global:SharePoint2013Path\PrerequisiteInstallerFiles\MicrosoftIdentityExtensions-64.msi /Sync:$global:SharePoint2013Path\PrerequisiteInstallerFiles\Synchronization.msi /AppFabric:$global:SharePoint2013Path\PrerequisiteInstallerFiles\WindowsServerAppFabricSetup_x64.exe /KB2671763:$global:SharePoint2013Path\PrerequisiteInstallerFiles\AppFabric1.1-RTM-KB2671763-x64-ENU.exe /MSIPCClient:$global:SharePoint2013Path\PrerequisiteInstallerFiles\setup_msipc_x64.msi /WCFDataServices:$global:SharePoint2013Path\PrerequisiteInstallerFiles\WcfDataServices.exe"
    if($process.ExitCode -eq 0) {
        #install sharepoint
        Write-Log -Verbose  "Installing SharePoint...."
        $path = $driveLetter+":\Setup.exe"
        $sharePointInstallProcess = Start-Process -Wait -PassThru $path -ArgumentList "/config $global:SharePoint2013Path\FarmSilentConfig.xml"
        switch($sharePointInstallProcess.ExitCode)
        {
            0 {
                Write-Log -Verbose  "SharePoint successfully installed"
                Write-Log -Verbose  "SharePoint Installed"
                if ($global:DoAllTasks) {
                    Set-Restart-AndResume $global:script "8"
                    }
            }
            default{
                Write-Log -Verbose  "An error has occured in installing SharePoint. Code: " $sharePointInstallProcess.ExitCode
            }
        }
    }
    else {
        if($process.ExitCode -eq 3010) {
            Write-Log -Verbose  "SharePoint prereqs install requires a reboot"
        }
        else {
            Write-Log -Verbose  "SharePoint prereqs not succesfully installed, please investigate.  Code: " $process.ExitCode
        }
    }

    Dismount-DiskImage -ImagePath $global:pathToSharePointISO
    
}