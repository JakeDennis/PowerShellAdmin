<#
 NAME: Get-OfflineDisks.ps1
 AUTHOR: Jake Dennis
 DATE  : 8/16/2018

 DESCRIPTION
     This script will check if disks on a server are offline using diskpart.exe. If offline, an automated attempt to online the disk will be executed using DiskPart.exe
 EXAMPLE
     PS C:\Users\user1> Get-OfflineDisks | Out-string
        Offline disk(s) found:
          Disk 1    Offline          40 GB  1024 KB         

        Attempting to online the disk(s)...
        Attempt to online the disk(s) suceeded.

        Online Disk(s):
          Disk 0    Online           60 GB      0 B            Disk 1    Online           40 GB  1024 KB         

        Microsoft DiskPart version 6.3.9600

        Copyright (C) 1999-2013 Microsoft Corporation.
        On computer: SERVER1
#>

#Start Function
Function Get-OfflineDisks{
    #Check for offline disks on the server and set variables for disk status
    $OnlineDisks = "List Disk" | diskpart | where {$_ -match "online"}
    $OfflineDisks = "List Disk" | diskpart | where {$_ -match "offline"}

    #If offline disk(s) exist
    if($OfflineDisks)
    {
        Write-Host "Offline disk(s) found:"
        Write-Host $OfflineDisks
        Write-Host ""
        Write-Host "Attempting to online the disk(s)..."
        Write-Host ""
        #for all offline disk(s) found on the server
        foreach($OffDisk in $OfflineDisks)
        {
    
            $OffDisks = $OffDisk.Substring(2,6)

#Creating command parameters for selecting the disk in DiskPart, attempting to online disk, and disabling read-only attribute
$AutoOnlineDisk = @"
select $OffDisks
attributes disk clear readonly
online disk
attributes disk clear readonly
"@
            #Sending parameters to diskpart
            $AutoOnlineDisk | diskpart
        }
        #Scan disks again after auto-fix
        $OfflineDisks = "List Disk" | diskpart | where {$_ -match "offline"}
        $OnlineDisks = "List Disk" | diskpart | where {$_ -match "online"}

        #If auto-fix failed
        if($OfflineDisks)
        {
            Write-Host "Attempt to online the disk(s) failed."
            Write-Host "Offline disk(s) found:"
            Write-Host $OfflineDisks
            Write-Host ""
            Write-Host $OnlineDisks
        }
        
        #If auto-fix succeeded
        else
        {
            Write-Host "Attempt to online the disk(s) suceeded."
            Write-Host ""
            Write-Host "Online Disk(s):"
            Write-Host $OnlineDisks
        }

    }
    #If no offline disk(s) existed
        else
        {
            Write-Host "All disk(s) are online."
            Write-Host $OnlineDisks
        }
}

#Output function to string variable for email body
$EmailBody = Get-OfflineDisks | Out-String

<#Set email parameters
$Email = @{
From = "Dev Refresh Disk Check <Sender@domain.com>"
To = @("Recipient@domain.com")
Subject = "Disk Check Report"
SMTPServer = "smtp@domain.com"
Body = $EmailBody
}
#>
#Send email; Must be sent as plain text in current format
#Send-MailMessage @Email