# Connect to Exchange Online
Connect-ExchangeOnline

# Get email address of mailbox to set permissions on
$targetMailbox = Read-Host "Please enter the email address of the mailbox you want to modify permissions on"

# Get email address of user to add to calendar permissions
$targetUser = Read-Host "Please enter the email address of the user you want to grant permissions to"

# Set permission variables for later use
$sendAsPermission = "SendAs"
$readAndManagePermission = "FullAccess"

# Create menu to specify permission level
function Show-Menu
{
     param (
           [string]$Title = "Mailbox Delegated Permission Selection"
     )
     cls
     Write-Host “================ $Title ================”
     Write-Host "Type the number corresponding to the desired permisison level and then press Enter."
	
     Write-Host '[1]: None'
     Write-Host '[2]: Send As'
     Write-Host '[3]: Read And Manage'
     Write-Host '[4]: Read and Manage with Send As'
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
				# Remove permissions
				Remove-MailboxPermission -Identity $targetMailbox -User $targetUser -AccessRights $readAndManagePermission -Confirm:$false
				Remove-RecipientPermission -Identity $targetMailbox -Trustee $targetUser -AccessRights $sendAsPermission -Confirm:$false
           } '2' {
				cls
				# Set permissions for Send As
				$permission = "SendAs"
				Add-RecipientPermission -Identity $targetMailbox -Trustee $targetUser -AccessRights $permission -Confirm:$false
           } '3' {
				cls
				# Set permissions for Full Access aka Read and Manage
				$permission = "FullAccess"
				Add-MailboxPermission -Identity $targetMailbox -User $targetUser -AccessRights $permission -Confirm:$false
          } '4' {
				cls
				# Set permissions for Read and Manage, and SendAs
				Add-MailboxPermission -Identity $targetMailbox -User $targetUser -AccessRights $readAndManagePermission -Confirm:$false
				Add-RecipientPermission -Identity $targetMailbox -Trustee $targetUser -AccessRights $sendAsPermission -Confirm:$false
		  }'q' {
				# Exit menu
				return
		  }
     }
}
until ($input -ne $null)

