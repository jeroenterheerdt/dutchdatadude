#ConfigurePowerPivot

#source: http://msdn.microsoft.com/en-us/library/hh230903.aspx
Function ConfigurePowerPivot
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Passphrase required")]
        [ValidateNotNullOrEmpty()]
        $passphrase,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Password
    )
    Write-Host "Step 8: Configure PowerPivot"    try {    #Load Configure PowerPivot ps1    $scriptPath = Split-Path -parent $global:script
    . ('C:\Program Files\Microsoft SQL Server\120\Tools\PowerPivotTools\SPAddinConfiguration\Resources\ConfigurePowerPivot.ps1')
    
    #Create a user for SharePoint DB connection
    #if required, remove the ad user
    Get-ADUser -Filter {Identity -eq '$global:spAccount'} | Remove-ADUser
    CreateServiceAccount -AccountName $global:spAccount -DisplayName "SharePoint Farm account" -Description "Account for SharePoint Farm" -Path $global:path -Password $Password
    $spAccountFQ = $global:domainpart+"\"+$global:spAccount
    $pwd = convertto-securestring $Password -asplaintext -force
    & "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\BIN\psconfig.exe" -cmd configdb -create -server $global:HostName -database 'SharePoint_Config' -user $spAccountFQ -password $Password -passphrase $passphrase -admincontentdatabase 'SharePoint_Admin' -cmd helpcollections -installall -cmd secureresources -cmd services -install -cmd installfeatures -cmd adminvs -provision -port 2000 -windowsauthprovider onlyusentlm -cmd applicationcontent -install -cmd quiet 
    Add-PSSnapin Microsoft.SharePoint.PowerShell
    Add-SPSolution -LiteralPath 'C:\Program Files\Microsoft SQL Server\120\Tools\PowerPivotTools\SPAddinConfiguration\Resources\powerpivotfarmsolution.wsp'
    Add-SPSolution -LiteralPath 'C:\Program Files\Microsoft SQL Server\120\Tools\PowerPivotTools\SPAddinConfiguration\Resources\PowerPivotFarm14Solution.wsp'
    Add-SPSolution -LiteralPath 'C:\Program Files\Microsoft SQL Server\120\Tools\PowerPivotTools\SPAddinConfiguration\Resources\powerpivotwebapplicationsolution.wsp'
    DeployFarmSolution $false
    DeployWebAppSolutionToCentralAdmin $false
    Install-SPFeature -path PowerPivotFarm -Force
    Install-SPFeature -path PowerPivotFarm -Force -CompatibilityLevel 14
    Install-SPFeature -path PowerPivotCA -Force
    InstallSiteCollectionFeatures
    
    Write-Host "PowerPivot Part 1 Configured. Computer needs to be restarted before PowerPivot configuration can continue." -ForegroundColor Green
    if ($global:DoAllTasks) {
        Set-Restart-AndResume $global:script "9"
        }

    }
    catch {
        Write-Host "Failed to configure PowerPivot. Error: $_.Exception.Message" -ForegroundColor Red
    }
}

Function ConfigurePowerPivotPart2 {
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Passphrase required")]
        [ValidateNotNullOrEmpty()]
        $passphrase,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Password
    )

    try {
     #Load Configure PowerPivot ps1    $scriptPath = Split-Path -parent $global:script
    . ('C:\Program Files\Microsoft SQL Server\120\Tools\PowerPivotTools\SPAddinConfiguration\Resources\ConfigurePowerPivot.ps1')
    Add-PSSnapin Microsoft.SharePoint.PowerShell
    Write-Host "DEBUG: updating Farm Credentials"
    $spAccountFQ = $global:domainpart+"\"+$global:spAccount
    stsadm.exe -o updatefarmcredentials -userlogin $spAccountFQ -password $Password
    Write-Host "DEBUG: New-PowerpivotSystemServiceInstance"
    New-PowerPivotSystemServiceInstance -Provision:$true
    Write-Host "DEBUG: New-PowerPivotServiceApplication"
    New-PowerPivotServiceApplication -ServiceApplicationName 'PowerPivot Service Application' -DatabaseServerName $global:HostName -DatabaseName 'PowerPivotServiceApplication' -AddToDefaultProxyGroup:$true
    Write-Host "DEBUG: Set-PowerPivotSystemService"
    Set-PowerPivotSystemService -Confirm:$false
    
    Write-Host "DEBUG: Creating user DefAppPool"
    $appAccountName = "DefAppPool"
    $appAccountNameFQ = $global:domainpart+"\"+$appAccountName
    CreateServiceAccount -AccountName $appAccountName -DisplayName "Default Application Pool" -Description "Service Account for Default Application Pool" -Path $global:path -Password $Password
    Write-Host "DEBUG: CreateWebApplication"
    CreateWebApplication 'SharePoint - 80' $global:HostName 'Default Application Pool' $appAccountNameFQ $pwd $global:HostName 'DefaultWebApplication'
    Write-Host "DEBUG: DeployWebAppSolution"
    DeployWebAppSolution $global:httpHostName 2047 $false
    Write-Host "DEBUG: New-SPSite"
    New-SPSite -Url $global:httpHostName -OwnerEmail 'me@example.com' -OwnerAlias $global:currentUserName -Template 'PowerPivot#0' -Name  'PowerPivot Site'
    Write-Host "DEBUG: EnableSiteFeatures"
    EnableSiteFeatures $global:httpHostName $true
    Write-Host "DEBUG: StartService SPWindowsTokenServiceInstance"
    StartService "Microsoft.SharePoint.Administration.Claims.SPWindowsTokenServiceInstance"
    Write-Host "DEBUG: StartSecureStoreService"
    StartSecureStoreService
    Write-Host "DEBUG: CreateSecureStoreApplicationService"
    CreateSecureStoreApplicationService $global:HostName 'Secure Store Service'
    Write-Host "DEBUG: CreateSecureStoreApplicationServiceProxy"
    CreateSecureStoreApplicationServiceProxy 'Secure Store Service' 'Secure Store Proxy'
    Write-Host "DEBUG: UpdateSecureStoreMasterKey"
    UpdateSecureStoreMasterKey 'Secure Store Proxy' $passphrase 
    Write-Host "DEBUG: CreateUnattendedAccountForDataRefresh"
    CreateUnattendedAccountForDataRefresh $global:httpHostName 'PowerPivotUnattendedAccount' 'PowerPivot Unattended Account for Data Refresh' $spAccountFQ $pwd
    Write-Host "DEBUG: StartService ExcelServerWebServiceInstance"
    StartService "Microsoft.Office.Excel.Server.MossHost.ExcelServerWebServiceInstance"
    Write-Host "DEBUG: New-SPExcelServiceApplication"
    New-SPExcelServiceApplication -name 'ExcelServiceApp1' -Default -ApplicationPool 'SharePoint Web Services System' | Get-SPExcelServiceApplication | Set-SPExcelServiceApplication | iisreset Set-SPExcelFileLocation -ExternalDataAllowed 2 -WorkbookSizeMax 200 -WarnOnDataRefresh:$false -ExcelServiceApplication 'ExcelServiceApp1' -identity 'http://'
    Write-Host "DEBUG: AddExcelBIServer"
    AddExcelBIServer
    Write-Host "DEBUG: SetECSUsageTracker"
    SetECSUsageTracker 'ExcelServiceApp1'
            Write-Host "PowerPivot Configured" -ForegroundColor Green
    if ($global:DoAllTasks) {
        Set-Restart-AndResume $global:script "10"
        }

    }
    catch {
        Write-Host "Failed to configure PowerPivot. Error: $_.Exception.Message" -ForegroundColor Red
    }

}