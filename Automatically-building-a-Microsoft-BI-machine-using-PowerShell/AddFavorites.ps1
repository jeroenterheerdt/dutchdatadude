#AddFavorites

#source: http://learn-powershell.net/2014/01/06/a-powershell-module-for-managing-internet-explorer-favorites/
Function AddFavorites
{
    
    Write-Log -Verbose  "Step 14: Add Favorites"    try {    Import-Module .\IEFavorites.psm1 -Verbose    $mdsFavoURL = $global:httpHostName    $mdsFavoURL += ":81"    Add-IEFavorite -Name "Master Data Services" -Url $mdsFavoURL -Verbose    $spca = $global:httpHostName    $spca += ":2000"    Add-IEFavorite -Name "SharePoint Central Administration" -URL $spca -Verbose     Add-IEFavorite -Name "Demo Site" -URL $global:httpHostName -Verbose    $rs = $global:httpHostName    $rs+= "/Reports"    Add-IEFavorite -Name "Report Manager" -URL $rs    Write-Log -Verbose  "Favorites Added."
    if ($global:DoAllTasks) {
        Set-Restart-AndResume $global:script "16"
        }

    }
    catch {
        Write-Log -Verbose  "Failed to Add Favorites. Error: $_.Exception.Message"
    }
}
