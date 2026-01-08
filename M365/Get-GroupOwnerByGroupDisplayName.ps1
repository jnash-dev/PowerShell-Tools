# Get list of group owners for a given group's DisplayName

# Create array to handle multiple owners
$ownerDisplayNames = @()

# Set DisplayName
[string]$displayName = Read-Host "Enter group's DisplayName"
Write-Host "Entered DisplayName is $($displayName)"

# Get the group's ID
$groups = Get-MgGroup -Filter "DisplayName eq '$($displayName)'"

# Check to see if multiple groups were saved to $groups
If ($groups.Count -gt 1) {
	ForEach ($group in $groups) {
		# Set $groupId to be the GroupID of the filtered group
		$groupId = (Get-MgGroup -GroupId $group.Id | Where-Object {$group.MailEnabled -eq "True" -and $group.OnPremisesSyncEnabled -notlike "True"}).Id
	}
	# Check if $groupId is not equal to null
		If (!($groupId -eq $null)) {
		Write-Host "GroupId is $($groupId)"
		# Get the group's owners
		$groupOwners = Get-MgGroupOwner -GroupId $groupId -All
		ForEach ($owner in $groupOwners) {
			$ownerDisplayNames += Get-MgUser -UserId $owner.Id | Select-Object -ExpandProperty DisplayName
		}
		Write-Output $ownerDisplayNames
		} Else {
			Write-Output "Group is not unified (Teams) group and has no owners."
		}
} Else {
	# Get the group's ID
	[string]$groupId = (Get-MgGroup -Filter "DisplayName eq '$($displayName)'" | Where-Object {$_.MailEnabled -eq "True" -and $_.OnPremisesSyncEnabled -notlike "True"}).Id
	
	# Check if GroupID is null
	If ($groupId.length -lt 1) {
		Write-Output "Group is not unified (Teams) group and has no owners."
		} Else {
			Write-Host "GroupId is $($groupId)"
			# Get the group's owners
			$groupOwners = Get-MgGroupOwner -GroupId $groupId -All
			ForEach ($owner in $groupOwners) {
				$ownerDisplayNames += Get-MgUser -UserId $owner.Id | Select-Object -ExpandProperty DisplayName
			}
			Write-Output $ownerDisplayNames
		}
}
