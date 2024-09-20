
$userlist = get-aduser -Filter * -Properties 'Name', 'Department', 'OfficePhone', 'EmailAddress'
Add-Content -Path 'C:\stuff\userreport.csv' -Value "Name:,Department:,Phone Number:,EmailAddress:"

foreach ($user in $userlist ) {
	$nam = $user.Name
	$dep = $user.Department
	$pho = $user.OfficePhone
	$eml = $user.EmailAddress
	Add-Content -Path 'C:\stuff\userreport.csv' -Value "$Nam,$dep,$pho,$Eml,"

}
