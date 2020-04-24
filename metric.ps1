# run under UAC (admin!)
# Lists interfaces, selects OpenVPN and asks you to set metric
# Set the metric to 1 to increase priority
# Run script again to check settings were applied
# Script is not signed, so call 
# ``Set-ExecutionPolicy Bypass``
# before running. After it, call 
# ``Set-ExecutionPolicy Default``
# Tested on Windows10 WMF 5.1
$ipPattern = "172.20.*"



$openVpnInterface = $null
Get-NetIPInterface | foreach {
 $int = $_
 $adap = (Get-NetAdapter -InterfaceIndex $int.ifIndex -ErrorAction SilentlyContinue)
 $ips = (Get-NetIPAddress -InterfaceIndex $int.ifIndex-ErrorAction SilentlyContinue)
 $openVpn = ($ips | ? {$_.IPAddress -like $ipPattern}) -ne $null
 if ($openVpn) {
   $openVpnInterface = $int
 }
 [PSCustomObject] @{
   OpenVPN=$openVpn;
   InterfaceMetric=$int.InterfaceMetric;
   Name=$int.InterfaceAlias;
   Adapter=$adap.InterfaceDescription;
   IPs=$ips;    
 }
} | sort -Property InterfaceMetric | format-table
if ($openVpnInterface -eq $null) {
  Write-Error "Can't find openvpn interface"
  exit
}
Write-Host "Following interface is probably OpenVPN. Current metric is $($openVpnInterface.InterfaceMetric)"
Format-Table -InputObject $openVpnInterface
$newMetric = (Read-Host -Prompt "Enter new metric")
Write-Host "Setting to $($newMetric)"
Set-NetIPInterface -InputObject $openVpnInterface -InterfaceMetric $newMetric




