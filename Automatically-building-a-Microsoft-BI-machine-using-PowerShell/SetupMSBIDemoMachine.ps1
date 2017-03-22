<#
.SYNOPSIS
Installs and sets up a MSBI Demo Machine in a number of steps
.DESCRIPTION

.PARAMETER DoAllTasks
Execute all tasks required to set up the machine. Alternatively you can specify the task to be executed using the other flags
.PARAMETER DisableIEESC
Disables Internet Explorer Security Configuration
.PARAMETER SetupActiveDirectory
Sets up Active Directory. -DomainName parameter is required
.PARAMETER ConfigurePasswordPolicy
Configures the password policy so passwords never expire. Should only be called after Active Directory is set up. 
.PARAMETER InstallSystemCenterEndpointProtection
Installs System Center Endpoint Protection
.PARAMETER InstallSQLServer
Installs SQL Server. Should only be called after Active Directory is set up. Requires -DomainName to be specified
.PARAMETER InstallSharePoint
Installs SharePoint. Should only be called after Active Directory is set up.
.PARAMETER InstallPowerPivot
Installs PowerPivot. Should only be called after Active Directory is set up. Requires -DomainName to be specified
.PARAMETER ConfigurePowerPivot
Configures PowerPivot and SharePoint farm. Should only be called after SQL Server, SharePoint and PowerPivot have been installed. Requires -passphrase as well as -DomainName to be specified.
.PARAMETER ConfigurePowerPivotPart2
Configures PowerPivot and SharePoint farm, second part. Should only be called after -ConfigurePowerPivot has been called. Requires -passphrase as well as -DomainName to be specified.
.PARAMETER AutoReboot
Optional. Enables automatic reboot and resume between steps. Handy for unattended installs. No automatic reboot will occur if parameter is not included
.PARAMETER DomainName
DomainName in format zzz.yyy (for example mydomain.local)
.PARAMETER passphrase
Passphrase to be used for SharePoint install. Parameter required for SharePoint setup.
.PARAMETER Password
Optional parameter if you want to specify the password used for service accounts. Otherwise defaults to pass@word1

.EXAMPLE
.\SetupMSBIDemoMachine -DoAllTasks -DomainName mydomain.local -passphrase pass@word1
Installs all components required using default passwords but does not do automatic reboots
.EXAMPLE
.\SetupMSBIDemoMachine -InstallSQLServer -Password myPWD1
Installs just SQL Server and uses myPWD1 as password for service accounts
.EXAMPLE
.\SetupMSBIDemoMachine -DoAllTasks -DomainName mydomain.local -passphrase pass@word1 -AutoReboot
Installs all components required using default passwords and does automatic reboots
#>

[CmdletBinding()]
Param(
[switch]$DisableIEESC,
[switch]$SetupActiveDirectory,
[string]$DomainName,
[switch]$ConfigurePasswordPolicy,
[switch]$InstallSystemCenterEndpointProtection,
[switch]$InstallSQLServer,
[switch]$InstallSharePoint,
[switch]$InstallPowerPivot,
[switch]$ConfigurePowerPivot,
[switch]$ConfigurePowerPivotPart2,
[string]$passphrase,
[switch]$DoAllTasks,
[string]$Password="pass@word1",
[string]$Step="1",
[switch]$AutoReboot=$false
)

# -------------------------------------
# Imports
# -------------------------------------
$global:script = $myInvocation.MyCommand.Definition
$scriptPath = Split-Path -parent $global:script
. (Join-Path $scriptpath RestartAndResumeFunctions.ps1)
. (Join-Path $scriptpath DisableIEESC.ps1)
. (Join-Path $scriptPath Set-Restart-AndResume.ps1)
. (Join-Path $scriptPath SetupActiveDirectory.ps1)
. (Join-Path $scriptPath ConfigurePasswordPolicy.ps1)
. (Join-Path $scriptPath InstallSystemCenterEndpointProtection.ps1)
. (Join-Path $scriptPath CreateServiceAccount.ps1)
. (Join-Path $scriptPath InstallSQLServer.ps1)
. (Join-Path $scriptPath InstallSharePoint.ps1)
. (Join-Path $scriptPath InstallPowerPivot.ps1)
. (Join-Path $scriptPath ConfigurePowerPivot.ps1)

$global:DoAllTasks = $DoAllTasks
$global:AutoReboot = $AutoReboot
Set-Location $scriptPath

#get the passed parameters
$Myparameters = $myinvocation.BoundParameters
#remove step from the list
$Myparameters.Remove("Step")
#build parameter string
$global:line = ""
foreach ($key in $Myparameters.keys)
{
    $value = (get-variable $key).Value 
    #is this a switch
    if($value -eq $true) {
        $global:line+= " -"+$key
    }
    else
    {
        $global:line+=" -"+$key+" "+$value
    }
}
#DEBUG
Write-Host "=========="
Write-Host "Debug"
Write-Host "Script: "$global:script
Write-Host "Line: "$global:line
Write-Host "Auto Reboot: "$global:AutoReboot
Write-Host "=========="
Write-Host ""
Write-Host ""


#reset any restart and might be lingering
Clear-Any-Restart

#Set the hostname
$global:HostName = hostname
$global:HostNameFull = $HostName
$global:HostNameFull += ".cloudapp.net"
$global:httpHostName = "http://"
$global:httpHostName += $HostName
#Set current user name
$global:currentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name;
#Path to SQL ISO
$global:pathToSQLISO = ".\Resources\SQLServer2014DeveloperEdition\en_sql_server_2014_developer_edition_x64_dvd_3940406.iso"
$global:pathToSQLISO = Resolve-Path $global:pathToSQLISO
#Path to SHarePoint ISO
$global:pathToSharePointISO = ".\Resources\SharePoint2013\en_sharepoint_server_2013_with_sp1_x64_dvd_3823428.iso"
$global:pathToSharePointISO = Resolve-Path $global:pathToSharePointISO
#Path to SharePoint Prerequisites
$global:SharePoint2013Path = ".\Resources\SharePoint2013"
$global:SharePoint2013Path = Resolve-Path $global:SharePoint2013Path
#Domain Vars
#$global:path = "CN=Managed Service Accounts,"
$global:path = "CN=Users,"
$global:root = [ADSI]''
$global:dn = $global:root.distinguishedName
$global:path += $global:dn
$global:domainpart = (gwmi Win32_NTDomain).DomainName
#SPFarm Account Name
$global:spAccount = "SPFarm"
#ACTUAL PROGRAM

#STEP 1 - Disable IE ESC
if ($DisableIEESC -or ($DoAllTasks -and (Should-Run-Step "1"))) {
    DisableIEESC
}
#Step 2 - Setup AD
if ($SetupActiveDirectory -or ($DoAllTasks -and (Should-Run-Step "2"))) {
    SetupActiveDirectory -DomainName $DomainName
}
#Step 3 - Configure Password Policy
if ($ConfigurePasswordPolicy -or ($DoAllTasks -and (Should-Run-Step "3"))) {
    ConfigurePasswordPolicy -DomainName $DomainName
}
#Step 4 - Install System Center Endpoint Protection
if($InstallSystemCenterEndpointProtection -or ($DoAllTasks -and (Should-Run-Step "4"))) {
    InstallSystemCenterEndpointProtection
}
#Step 5 - Install SQL Server
if($InstallSQLServer -or ($DoAllTasks -and (Should-Run-Step "5"))) {
    InstallSQLServer -Password $Password
}
#Step 6- Install SharePoint
if($InstallSharePoint -or ($DoAllTasks -and (Should-Run-Step "6"))) {
    InstallSharePoint
}
#Step 7- Install PowerPivot
if($InstallPowerPivot -or ($DoAllTasks -and (Should-Run-Step "7"))) {
    InstallPowerPivot -Password $Password
}
#Step 8 - Configure PowerPivot
if($ConfigurePowerPivot -or ($DoAllTasks -and (Should-Run-Step "8"))) {
    ConfigurePowerPivot -passphrase $passphrase -Password $Password
}
#Step 9 - Configure PowerPivot Part 2
if($ConfigurePowerPivotPart2 -or ($DoAllTasks -and (Should-Run-Step "9"))) {
    ConfigurePowerPivotPart2 -passphrase $passphrase -Password $Password
}