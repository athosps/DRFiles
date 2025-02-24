﻿<#
Created:	 2013-01-08
Version:	 1.0
Author       Mikael Nystrom and Johan Arwidmark       
Homepage:    http://www.deploymentfundamentals.com

Disclaimer:
This script is provided "AS IS" with no warranties, confers no rights and 
is not supported by the authors or DeploymentArtist.

Author - Mikael Nystrom
    Twitter: @mikael_nystrom
    Blog   : http://deploymentbunny.com

Author - Johan Arwidmark
    Twitter: @jarwidmark
    Blog   : http://deploymentresearch.com
#>
Param
(
    [parameter(mandatory=$true,HelpMessage="Please, provide a name.")][ValidateNotNullOrEmpty()]$Account,
    [parameter(mandatory=$true,HelpMessage="Please, provide the organization unit(s) to be used.")][ValidateNotNullOrEmpty()]$TargetOUs
)

# Start logging to screen
Write-host (get-date -Format u)" - Starting"

# This is what we typed in
Write-host "Account to search for is" $Account
Write-Host "OUs to search for are" $TargetOUs

$CurrentDomain = (Get-ADDomain).DistinguishedName
$SearchAccount = Get-ADUser $Account
$SAM = $SearchAccount.SamAccountName
$UserAccount = $CurrentDomain.NetBIOSName+"\"+$SAM

Write-Host "Account is = $UserAccount"

$OUs = $TargetOUs -split ";"

foreach ($OU in $OUs) {
    $OrganizationalUnitDN = $OU # Do not concatenate $CurrentDomain here

    Write-host "Processing OU = " $OrganizationalUnitDN

    dsacls.exe $OrganizationalUnitDN /G $UserAccount":CCDC;Computer" /I:T | Out-Null
    dsacls.exe $OrganizationalUnitDN /G $UserAccount":LC;;Computer" /I:S | Out-Null
    dsacls.exe $OrganizationalUnitDN /G $UserAccount":RC;;Computer" /I:S | Out-Null
    dsacls.exe $OrganizationalUnitDN /G $UserAccount":WD;;Computer" /I:S  | Out-Null
    dsacls.exe $OrganizationalUnitDN /G $UserAccount":WP;;Computer" /I:S  | Out-Null
    dsacls.exe $OrganizationalUnitDN /G $UserAccount":RP;;Computer" /I:S | Out-Null
    dsacls.exe $OrganizationalUnitDN /G $UserAccount":CA;Reset Password;Computer" /I:S | Out-Null
    dsacls.exe $OrganizationalUnitDN /G $UserAccount":CA;Change Password;Computer" /I:S | Out-Null
    dsacls.exe $OrganizationalUnitDN /G $UserAccount":WS;Validated write to service principal name;Computer" /I:S | Out-Null
    dsacls.exe $OrganizationalUnitDN /G $UserAccount":WS;Validated write to DNS host name;Computer" /I:S | Out-Null
    dsacls.exe $OrganizationalUnitDN
}

Write-host (get-date -Format u)" - Finished"

