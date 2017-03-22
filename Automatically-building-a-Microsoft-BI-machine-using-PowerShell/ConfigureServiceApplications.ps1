#ConfigureServiceApplications

Function ConfigureServiceApplications
{
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Password
    )
    Write-Log -Verbose  "Step 12: Configure Service Applications"    try {    Add-PSSnapin Microsoft.SharePoint.PowerShell    $appAccountName = "DefAppPool"
    $appAccountNameFQ = $global:domainpart+"\"+$appAccountName    $ApplicationPool = Get-SPServiceApplicationPool -Identity "Service Applications"
    if($ApplicationPool -eq $null) {
    $ApplicationPool = New-SPServiceApplicationPool -Name "Service Applications" -Account $appAccountNameFQ
    }

    #unattended account
    $unattendedAccountName = $global:spAccount
    $unattendedAccountNameFQ = $global:domainpart+"\"+$global:spAccount

    #performance point services
    
    New-SPPerformancePointServiceApplication -Name "PerformancePoint Services" -ApplicationPool $ApplicationPool -DatabaseServer "$global:HostName" -DatabaseName "PerformancePointServiceApplication"
    New-SPPerformancePointServiceApplicationProxy -Name "PerformancePoint Services Proxy" -ServiceApplication "PerformancePoint Services" -Default
    New-SPPerformancePointServiceApplicationTrustedLocation -ServiceApplication "PerformancePoint Services" -url "$global:httpHostName" -Type SiteCollection -TrustedLocationType Content
    Set-SPPerformancePointSecureDataValues -ServiceApplication "PerformancePoint Services" -DataSourceUnattendedServiceAccount (New-Object System.Management.Automation.PSCredential "$unattendedAccountNameFQ", (ConvertTo-SecureString $Password -AsPlainText -Force))
    Write-Log -Verbose  "Succesfully configured PerformancePoint Services"

    #visio services
    
    New-SPVisioServiceApplication -Name "Visio Services" -ApplicationPool $ApplicationPool -AddToDefaultGroup
    $usernameField = New-SPSecureStoreApplicationField –Name "UserName" -Type WindowsUserName –Masked:$false
    $passwordField = New-SPSecureStoreApplicationField –Name "Password" –Type WindowsPassword –Masked:$true
    $fields = $usernameField,$passwordField
    $userClaim = New-SPClaimsPrincipal -Identity $unattendedAccountNameFQ -IdentityType WindowsSamAccountName
    $groupClaim = New-SPClaimsPrincipal -Identity "nt authority\authenticated users" -IdentityType WindowsSamAccountName
    $secureUserName = $unattendedAccountNameFQ
    $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $credentialValues = $securePassword
    $targetapp = New-SPSecureStoreTargetApplication –Name "Visio Services" –FriendlyName "Visio Services" –ApplicationType Group
    $secureStoreApp = New-SPSecureStoreApplication –ServiceContext $global:httpHostName –TargetApplication $targetapp –Fields $fields –Administrator $userClaim -CredentialsOwnerGroup $groupClaim
    Update-SPSecureStoreGroupCredentialMapping -Identity $secureStoreApp -Values $credentialValues
    Set-SPVisioExternalData -VisioServiceApplication "Visio Services" -UnattendedServiceAccountApplicationID "Visio Services"
    Write-Log -Verbose  "Succesfully configured Visio Services"

    #reporting services
    Install-SPRSService
    Install-SPRSServiceProxy
    get-spserviceinstance -all |where {$_.TypeName -like "SQL Server Reporting*"} | Start-SPServiceInstance
    $serviceApp = New-SPRSServiceApplication "Reporting Services" -ApplicationPool $ApplicationPool
    $serviceAppProxy = New-SPRSServiceApplicationProxy "Reporting Services Proxy" -ServiceApplication $serviceApp
    Get-SPServiceApplicationProxyGroup –default | Add-SPServiceApplicationProxyGroupMember –Member $serviceAppProxy
    $webApp = Get-SPWebApplication $global:httpHostName
    $appPoolAccountName = $ApplicationPool.ProcessAccount.LookupName()
    $webApp.GrantAccessToProcessIdentity($appPoolAccountName)
    Write-Log -Verbose  "Succesfully configured Reporting Services"
    
    Write-Log -Verbose  "Service Applications Configured."
    if ($global:DoAllTasks) {
        Set-Restart-AndResume $global:script "14"
        }

    }
    catch {
        Write-Log -Verbose  "Failed to configure Service Applications. Error: $_.Exception.Message"
    }
}
