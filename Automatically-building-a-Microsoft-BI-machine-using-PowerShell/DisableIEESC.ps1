#Disables Internet Explorer Enhanced Security Configuration
#source: http://itproctology.blogspot.nl/2013/09/powershell-to-disable-ie-enhanced.html
Function DisableIEESC {
    Write-Log -Verbose "Step 1: Disable Internet Explorer Enhanced Security"
    try {
        $AdminKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}”
        $UserKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}”
        Set-ItemProperty -Path $AdminKey -Name “IsInstalled” -Value 0
        Set-ItemProperty -Path $UserKey -Name “IsInstalled” -Value 0
        Stop-Process -Name Explorer
        Write-Log -Verbose  "IE ESC succesfully disabled"
        if ($global:DoAllTasks) {
            Set-Restart-AndResume $global:script "2"
        }
    }
    catch {
        Write-Log -Verbose  "Failed to disable IE ESC. Error: $_.Exception.Message"
    }
}