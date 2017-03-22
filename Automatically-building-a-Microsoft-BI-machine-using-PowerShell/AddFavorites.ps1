﻿#AddFavorites

#source: http://learn-powershell.net/2014/01/06/a-powershell-module-for-managing-internet-explorer-favorites/
Function AddFavorites
{
    
    Write-Log -Verbose  "Step 14: Add Favorites"
    if ($global:DoAllTasks) {
        Set-Restart-AndResume $global:script "16"
        }

    }
    catch {
        Write-Log -Verbose  "Failed to Add Favorites. Error: $_.Exception.Message"
    }
}