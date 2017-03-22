Function Set-Restart-AndResume ([string] $key, [string] $run) 
{
    Write-Log -Verbose "Set-Restart-AndResume"
    $run += $global:line
    Write-Log -Verbose "$run"
    Restart-And-Resume $key $run
}