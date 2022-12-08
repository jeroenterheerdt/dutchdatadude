#Set up Active Directory
#source: http://blogs.technet.com/b/ashleymcglone/archive/2013/04/18/touch-free-powershell-dcpromo-in-windows-server-2012.aspx
Function SetupActiveDirectory {
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Domain name required, please specify in format yyy.zzz")]
        [ValidateNotNullOrEmpty()]
        $DomainName
    )
    Write-Log -Verbose  "Step 2: Set up Active Directory"
    
    try {
        Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
        if ($global:DoAllTasks) {
            Set-Restart-AndResume $global:script "3"
        }
    }
    catch {
        Write-Log -Verbose  "Failed to set up Active Directory. Error: $_.Exception.Message"
    }
}
Function SetupActiveDirectoryPart2 {
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Domain name required, please specify in format yyy.zzz")]
        [ValidateNotNullOrEmpty()]
        $DomainName
    )
    Write-Log -Verbose  "Step 2: Set up Active Directory"
    
    try {
        Import-Module ADDSDeployment
        $dotposition = $DomainName.LastIndexOf('.')
        $netbiosname = $DomainName.Substring(0,$dotposition)
        $result = Install-ADDSForest -DomainName $DomainName -InstallDNS:$true -Confirm:$false -NoRebootOnCompletion:$true -Force:$true -DatabasePath "C:\Windows\NTDS" -DomainMode Win2012R2 -ForestMode Win2012R2 -LogPath "C:\Windows\NTDS" -SysvolPath "C:\Windows\SYSVOL" -DomainNetbiosName $netbiosname
        Write-Log -Verbose  "Active Directory set up done"
        if ($global:DoAllTasks) {
            Set-Restart-AndResume $global:script "4"
        }
    }
    catch {
        Write-Log -Verbose  "Failed to set up Active Directory. Error: $_.Exception.Message"
    }
}
