# PowerShell script to generate a list of all users in an Active Directory domain

# Import the Active Directory module
Import-Module ActiveDirectory

# Get all users in the domain
$users = Get-ADUser -Filter * -Properties Name, SamAccountName, UserPrincipalName, Enabled, LastLogonDate

# Create an array to store user information
$userList = @()

# Iterate through each user and add their information to the array
foreach ($user in $users) {
    $userInfo = [PSCustomObject]@{
        Name = $user.Name
        SamAccountName = $user.SamAccountName
        UserPrincipalName = $user.UserPrincipalName
        Enabled = $user.Enabled
        LastLogonDate = $user.LastLogonDate
    }
    $userList += $userInfo
}

# Export the user list to a CSV file
$userList | Export-Csv -Path "ADUserList.csv" -NoTypeInformation

Write-Host "User list has been exported to ADUserList.csv"
