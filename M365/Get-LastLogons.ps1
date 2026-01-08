#Creates a CSV in the current directory containing account status and last sign ons
Connect-MgGraph -Scopes 'User.ReadWrite.All', 'AuditLog.Read.All'
Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,AccountEnabled,SignInActivity | Select-Object Id,DisplayName,UserPrincipalName,AccountEnabled, @{n="LastSignInDateTime";e={$_.SignInActivity.LastSignInDateTime}} | Export-CSV -Path "LastSignIns.csv" -NoTypeInformation
 

<#@{ #Hashtable used for signin data
    n="LastSignInDateTime"; #Name of column?
    e={$_.SignInActivity.LastSignInDateTime} #Column data?
}#>
