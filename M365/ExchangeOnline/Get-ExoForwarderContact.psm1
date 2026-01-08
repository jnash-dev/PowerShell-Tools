Function Get-ExoForwarderContact
{
<#
   .SYNOPSIS

    This function outputs the forwarding information for a given Exchange Online Recipient Object

   .DESCRIPTION

    This function takes the object's identity and uses that to query ExchangeOnline for the 
	Identity, Alias, DisplayName, and PrimarySmtpAddress attributes of the given object.

   .EXAMPLE

    Get-ExoForwarderContact

    Asks you for the object's Identity, and then outputs the Identity, Alias, DisplayName, and PrimarySmtpAddress attributes for that object.
	
   .EXAMPLE
	
	Get-ExoForwarderContact -Identity *561*
	
	Outputs the attributes associated with any existing Recipient objects that contain 561 in their Identity fields

   .PARAMETER Identity

    The object's ForwardingAddress and ForwardingSmtpAddress from the Get-ExoForwarders command.
	Alternatively, you can use the last name of the contact.
	      
   .INPUTS
   
    [System.String]
	
   .OUTPUTS
   
    [System.Management.Automation.PSCustomObject]
	
   .NOTES

    Name:  Get-ExoForwarderContact
    Author: Justin Nash

   .LINK

    Coming soon

 #>


#region ParameterDefinitions
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,
ValueFromPipelineByPropertyName=$true)]
[ValidateNotNullOrEmpty()]
[Alias("ForwardingAddress")]
[string]$Identity
)
#endregion

#region Parameter Validation
If ($Identity -eq "No value set") {
		Write-Output "Forwarder does not exist. `n"
		Get-PSSession | Remove-PSSession
		break
}
#endregion

#region ConnectToExchangeOnline
$session = Get-PSSession -Name ExchangeOnline*
If ($session -eq $null) {
	Connect-ExchangeOnline -showbanner:$false > $nul
}
#endregion


#region ParameterHandling
$objectIdentity = "$Identity"
#endregion


#region GetExoForwarderContacts
$objectProperties = Get-EXORecipient -Identity $objectIdentity | select DisplayName, Identity, Alias, PrimarySmtpAddress
Write-Host "`r"
Write-Host "Requested attributes for $objectIdentity are: "
Write-Host DisplayName: $objectProperties.DisplayName
Write-Host Identity: $objectProperties.Identity
Write-Host Alias: $objectProperties.Alias
Write-Host PrimarySmtpAddress: $objectProperties.PrimarySmtpAddress
Write-Host "`r"
Write-Output $objectProperties
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
