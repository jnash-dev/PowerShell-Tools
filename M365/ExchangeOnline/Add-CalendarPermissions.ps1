# Connect to Exchange Online
Connect-ExchangeOnline

# Get email address of calendar to set permissions on
$targetCalendar = Read-Host "Please enter the email address for the calendar to modify permissions on"

# Get email address of user to add to calendar permissions
$targetUser = Read-Host "Please enter the email address of the user you want to grant calendar permissions to"

# Create menu to specify permission level
function Show-Menu
{
     param (
           [string]$Title = "Calendar Permission Selection"
     )
     cls
     Write-Host “================ $Title ================”
     Write-Host "Type the number corresponding to the desired permisison level and then press Enter."
	
     Write-Host '[1]: None'
     Write-Host '[2]: CreateItems'
     Write-Host '[3]: CreateSubfolders'
	 Write-Host '[4]: DeleteAllItems'
	 Write-Host '[5]: DeleteOwnedItems'
	 Write-Host '[6]: EditAllItems'
	 Write-Host '[7]: EditOwnedItems'
	 Write-Host '[8]: FolderContact'
	 Write-Host '[9]: FolderOwner'
	 Write-Host '[10]: FolderVisible'
	 Write-Host '[11]: ReadItems'
     Write-Host '[Q]: Exit Menu'
}

do
{
     Show-Menu
     $input = Read-Host “Please make a selection”
     switch ($input)
     {
           '1' {
				cls
				# Set permission variable
				$permission = "None"
           } '2' {
				cls
				# Set permission variable
				$permission = "CreateItems"
           } '3' {
				cls
				# Set permission variable
				$permission = "CreateSubfolders"
          } '4' {
				cls
				# Set permission variable
				$permission = "DeleteAllItems"
		  } '5' {
				cls
				# Set permission variable
				$permission = "DeleteOwnedItems"
		  } '6' {
				cls
				# Set permission variable
				$permission = "EditAllItems"
		  } '7' {
				cls
				# Set permission variable
				$permission = "EditOwnedItems"
		  } '8' {
				cls
				# Set permission variable
				$permission = "FolderContact"
		  } '9' {
				cls
				# Set permission variable
				$permission = "FolderOwner"
		  } '10' {
				cls
				# Set permission variable
				$permission = "FolderVisible"
		  } '11' {
				cls
				# Set permission variable
				$permission = "ReadItems"
		  } 'q' {
				# Exit menu
				return
		  }
     }
}
until ($input -ne $null)

Write-Host "Selected permission level is $permission"

# Set the calendar permissions
Add-MailboxFolderPermission -Identity $targetCalendar`:\Calendar -User $targetUser -AccessRights $permission -SendNotificationToUser $false
