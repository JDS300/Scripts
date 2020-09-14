#DFS Monitor and email message 
#run as administrator 
#SMTP configuration 
#Found @ https://gallery.technet.microsoft.com/scriptcenter/Monitor-DFS-backlog-and-f2761f16

#Important
#For the initial replication of existing data on the primary member, the staging folder quota must be large enough so that replication can continue even if multiple large files remain in the staging folder because partners cannot promptly download the files. 
#To properly size the staging folder for initial replication, you must take into account the size of the files to be replicated. At a minimum, the staging folder quota for servers running Windows Server 2008 should be at least the size of the 32 largest files in the replicated folder, or the 16 largest files for the SYSVOL folder on a read-only domain controller. To improve performance, set the size of the staging folder quota as close as possible to the size of the replicated folder. 
#To determine the size of the largest files in a replicated folder using Windows Explorer, sort by size and add the 32 largest file sizes (16 if it’s the SYSVOL folder on a read-only domain controller) to get the minimum staging folder size. To get the recommended minimum staging folder size (in gigabytes) from a Windows PowerShell® command prompt, use this Windows PowerShell command where <replicatedfolderpath> is the path to the replicated folder (change 32 to 16 for read-only replicated folders): 
#Run this to set the Determine Largest Files:
#(Get-ChildItem <replicatedfolderpath>-recurse | Sort-Object length -descending | select-object -first 32 | measure-object -property length -sum).sum /1gb

$EmailFrom = "alerts@mydomain.ca" 
$EmailTo = "alerts@mydomain.ca" 
$EmailTo1 = "daniel@mydomain.ca" 
$EmailTo2 = "joao@mydomain.ca" 
$EmailTo3 = "thiago@mydomain.ca" 
$EmailSubject = "DFS Monitoring Report" 
$emailbody = "Server reached predefined amount of files in backlog" 
$SMTPServer = "smtp.my-isp.ca" 
 
#Starts here 
 
$RGroups = Get-WmiObject  -Namespace "root\MicrosoftDFS" -Query "SELECT * FROM DfsrReplicationGroupConfig" 
$ComputerName=$env:ComputerName 
$Succ=0 
$Warn=0 
$Err=0 
  
foreach ($Group in $RGroups) 
{ 
    $RGFoldersWMIQ = "SELECT * FROM DfsrReplicatedFolderConfig WHERE ReplicationGroupGUID='" + $Group.ReplicationGroupGUID + "'" 
    $RGFolders = Get-WmiObject -Namespace "root\MicrosoftDFS" -Query  $RGFoldersWMIQ 
    $RGConnectionsWMIQ = "SELECT * FROM DfsrConnectionConfig WHERE ReplicationGroupGUID='"+ $Group.ReplicationGroupGUID + "'" 
    $RGConnections = Get-WmiObject -Namespace "root\MicrosoftDFS" -Query  $RGConnectionsWMIQ 
    foreach ($Connection in $RGConnections) 
    { 
        $ConnectionName = $Connection.PartnerName#.Trim() 
        if ($Connection.Enabled -eq $True) 
        { 
            #if (((New-Object System.Net.NetworkInformation.ping).send("$ConnectionName")).Status -eq "Success") 
            #{ 
                foreach ($Folder in $RGFolders) 
                { 
                    $RGName = $Group.ReplicationGroupName 
                    $RFName = $Folder.ReplicatedFolderName 
  
                    if ($Connection.Inbound -eq $True) 
                    { 
                        $SendingMember = $ConnectionName 
                        $ReceivingMember = $ComputerName 
                        $Direction="inbound" 
                    } 
                    else 
                    { 
                        $SendingMember = $ComputerName 
                        $ReceivingMember = $ConnectionName 
                        $Direction="outbound" 
                    } 
  
                    $BLCommand = "dfsrdiag Backlog /RGName:'" + $RGName + "' /RFName:'" + $RFName + "' /SendingMember:" + $SendingMember + " /ReceivingMember:" + $ReceivingMember 
                    $Backlog = Invoke-Expression -Command $BLCommand 
  
                    $BackLogFilecount = 0 
                    foreach ($item in $Backlog) 
                    {                         
                        if ($item -ilike "*Backlog File count*") 
                        {                       
                            $BacklogFileCount = [int]$Item.Split(":")[1].Trim() 
                        } 
                    } 
  
                    if ($BacklogFileCount -eq 0) 
                    { 
                        $Color="white" 
                        $Succ=$Succ+1 
                    } 
                    elseif ($BacklogFilecount -lt 10000) 
                    { 
                        $Color="yellow" 
                        $Warn=$Warn+1 
                         
                    } 
                    else 
                    { 
                        $Color="red" 
                        $Err=$Err+1 
                         
                    } 
                     
                    $results = Write-Host "$BacklogFileCount files in backlog $SendingMember->$ReceivingMember for $RGName" -fore $Color  
                    $results1 = Write-Output "$BacklogFileCount files in backlog $SendingMember->$ReceivingMember for $RGName" | Out-File -FilePath C:\scripts\dfslog-$(get-date -f yyyy-MM-dd).txt -Append 
                } # Closing iterate through all folders 
            #} # Closing  If replies to ping 
        } # Closing  If Connection enabled 
    } # Closing iteration through all connections 
} # Closing iteration through all groups 
 
 
Send-MailMessage -Port 25 -SmtpServer $SMTPServer -From $EmailFrom -To $EmailTo,$EmailTo1,$EmailTo2,$EmailTo3 -Subject $EmailSubject -Attachments C:\scripts\dfslog-$(get-date -f yyyy-MM-dd).txt 
 
#reference https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/send-mailmessage?f=255&MSPPError=-2147217396 
