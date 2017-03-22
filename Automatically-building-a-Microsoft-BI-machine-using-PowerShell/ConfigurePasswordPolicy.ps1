#Configure Password Policy
Function ConfigurePasswordPolicy {
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Domain name required, please specify in format yyy.zzz")]
        [ValidateNotNullOrEmpty()]
        $DomainName
    )
    Write-Log -Verbose  "Step 3: Configure Password Policy"
   try {
    Set-ADDefaultDomainPasswordPolicy -Identity $DomainName -MinPasswordLength:0 -PasswordHistoryCount:0 -MaxPasswordAge:0 -MinPasswordAge:0 -ComplexityEnabled:$false
    Write-Log -Verbose  "Password Policy Configured"
    if ($global:DoAllTasks) {
        Set-Restart-AndResume $global:script "5"
    }
    }
    catch {
    Write-Log -Verbose  "Failed to configure Password Policy. Error: $_.Exception.Message"
    }
}