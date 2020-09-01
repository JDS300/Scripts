Import-Module ActiveDirectory

$Domain="@domain.com"

$UserOu="OU=SomeOU,OU=AD Sync Enabled,OU=Company Users,DC=internal,DC=domain,DC=com"

$NewUsersList=Import-CSV "C:\Scripts\ImportCSV.csv"

ForEach ($User in $NewUsersList) {

$FullName=$User.FullName

$givenName=$User.givenName

$telephoneNumber=$User.telephoneNumber

$sAMAccountName=$User.sAMAccountName

$sn=$User.sn

$userPrincipalName=$User.sAMAccountName+$Domain

$userPassword=$User.password

$mail=$User.mail

$office=$User.Office

$mobileNumber=$User.mobilePhone

$ProxyAddresses=$User.proxyAddress

$expire=$null

New-ADUser -PassThru -Path $UserOu -Enabled $True -ChangePasswordAtLogon $False -AccountPassword (ConvertTo-SecureString $userPassword -AsPlainText -Force) -CannotChangePassword $False -EmailAddress $mail –OfficePhone $telephoneNumber -MobilePhone $mobileNumber -Office $office -DisplayName $FullName -GivenName $givenName -Name $FullName -SamAccountName $sAMAccountName -Surname $sn -UserPrincipalName $userPrincipalName -OtherAttributes @{Proxyaddresses=$ProxyAddresses -split ","}

}
