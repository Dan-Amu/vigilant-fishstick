$ActiveLeases = $(get-dhcpserverv4lease -ScopeId '172.16.17.0')

Add-Content -Path './ActiveDHCPLeases.csv' -Value "sep=,"
Add-Content -Path './ActiveDHCPLeases.csv' -Value "Scope:,IP Address:,Hostname:,DHCP UID:,Lease State:,"
foreach ($lease in $ActiveLeases) {
	
	#$OkayLease = @{

	$ScopeID = $lease.ScopeId.IPAddressToString
	$IPAddress = $lease.IPAddress.IPAddressToString
	$HostName = $lease.hostName
	$ClientID = $lease.ClientID
	$AddressState = $lease.AddressState
	#}
	Add-Content -Path './ActiveDHCPLeases.csv' -Value "$ScopeID,$IPAddress,$HostName,$ClientID,$AddressState,"
#	write-host $lease.ScopeId.IPAddressToString
	#$CleanedLeases += $OkayLease
}

write-host $CleanedLeasess

