#Install System Center Endpoint Protection
Function InstallSystemCenterEndpointProtection
{
    Write-Log -Verbose  "Step 4: Install System Center Endpoint Protection"
    Start-Process .\Resources\SystemCenterEndpointProtection\scepinstall.exe -Wait -ArgumentList "/s /q" #-NoNewWindow
    Write-Log -Verbose  "System Center Endpoint Protection Installed"
    if ($global:DoAllTasks) {
        Set-Restart-AndResume $global:script "6"
        }
}