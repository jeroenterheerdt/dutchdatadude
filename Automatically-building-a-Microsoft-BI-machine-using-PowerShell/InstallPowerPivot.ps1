#Install PowerPivot
#source: http://msdn.microsoft.com/en-us/library/ee210645.aspx
Function InstallPowerPivot
{
Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Password
)
    Write-Log -Verbose  "Step 7: Install PowerPivot"
    #MOUNT SQL ISO
    $mountresult = Mount-DiskImage -ImagePath $global:pathToSQLISO -PassThru
    $driveLetter = ($mountresult | Get-Volume).DriveLetter
    $setupFile = $driveLetter+":\setup.exe"
    #Remove Service Account if it already existed
    Get-ADServiceAccount -Filter {Name -eq 'PP'} | Remove-ADServiceAccount
    $ppAccountName = "PP"
    $ppAccountNameFQ = $global:domainpart+"\"+$ppAccountName
    CreateServiceAccount -AccountName $ppAccountName -DisplayName "PowerPivot" -Description "Service Account for PowerPivot for SharePoint" -Path $global:path -Password $Password
    #do PP installation
    #trying with plain text pwd in call
    $process = Start-Process -NoNewWindow -Wait $setupFile -ArgumentList "/ACTION=INSTALL /IACCEPTSQLSERVERLICENSETERMS /Q /INSTANCENAME=POWERPIVOT /ERRORREPORTING=1 /SQMREPORTING=1 /ASSVCACCOUNT=$ppAccountNameFQ /ASSVCPASSWORD=$Password /ASSYSADMINACCOUNTS=$global:currentUserName /ROLE=SPI_AS_ExistingFarm"
    #SPI_AS_ExistingFarm
    
    #dismount
    Dismount-DiskImage -ImagePath $global:pathToSQLISO
    Write-Log -Verbose  "If above an error is shown please check out C:\Program Files\Microsoft SQL Server\120\Setup Bootstrap\Log\Summary.txt"
    Write-Log -Verbose  "PowerPivot Installed"
    if ($global:DoAllTasks) {
        Set-Restart-AndResume $global:script "9"
        }
}