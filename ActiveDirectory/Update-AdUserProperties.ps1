## Used for synchronizing current AD users with ADP generated CSV

# Define the input CSV file path
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

# Show Open File dialog window
$folderSelection = New-Object System.Windows.Forms.OpenFileDialog -Property @{  
InitialDirectory = [Environment]::GetFolderPath('Windows')  
CheckFileExists = 0  
ValidateNames = 0  
FileName = "Choose CSV File"  
}  

$folderSelection.ShowDialog()  

$csvFilePath = $folderSelection.FileName 

# Import the CSV file
$data = Import-Csv -Path $csvFilePath

# Initialize an array to hold the combined display names and job titles
$results = @()

# Combine firstname and lastname into DisplayName and extract job titles
$data | ForEach-Object {
    
	# Use preferred name if available, otherwise use payroll first name
    if ($_."PREFERRED OR CHOSEN FIRST NAME") { 
        $firstName = $_."PREFERRED OR CHOSEN FIRST NAME" 
    } else { 
       $firstName = $_."PAYROLL FIRST NAME" -replace '(\s\w*)$', '' 
    }
	 
    $displayName = $firstName + "*" + $_."PAYROLL LAST NAME"
	$fullName = $firstName + " " + $_."PAYROLL LAST NAME"
	
	# Extract job title after the hyphen
    $jobTitle = ""
    if ($_."JOB TITLE" -match '-\s*(.*)$') {
        $jobTitle = $matches[1].Trim()
    }

	# Extract department after the hyphen
	$department = ""
	if ($_."HOME DEPARTMENT" -match '-\s*(.*)$') {
		$department = $matches[1].Trim()
	}

	# Extract phone extension
	$extension = $_."EXTENSION"

    # Add the DisplayName, JobTitle, Department, FullName, and Extension values to results array as a hashtable
    $results += [PSCustomObject]@{
        DisplayName = $displayName
        JobTitle = $jobTitle
		Department = $department
		FullName = $fullName
		Extension = $extension
	}
}

# Active Directory querying
$foundUsers = @()
$notFoundUsers = @()

$results | ForEach-Object {
	$user = Get-ADUser -Filter "DisplayName -like '$($_.DisplayName)'" -Properties *
	If ($user) {
		# Create ADUser instance called userUpdate
		$userUpdate = Get-ADUser -Identity $user.SamAccountName -Properties Title,Description,Office,Department,OfficePhone,EmailAddress
		
		# Map userUpdate properties to update in AD
		$userUpdate.Title = $_.jobTitle
		$userUpdate.Description = $_.jobTitle
		$userUpdate.Office = $_.department
		$userUpdate.Department = $_.department
		if ($_.extension) {$userUpdate.OfficePhone = $_.extension}
		$userUpdate.EmailAddress = $user.UserPrincipalName
		
		# Update AD user properties
		Set-AdUser -Instance $userUpdate
		
		# Uncomment for generating CSVs
		<#$foundUsers += [PSCustomObject]@{
		ADDisplayName = $user.displayName
        ADJobTitle = $user.title
		ADDepartment = $user.department
		ADPhoneNumber = $user.telephoneNumber
		FullName = $_.fullName
		JobTitle = $_.jobTitle
		Department = $_.department
		Extension = $_.extension
		}#>
	
	} Else {
		$notFoundUsers += [PSCustomObject]@{
		FullName = $_.fullName
		JobTitle = $_.jobTitle
		Department = $_.department
		}
	
	}
}


# Uncomment to export CSV list of employees found in AD
#$foundUsers | Export-CSV FoundEmployees.csv -NoTypeInformation

# Uncomment to export CSV list of employees not found in AD
#$notFoundUsers | Export-CSV NotFoundEmployees.csv -NoTypeInformation
