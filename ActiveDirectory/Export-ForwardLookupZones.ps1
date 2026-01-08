#Used to backup all Forward Lookup Zones on a self-hosted DNS server. Results are exported to a ZIP file on the user's desktop.
$commonDomain = "test.com"
$dnsPath = "C:\Windows\System32\dns"
$backupPath = "$dnsPath`\backup"
$testForBackupFolder = Test-Path "$backupPath"
$testForBackups = Test-Path "$backupPath`\$commonDomain" -PathType Leaf

If ($testForBackupFolder -eq $False) {
		New-Item -Path "$backupPath" -ItemType Directory -Force
}


If ($testForBackups -eq $True) {
	Remove-Item "$backupPath`\*" -Force
	$testForBackups = Test-Path "$backupPath`\$commonDomain" -PathType Leaf
	If ($testForBackups -eq $True) {
		Throw "Could not clear backup folder. Please check your permissions and try again."
	}
} Else {
	(Get-DnsServerZone | Where-Object {$_.IsReverseLookupZone -eq $False}).ZoneName | Out-File -FilePath "$backupPath`\DnsZones.txt"
	$content = Get-Content $backupPath`\DnsZones.txt
	ForEach ($zone in $content) {
		Export-DnsServerZone -Name $zone -filename backup`\$zone
	}
	Compress-Archive -Path "$backupPath`\*" -DestinationPath "C:\Users\$env:UserName`\Desktop\DnsZoneBackup.zip"
}
