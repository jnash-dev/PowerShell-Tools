# Connect to Exchange Online
Connect-ExchangeOnline

# Get email address of calendar to set permissions on
$targetCalendar = Read-Host "Please enter the email address for the calendar to modify permissions on"

# Get email address of user to add to calendar permissions
$targetUser = Read-Host "Please enter the email address of the user you want to grant calendar permissions to"


# Set the calendar permissions
Get-MailboxFolderPermission -Identity $targetCalendar`:\Calendar -User $targetUser
