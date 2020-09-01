$NewUsersList=Import-CSV "C:\Scripts\TSMART-ADUsers_MobilePhone.csv"

ForEach ($User in $NewUsersList) {

$FullName=$User.DisplayName

$mobileNumber=$User.MobilePhone

Get-ADUser -Filter "Name -eq '$FullName'"| Set-ADUser -MobilePhone $mobileNumber

}