#Creates a service account
Function CreateServiceAccount
{
    Param(
        [Parameter(Mandatory=$true)]
        $AccountName,
        [Parameter(Mandatory=$true)]
        $Path,
        [Parameter(Mandatory=$true)]
        $DisplayName,
        [Parameter(Mandatory=$true)]
        $Description,
        $Password
    )
    #No more MSAs just normal accounts
    #New-ADServiceAccount -Name $AccountName -DisplayName $DisplayName -Description $Description -RestrictToSingleComputer -Enabled $true -Path $Path
    #add-ADComputerServiceAccount -Identity $global:HostName -ServiceAccount $AccountName
    #Install-ADServiceAccount -Identity $AccountName
    Write-Host "DEBUG: CreateServiceAccount called with"
    Write-Host "AccountName: "$AccountName
    Write-Host "Path: "$Path
    Write-Host "DisplayName: "$DisplayName
    Write-Host "Description: "$Description
    Write-Host "Password: "$Password
    $pwd = convertto-securestring $Password -asplaintext -force
    New-ADUser -Name $AccountName -DisplayName $DisplayName -Description $Description -AccountPassword $pwd -Enabled $true
    $user = get-ADUser "CN=$AccountName,$path"
    $group = get-adGroup "CN=Domain Admins,$path"
    Add-ADGroupMember -Identity $group -Member $user
}