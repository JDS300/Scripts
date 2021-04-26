<#
.SYNOPSIS
    Convert mailbox enabled user into mail enabled user
.DESCRIPTION
	Automates converstion of mailbox enabled user account into a mail enabled user account
.NOTES
    Author: Jonathan - jon@elderec.org
.LINK 
    http://elderec.org
.PARAMETER Identity
	Identity of mailbox enabled user being converted
.PARAMETER EmailAddress
	The users primary email address, this will be used as the external address on the new mail enabled user
.PARAMETER DomainController
	The domain controller to use
.EXAMPLE
	.\Convert-MBUtoMEU.ps1 -Identity "Jon Q. User" -EmailAddress "jon_user@contoso.com"
#>


param (
	[parameter(Mandatory=$true, HelpMessage="Enter the Identity of the user to convert")][string]$Identity,
	[parameter(Mandatory=$true, HelpMessage="Enter the users primary email address")][string]$EmailAddress
)


# get the user
$user = Get-Mailbox -Identity $Identity


# get curret email addresses
$currAddresses = $user.EmailAddresses


# get the X500 address
# $legDn = $user.LegacyExchangeDn


# add the legacy DN to the list
# $currAddresses.add("X500:$legDn")

# get Windows Email Address
$windowsEmailAddress = $user.WindowsEmailAddress

# disable the old mailbox
Disable-Mailbox -Identity $user -Confirm:$false


# Mail enable the user account
Enable-MailUser -Identity $User -ExternalEmailAddress $EmailAddress


# get the new user
$newUser = Get-MailUser -Identity $Identity


# set the new addresses

Set-MailUser -Identity $newUser -EmailAddressPolicyEnabled $false -ExternalEmailAddress $EmailAddress -EmailAddresses $currAddresses -WindowsEmailAddress $windowsEmailAddress
