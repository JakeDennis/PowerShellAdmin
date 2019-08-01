<#
 NAME  : CheckAppServers.ps1
 AUTHOR: Jake Dennis
 DATE  : 7/31/2019
 DESCRIPTION
        This script will check a list of Windows servers and gather memory and drive space metrics along with the number logged on users.
 LINK
        https://github.com/JakeDennis/PowerShellAdmin
#>

$Servers = Get-Content "C:\Scripts\AppServers.txt"
$CSVReport = "C:\Scripts\AppServersReport_$(Get-Date -Format yyyy-MM-dd_hhmmss).csv"

foreach($Server in $Servers){
    $PingTest = Test-Connection $Server -Count 1 | Select Address, IPv4Address
    $Hostname = $PingTest.Address
    $IPAddress = $PingTest.IPv4Address
    $OperatingSystem = Get-WmiObject Win32_OperatingSystem
    $Disks = Get-WmiObject  Win32_LogicalDisk -ComputerName $Server -ErrorAction SilentlyContinue -Filter "DriveType = 3"
    $UpTime = $OperatingSystem.ConvertToDateTime($OperatingSystem.LocalDateTime) - $OperatingSystem.ConvertToDateTime($OperatingSystem.LastBootUpTime)
    $UpTime = [math]::Round($UpTime.TotalDays,2)
    $Sessions = quser /server:$Server
    if($Sessions -eq $null){
        $Sessions = @("none")
    }
  
    foreach($Disk in $Disks){
        [pscustomobject]@{
        Hostname = $Hostname.ToUpper()
        IPAddress = $IPAddress.IPAddressToString
        'UpTime(Days)' = $UpTime
        NumOfUsers = $Sessions.Count - 1
        'MemoryAvailable(GB)' = [math]::Round($OperatingSystem.FreePhysicalMemory/(1024*1024),2)
        'TotalMemory(GB)' = [math]::Round($OperatingSystem.TotalVisibleMemorySize/(1024*1024),2)
        'MemoryAvailable(%)' = [math]::Round(($OperatingSystem.FreePhysicalMemory/$OperatingSystem.TotalVisibleMemorySize)*100,2)
        DriveLetter = $Disk.DeviceID
        'SpaceAvailable(GB)' = [math]::Round($Disk.FreeSpace/1GB,2)
        'TotalSpace(GB)' = [math]::Round($Disk.Size/1GB,2)
        'SpaceAvailable(%)' = [math]::Round(($Disk.FreeSpace/$Disk.Size)*100,2)
        } | Export-Csv -Path $CSVReport -NoTypeInformation -Append
    }
}

