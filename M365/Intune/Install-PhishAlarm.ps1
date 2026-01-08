$global:installDir = "C:\Program Files (x86)\Wombat Security\PhishAlarm Outlook Add-In"
$global:dllName = "PhishAlarm Outlook Add-In.dll"
$global:filenameTimestamp = Get-Date -Format "yyyy-MM-dd@HH-mm-ss"
$global:msiName = "PhishAlarm Outlook Add-In.msi"
$global:sleepTime = 20

function Set-TempDir {
$global:tempDir = "C:\temp"
$testTempDir = Test-Path $tempDir
If ($testTempDir -eq $False) {
    New-Item -Path "C:\" -Name "Temp" -ItemType Directory
}
$global:phishAlarmDir = "$tempDir`\PhishAlarm"
$testPhishAlarmDir = Test-Path "$phishAlarmDir"
If ($testPhishAlarmDir -eq $False) {
    New-Item -Path "$tempDir" -Name "PhishAlarm" -ItemType Directory
}
}


Function Set-LogDir {
    $testLogDir = Test-Path "$phishAlarmDir`\Logs"
    If ($testLogDir -eq $False) {
        New-Item -Path $phishAlarmDir -Name "Logs" -ItemType Directory
        $global:logDir = "$phishAlarmDir`\Logs"
    } Else {
        $global:logDir = "$phishAlarmDir`\Logs"
    }
}


$log = "$logDir`\PA_Deployment_$filenametimestamp`.log"
function time { #used to format the time data for the timestamp
	$global:timestamp = Get-Date -Format "yyyy-MM-dd@HH-mm-ss"
	$global:logPrefix = "<LOG $timestamp`> "
	$logPrefix
}
function log ($logmsg){ #called to timestamp log entries
	$global:logTime = time
	$global:logEntry = $logTime + "$logMsg"
	$logEntry >> $log
}


#Beginning of main commands
Set-TempDir
Set-LogDir
log "Copying MSI to $phishAlarmDir" ; Copy-Item ".\$msiName" -Destination "$phishAlarmDir" -Force

#Install if MSI present
$testMsi = Test-Path "$phishAlarmDir`\PhishAlarm Outlook Add-In.msi" -PathType Leaf
If ($testMSi -eq $True) {
    Set-Location $phishAlarmDir
    log "Running msiexec with parameters /qn ALLUSERS=1 /l*vx C:\temp\PhishAlarm\Logs\Deployment_$filenameTimestamp.log /i `"PhishAlarm Outlook Add-In.msi`" COMPANYID=2ae910be-8cb8-4684-1000-a72b-79ec8811376b REGION=us analyzerUrl=https://analyzer-api.securityeducation.com"
	msiexec /qn ALLUSERS=1 /l*vx C:\temp\PhishAlarm\Logs\Deployment_$filenameTimestamp.log /i "PhishAlarm Outlook Add-In.msi" COMPANYID=2ae910be-8cb8-4684-1000-a72b-79ec8811376b REGION=us analyzerUrl=https://analyzer-api.securityeducation.com
    log "Sleeping for $sleepTime seconds." ; Start-Sleep -Seconds $sleepTime
}


#Test and cleanup
$testInstall = Test-Path "$installDir`\$dllName" -PathType Leaf
If ($testInstall -eq $True) {
    log "Removing MSI file from $phishAlarmDir"
    Remove-Item ".\PhishAlarm Outlook Add-In.msi" -Force
}
