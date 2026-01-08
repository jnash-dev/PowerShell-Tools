#Connect to Graph
Connect-MgGraph -Scopes 'User.ReadWrite.All', 'Group.ReadWrite.All', 'Directory.ReadWrite.All'

#Prompt for target user's UPN
$userUPN = Read-Host -Prompt "Please enter user's email address"

#Create object for user
$user = Get-MgUser -UserId $userUPN

#Get list of group IDs that target user is a member of
$groups = Get-MgUserMemberOf -UserId $user.Id | Select-Object *

#Get display names of groups that target user is in
$groupdata =
$groups | ForEach-Object {
    $GroupIDs = $_.id
    $otherproperties = $_.AdditionalProperties
    $finalreport = "" | Select-Object -Property "Group Name","Group ID"
    $finalreport.'Group Name' = $otherproperties.displayName
    $finalreport.'Group ID' = $GroupIDs
    $finalreport
}

#Export results to CSV named with user's UPN in the current directory
$groupdata | export-csv -notypeinformation -path ".\$userUPN`.csv"
