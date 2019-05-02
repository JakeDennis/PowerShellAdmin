<#
 NAME  : CheckFolderActivity.ps1
 AUTHOR: Jake Dennis
 DATE  : 4/30/2019
 DESCRIPTION
        This script will check a given directory for modified files within a provided interval defined in minutes. If no files are found, a warning message is written to a custom event log. 
 LINK
        https://github.com/JakeDennis/PowerShellAdmin
#>
#Arguments
$Window = -35 #check for activity in last X minutes
$DriveLetter = 'D:'
$CurrentDate = Get-Date -Format MMddyyyy
$DirectoryPath = "\\ProgramData\\Directory\\Logs\\FY$($CurrentDate)\\"
$LogName = "Monitoring"
$LogSource = "Scripts"
$EventID = 1

$WMIDate = (Get-Date).AddMinutes($Window)
$Interval = -$Window
$Count = 0

#Parse folder for directory metadata
try{
    $Files = Get-WmiObject CIM_DataFile -Filter "Drive='$($DriveLetter)' and Path='$($DirectoryPath)'" -ErrorAction Stop
}
catch{
    $ErrorMessage =
@"
    Script: $($PSCommandPath)`n
    Error processing directory: $($DirectoryPath)`n
    $($Error)
"@
    Write-EventLog -LogName $LogName -Source $LogSource -EventId $EventID -EntryType Error -Message "$($ErrorMessage)"
    Exit
}

if ($Files -eq $null){  
  $Count = 0
}
else{
    foreach($File in $Files){
        $FileModifiedTime = $File.ConvertToDateTime($File.LastModified)
        if($FileModifiedTime -ge $WMIDate){
           $Count++
        }
    }
 }

#Write to newly created event log. Use New-EventLog and LimitEventLog commands to create the custom event log.
$InformationMessage = @"
$($Count) file(s) modified in the last $($Interval) minutes.`n
Processed $($DirectoryPath)`n 
Script: $($PSCommandPath)
"@
$WarningMessage = @"
$($Count) file(s) modified in the last $($Interval) minutes.`n
Check if WFM application is processing files sucessfully.`n
Processed $($DirectoryPath)`n
$($PSCommandPath)
"@

if($Count -ge 1){
    Write-EventLog -LogName $LogName -Source $LogSource -EventId $EventID -EntryType Information -Message $InformationMessage
}
if($Count -eq 0){
    Write-EventLog -LogName $LogName -Source $LogSource -EventId $EventID -EntryType Warning -Message $WarningMessage
}

