Function Write-Log {
    [cmdletbinding()]

    Param(
    [Parameter(Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$Message
    )
    
    #Pass on the message to Write-Verbose if -Verbose was detected
    Write-Verbose $Message
    
    Write-Output "$(Get-Date) $Message" | Out-File -FilePath $global:LogFile -Append
    

} #end function