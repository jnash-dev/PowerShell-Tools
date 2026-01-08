Function Get-ExoForwarders
{
<#
   .SYNOPSIS

    This function outputs a list of forwarding addresses associated with a given mailbox.

   .DESCRIPTION

    This function takes the mailbox's email address and uses that to query ExchangeOnline for the 
	ForwardingAddress, ForwardingSmtpAddress, and DeliverToMailboxAndForward attributes of the given mailbox.

   .EXAMPLE
	
	Get-ExoForwarders
	
   .EXAMPLE
   
	Get-ExoForwarders -UserPrincipalName John_Smith@example.com	
	
   .EXAMPLE
	
	Get-ExoForwarders -UPN John_Smith@example
	
   .PARAMETER UserPrincipalName

    The mailbox's email address. Alternatively, use -UPN in place of -UserPrincipalName
         
   .INPUTS
   
    [System.String]
	
   .OUTPUTS
   
    [System.Management.Automation.PSCustomObject]
	
   .NOTES

    Name:  Get-ExoForwarders
    Author: Justin Nash

 #>


#region ParameterDefinitions
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,
ValueFromPipelineByPropertyName=$true)]
[ValidateNotNullOrEmpty()]
[Alias("UPN")]
[string]$UserPrincipalName
)
#endregion


#region ConnectToExchangeOnline
$session = Get-PSSession -Name ExchangeOnline*
If ($session -eq $null) {
	Connect-ExchangeOnline -showbanner:$false > $nul
}
#endregion


#region ParameterHandling
If ($UserPrincipalName) {
$mailboxID = "$UserPrincipalName"
} Else {
$mailboxID = Read-Host "Please enter the mailbox's email address"	
}
#endregion


#region GetExoForwarders
$mailboxProperties = Get-EXOMailbox -Identity $mailboxID -PropertySets Delivery,Minimum | select Name, *forward*
if ($mailboxProperties.ForwardingAddress -eq $null) {
	$consoleOutput = [PSCustomObject]@{
		Name = $mailboxProperties.Name
		DeliverToMailboxAndForward = $mailboxProperties.DeliverToMailboxAndForward
		ForwardingAddress = 'No value set'
	}
if ($mailboxProperties.ForwardingSmtpAddress -eq $null) {
	$consoleOutput | Add-Member -MemberType NoteProperty -Name 'ForwardingSmtpAddress' -Value 'No value set'
	}
} elseif ($mailboxProperties.ForwardingAddress -ne $null) {
	$consoleOutput = [PSCustomObject]@{
	Name = $mailboxProperties.Name
	DeliverToMailboxAndForward = $mailboxProperties.DeliverToMailboxAndForward
	ForwardingAddress = $mailboxProperties.ForwardingAddress
	}
	if ($mailboxProperties.ForwardingSmtpAddress -ne $null) {
		$consoleOutput | Add-Member -MemberType NoteProperty -Name 'ForwardingSmtpAddress' -Value $mailboxProperties.ForwardingSmtpAddress
	} elseif ($mailboxProperties.ForwardingSmtpAddress -eq $null) {
		$consoleOutput | Add-Member -MemberType NoteProperty -Name 'ForwardingSmtpAddress' -Value 'No value set'
	}
}
	


Write-Host "`n"
Write-Host "Requested attributes for $mailboxID are: "
Write-Host Name: $consoleOutput.Name
Write-Host DeliverToMailboxAndForward: $consoleOutput.DeliverToMailboxAndForward
Write-Host ForwardingAddress: $consoleOutput.ForwardingAddress
Write-Host ForwardingSmtpAddress: $consoleOutput.ForwardingSmtpAddress
Write-Host "`r"
Write-Output $consoleOutput
#endregion


#region DisconnectFromExchangeOnline
$pipelineLength = $PSCmdlet.MyInvocation.PipelineLength
$pipelinePosition = $PSCmdlet.MyInvocation.PipelinePosition
#If the first or last item in the pipeline, then close the session
If ($pipelineLength -le $pipelinePosition -Or $pipelineLength -eq 1) {
Get-PSSession | Remove-PSSession > $null
}
#endregion
}
