#DutchDataDude.com
#Code is provided as is.

Install-Module Az.Network -Scope CurrentUser

#CONFIG
$resourcegroup = "[ResourceGroupForAzureSQLDatabase]"
$server= "[AzureSQLServerName]"
$subscriptionId = "[SubscriptionID]"
$location = "[LocationForResourceGroupAndAzureSQLServer]"

#this is the URL for public clouds, for other clouds use appropriate URL
$url = "https://download.microsoft.com/download/7/1/D/71D86715-5596-4529-9B13-DA13A5DE5B63/ServiceTags_Public_20200420.json"

#source: https://gallery.technet.microsoft.com/scriptcenter/Start-and-End-IP-addresses-bcccc3a9
function Get-IPrangeStartEnd 
{ 
    <#  
      .SYNOPSIS   
        Get the IP addresses in a range  
      .EXAMPLE  
       Get-IPrangeStartEnd -start 192.168.8.2 -end 192.168.8.20  
      .EXAMPLE  
       Get-IPrangeStartEnd -ip 192.168.8.2 -mask 255.255.255.0  
      .EXAMPLE  
       Get-IPrangeStartEnd -ip 192.168.8.3 -cidr 24  
    #>  
      
    param (  
      [string]$start,  
      [string]$end,  
      [string]$ip,  
      [string]$mask,  
      [int]$cidr  
    )  
      
    function IP-toINT64 () {  
      param ($ip)  
      
      $octets = $ip.split(".")  
      return [int64]([int64]$octets[0]*16777216 +[int64]$octets[1]*65536 +[int64]$octets[2]*256 +[int64]$octets[3])  
    }  
      
    function INT64-toIP() {  
      param ([int64]$int)  
 
      return (([math]::truncate($int/16777216)).tostring()+"."+([math]::truncate(($int%16777216)/65536)).tostring()+"."+([math]::truncate(($int%65536)/256)).tostring()+"."+([math]::truncate($int%256)).tostring() ) 
    }  
      
    if ($ip) {$ipaddr = [Net.IPAddress]::Parse($ip)}  
    if ($cidr) {$maskaddr = [Net.IPAddress]::Parse((INT64-toIP -int ([convert]::ToInt64(("1"*$cidr+"0"*(32-$cidr)),2)))) }  
    if ($mask) {$maskaddr = [Net.IPAddress]::Parse($mask)}  
    if ($ip) {$networkaddr = new-object net.ipaddress ($maskaddr.address -band $ipaddr.address)}  
    if ($ip) {$broadcastaddr = new-object net.ipaddress (([system.net.ipaddress]::parse("255.255.255.255").address -bxor $maskaddr.address -bor $networkaddr.address))}  
      
    if ($ip) {  
      $startaddr = IP-toINT64 -ip $networkaddr.ipaddresstostring  
      $endaddr = IP-toINT64 -ip $broadcastaddr.ipaddresstostring  
    } else {  
      $startaddr = IP-toINT64 -ip $start  
      $endaddr = IP-toINT64 -ip $end  
    }  
      
     $temp=""|Select start,end 
     $temp.start=INT64-toIP -int $startaddr 
     $temp.end=INT64-toIP -int $endaddr 
     return $temp 
}


# Sign-in with Azure account credentials
Connect-AzAccount
$context = Set-AzContext -SubscriptionId $subscriptionId
$output = "$PSScriptRoot\servicetags.json"

#download the service tags and convert to Json
Invoke-WebRequest -Uri $url -OutFile $output

$j = Get-Content $output | ConvertFrom-Json

#remove all firewall rules for PowerQueryOnline
$existingrules = Get-AzSqlServerFirewallRule -ResourceGroupName $resourcegroup -ServerName $server
foreach ($rule in $existingrules) {
    if ($rule.FirewallRuleName -match "PowerQuery") {
        write-host "Removing rule " $rule.FirewallRuleName
        Remove-AzSqlServerFirewallRule -ResourceGroupName $resourcegroup -ServerName $server -FirewallRuleName $rule.FirewallRuleName -DefaultProfile $context
    }
}

$v = $j.values
foreach ($val in $v) {
    if ($val.name -match "PowerQuery") {
        $addresses = $val.properties.addressPrefixes;
        foreach($address in $addresses) {
            $split = $address.Split('/')
            $startend = Get-IPRangeStartEnd -ip $split[0] -cidr $split[1]
            $end = $startend.end
            $start = $startend.start
            $rulename = $val.name+":"+$start+"-"+$end

            #add rules
            write-Host "Adding " $rulename
            New-AzSqlServerFirewallRule -ResourceGroupName $resourcegroup -ServerName $server -FirewallRuleName $rulename -StartIpAddress $start -EndIpAddress $end -DefaultProfile $context
        }
    }
}

