$mccDir = "C:\Program Files (x86)\Mitel\MiContact Center"
$testMccDir = Test-Path $mccDir
$mitelDir = "C:\Program Files (x86)\Mitel"
$testMitelDir = Test-Path "C:\Program Files (x86)\Mitel"
$pfDestDir = "$mccDir`\PFInstaller"
$testPfDestDir = Test-Path $pfDestDir
$preReqDestDir = "$mccDir`\PreReqs"
$testPreReqDestDir = Test-Path $preReqDestDir
$filenametimestamp = Get-Date -Format "yyyy-MM-dd@HH-mm-ss" #Used for log file name
function time { #used to format the time data for the timestamp
	$global:timestamp = Get-Date -Format "yyyy-MM-dd@HH-mm-ss"
	$global:logPrefix = "<LOG $timestamp`> "
	$logPrefix
}
function log ($logmsg){ #called to timestamp log entries
	$global:logTime = time
	$global:logEntry = $logTime + "$logMsg"
	$logEntry
}
$testLogDir = Test-Path "C:\Temp\Mitel\Logs"
$log = "C:\Temp\Mitel\Logs\MCC_Deployment_$filenametimestamp`.log"
$cccExe = "C:\Program Files (x86)\Mitel\MiContact Center\Applications\ContactCenterClient\ContactCenterClient.exe"
$sleepSecs1 = "20"
$sleepSecs2 = "180"

#CRITICAL ERROR. CANNOT OUTPUT TO LOG WHEN LOG DOESN'T EXIST!!
#Check for core directories and create them if needed
If ($testLogDir -eq $False) {
	$logMsg = "C:\Temp\Mitel not found. Creating C:\Temp\Mitel." #should test for Temp first otherwise script errors out
    log $logMsg ; $logEntry 
	New-Item -Path "C:\" -Name "Temp" -ItemType Directory
    $logMsg = "C:\Temp created."
    log $logMsg ; $logEntry 
	New-Item -Path "C:\Temp" -Name "Mitel" -ItemType Directory
    $logMsg = "C:\Temp\Mitel created."
    log $logMsg ; $logEntry 
	New-Item -Path "C:\Temp\Mitel" -Name "Logs" -ItemType Directory
    $logMsg = "C:\Temp\Mitel\Logs created."
}

If ($testMitelDir -eq $False) {
    $logMsg = "$mitelDir not found. Creating $mitelDir`."
    log $logMsg ; $logEntry >> $log
	New-Item -Path "C:\Program Files (x86)" -Name "Mitel" -ItemType Directory
    $logMsg = "$logPrefix$mitelDir created."
	log $logMsg ; $logEntry >> $log
}

If ($testMccDir -eq $False) {
    $logMsg = "$mccDir not found. Creating $mccDir`."
    log $logMsg ; $logEntry >> $log
	New-Item -Path "C:\Program Files (x86)\Mitel" -Name "MiContact Center" -ItemType Directory
    $logMsg = "$mccdir created."
	log $logMsg ; $logEntry >> $log
}


#Setting install dir and extracting zip file
$sourceDir = "C:\Temp\Mitel"
$logMsg = "Extracting MitelACD.zip to C:\Temp\Mitel."
log $logMsg ; $logEntry >> $log
Expand-Archive .\MitelACD.zip -Destination "$sourceDir" -Force
Set-Location $sourceDir

#Check for existing PFInstall folder on target
If ($testPfDestDir -eq $True) {
    $logMsg = "$pfDestDir detected. Removing $pfDestDir`."
	log $logMsg ; $logEntry >> $log
    Remove-Item -Recurse -Force -Path $pfDestDir >> $log
    $logMsg = "$pfDestDir removed. Recreating $pfDestDir`."
	log $logMsg ; $logEntry >> $log
    New-Item -Path $mccDir -Name "PFInstaller" -ItemType Directory 
    $logMsg = "$pfDestDir created. Copying PFInstaller files to $pfDestDir`."
    log $logMsg ; $logEntry >> $log
	Copy-Item -Path ".\PFInstaller" -Destination $mccDir -Recurse -Force
} Else {
    $logMsg = "$pfDestDir not found. Creating $pfDestDir`." 
    log $logMsg ; $logEntry >> $log
	New-Item -Path $mccDir -Name "PFInstaller" -ItemType Directory 
    $logMsg = "$pfDestDir created. Copying PFInstaller files to $pfDestDir`." 
    log $logMsg ; $logEntry >> $log
	Copy-Item -Path ".\PFInstaller" -Destination $mccDir -Recurse -Force  
}


#Check for existing PreReqs folder on target
If ($testPreReqDestDir -eq $True) {
    $logMsg = "$preReqDestDir detected. Removing $preReqDestDir`."
    log $logMsg ; $logEntry >> $log
	Remove-Item -Recurse -Force -Path $preReqDestDir >> $log 
    $logMsg = "$preReqDestDir removed. Recreating $preReqDestDir`."
    log $logMsg ; $logEntry >> $log
	New-Item -Path $mccDir -Name "PreReqs" -ItemType Directory 
    $logMsg = "$preReqDestDir created. Copying PreReq files to $preReqDestDir`."
    log $logMsg ; $logEntry >> $log
	Copy-Item -Path ".\PFInstaller\PreReqs" -Destination $mccDir -Recurse -Force 
} Else {
        $logMsg = "$preReqDestDir not detected. Creating $preReqDestDir`."
        log $logMsg ; $logEntry >> $log
		New-Item -path "$mccDir" -Name "PreReqs" -ItemType Directory     
        $logMsg = "$preReqDestDir created. Copying PreReq files to $preReqDestDir`."
        log $logMsg ; $logEntry >> $log
		Copy-Item -Path ".\PFInstaller\PreReqs" -Destination $mccDir -Recurse -Force 
}


#Check if dependencies are in place before running package
$deployTest = Test-Path "$pfDestDir`\Client Component Pack.deploy" -PathType Leaf
$7zTest = Test-Path "$pfDestDir`\8.1.11036.2 ccp.7z" -PathType Leaf
$manTest = Test-Path "$pfDestDir`\8.1.11036.2ccpmanifest.xml" -PathType Leaf

$logMsg = "Verifying dependencies are present."
log $logMsg ; $logEntry >> $log
If ($deployTest -eq $True){
    $logMsg = "Client Component Pack.deploy is present."
	log $logMsg ; $logEntry >> $log
    If ($7zTest -eq $True) {
        $logMsg = "8.1.11036.2 ccp.7z is present."
		log $logMsg ; $logEntry >> $log
        If ($manTest -eq $True) {
            $logMsg = "8.1.11036.2ccpmanifest is present."
			log $logMsg ; $logEntry >> $log
            #Make sure PowerShell finishes copying files before running package
            $logMsg = "Sleeping for $sleepSecs1 seconds."
			log $logMsg ; $logEntry >> $log
			Start-Sleep -Seconds $sleepSecs1
            $logMsg = "Executing package."
			log $logMsg ; $logEntry >> $log
            .\Setup.exe /s /workflow="Client Component Pack.deploy" /features="Ignite,ContactCenterClient,FlexibleReporting,ContactCenterSoftphone" /enterpriseip="172.17.128.13"
			$logMsg = "Sleeping for $sleepSecs2 seconds."
			log $logMsg ; $logEntry >> $log
			Start-Sleep -Seconds $sleepSecs2 #Keeps script from closing before background work is done. Otherwise Intune thinks the package failed to install.
			$logMsg = "Verifying applications installed correctly."
			log $logMsg ; $logEntry >> $log
			$testCccExe = Test-Path "C:\Program Files (x86)\Mitel\MiContact Center\Applications\ContactCenterClient\ContactCenterClient.exe" -PathType Leaf
			If($testCccExe -eq $True) {
				$logMsg = "MiContact Center was installed succesfully."
				log $logMsg ; $logEntry >> $log
				Exit 0
			} Else {
				$logMsg = "MiContact Center installation failed."
				log $logMsg ; $logEntry >> $log
				Exit 1
			}
		}
    }
}


