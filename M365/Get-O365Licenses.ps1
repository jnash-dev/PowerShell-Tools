Connect-MgGraph -Scopes 'User.ReadWrite.All', 'Group.ReadWrite.All', 'Directory.ReadWrite.All'

$users = Get-MgUser -All

ForEach ($user in $users) {
$licenseDetails = Get-MgUserLicenseDetail -UserId $user.Id | Where-Object {$_.SkuPartNumber -like "O365*"}

$output = [PSCustomObject]@{
    DisplayName = $user.DisplayName
    License = $licenseDetails.SkuPartNumber
}

$output  | Export-CSV -Path "Licensed Users.csv" -NoTypeInformation -Append

}