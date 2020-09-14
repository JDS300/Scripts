$NewUsersList=Import-CSV "C:\Scripts\Users.csv"

ForEach ($User in $NewUsersList) {

$FullName=$User.DisplayName

$ProxyAddress=$User.ProxyAddresses

Get-ADUser -Filter "Name -eq '$FullName'"| Set-ADUser -Replace @{ProxyAddresses=$ProxyAddress -split ","}

$ChgUser = Get-ADUser -Filter "Name -eq '$FullName'" -Properties ProxyAddresses | Select Name, ProxyAddresses

#Display the User Information post change
$ChgUser

}
