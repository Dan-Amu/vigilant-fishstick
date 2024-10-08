Import-Module ActiveDirectory
Write-Host $args[0]

$ExcelImport = Import-Excel $args[0]

$AvdelingConversion = @{
	'Slags' = 'Salg'
	'Salgs' = 'Salg'
	'Kunde Support' = 'Kundestøtte'
	'Utviklings' = 'Utvikling'
}

function GenerateUsername {
	param (
		$FirstName,
		$LastName
	)
	$LastNameLength = echo $LastName | Measure-Object -Character
	$LastNameLength = $LastNameLength.Characters
	
	$FirstName = $FirstName.ToLower()
	$LastName = $LastName.ToLower()
	
	$ExistingUsernames = (Get-ADUser -Filter *).SamAccountName
	$PotentialUsername = 'Administrator'
	
	$a = 0
	$b = 1
	$c = 0
	$d = 1
	
	while (($ExistingUsernames -contains $PotentialUsername) -eq $true) {
	        $PotentialUsername = -join($FirstName[$a], $FirstName[$b], $LastName[$c], $LastName[$d])
	        #Write-Host $PotentialUsername

	        if ($d -lt $LastNameLength ) { $d += 1 }
	        #Write-Host $d
	         elseif($b -lt $FirstNameLength ){ 
			 $b += 1
			 $d  = 1}
	        else { Write-Host "Cannot create user $FirstName $LastName" }
	}
	$FinalUsername = $PotentialUsername
	#Write-Host $PotentialUsername
	return $FinalUserName

}
$CleanedImportList = @()

#clean up the imported data
foreach ($ImportedUser in $ExcelImport) {

#	Write-Host ( $AvdelingConversion.ContainsKey($ImportedUser.Avdeling) )
#	Write-Host $ImportedUser.Avdeling
#	if ( ($AvdelingConversion.ContainsKey($ImportedUser.Avdeling)) -eq $true ) {
#		$ImportedUser.Avdeling	= $AvdelingConversion[$ImportedUser.Avdeling]
#		Write-Host $AvdelingConversion[$ImportedUser.Avdeling]
#	}

	if ($ImportedUser.'User login name' -eq '<see naming convention>') {
   		if ($AvdelingConversion.ContainsKey($ImportedUser.Avdeling)) {
   	 		$ImportedUser.Avdeling = $AvdelingConversion[$ImportedUser.Avdeling]
   		#	Write-Host "Converted Avdeling: $($ImportedUser.Avdeling)"
   	 	}

		$ImportedUserInfo = [PSCustomObject]@{
			Fornavn 	= $ImportedUser.Fornavn
			Initial 	= $ImportedUser.'Midt initial'
			Etternavn 	= $ImportedUser.Etternavn
			Avdeling	= $ImportedUser.Avdeling
			Passord 	= " "
			Tlf		= $ImportedUser.mobiltelefon
	
		}
	$CleanedImportList += $ImportedUserInfo
	}
}

$FormattedImportList = @()

foreach ($CleanedUser in $CleanedImportList) {
	
	$Sam = GenerateUsername -FirstName $CleanedUser.Fornavn -LastName $CleanedUser.Etternavn
	#Write-Host $Sam
	$CleanedUserInfo = @{
		'SamAccountName'        = $Sam
		'UserPrincipalName'     = (-join($Sam, '@fsi-danamu.com'))
		'Name' 			= (-join($CleanedUser.Fornavn, ' ', $CleanedUser.Initial, '. ', $CleanedUser.Etternavn))
		'EmailAddress'		= (-join($Sam, '@fsi-danamu.com'))
		'GivenName' 		= $CleanedUser.Fornavn
		'Initial'		= $CleanedUser.Initial
		'Surname' 		= $CleanedUser.Etternavn
		'AccountPassword' 	= (ConvertTo-SecureString -AsPlainText 'Passord1234567' -Force)
    		'ChangePasswordAtLogon' = $true 
    		'Enabled'               = $true 
    		'Path'                  = 'OU='+$CleanedUser.Avdeling+',OU=Ansatte,DC=fsi-danamu,DC=com' 
    		'PasswordNeverExpires'  = $false 
		'OfficePhone'		= $CleanedUser.Tlf
		'Department'		= $CleanedUser.Avdeling
	}

	New-ADUser  @CleanedUserInfo
	Add-ADGroupMember -Identity $CleanedUser.Avdeling -Members $Sam 
#	Write-Host $CleanedUserInfo.Name	
#	Write-Host $CleanedUser.Avdeling
}
#$Parameters = @{
#    'SamAccountName'        = $Sam
#    'UserPrincipalName'     = $UPN 
#    'Name'                  = $Fullname
#    'EmailAddress'          = $Email 
#    'GivenName'             = $FirstName 
#    'Surname'               = $Lastname  
#    'AccountPassword'       = $password 
#    'ChangePasswordAtLogon' = $true # Set False if you do not want user to change password at next logon.
#    'Enabled'               = $true 
#    'Path'                  = $OU
#    'PasswordNeverExpires'  = $False # Set True if Password should expire as set on GPO.
#}
#New-ADUser @Parameters

#write-host $AvdelingConversion['Kunde Support']
