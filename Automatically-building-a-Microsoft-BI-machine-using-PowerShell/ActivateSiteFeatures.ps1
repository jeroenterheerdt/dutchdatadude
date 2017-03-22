#ActivateSiteFeatures

Function ActivateSiteFeatures
{
    
    Write-Log -Verbose "Step 13: Activated Site Features"    try {    Add-PSSnapin Microsoft.SharePoint.PowerShell    Enable-SPFeature -Identity PPSSiteCollectionMaster -Url $global:httpHostName     Enable-SPFeature -Identity PPSSiteMaster -Url $global:httpHostName
    Enable-SPFeature -Identity PremiumWeb -Url $global:httpHostName    Write-Log -Verbose  "Site Features Activated."
    if ($global:DoAllTasks) {
        Set-Restart-AndResume $global:script "15"
        }

    }
    catch {
        Write-Log -Verbose  "Failed to Activated Site Features. Error: $_.Exception.Message"
    }
}
