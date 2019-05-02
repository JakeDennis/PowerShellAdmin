<#
 NAME: NTP Time and Drift Monitor.ps1
 
 AUTHOR: Jake Dennis
 DATE  : 3/1/2018

 DESCRIPTION
     Script used to monitor NTP servers for latency and time drift from their source and import into SolarWinds SAM module.
     This version differs from the version SolarWinds uses due to output requirements and 32-bit constraints. 
     This version is designed for 64-bit PowerShell and outputs values with labels
#>

### Get Date and Time for Logging
function Get-TimeStamp {
    
   return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    
}

### Get SWIS-Snapin for Database Connection and CRUD commands
if (-not (Get-PSSnapin | where {$_.Name -eq "SwisSnapin"})) {

    Add-PSSnapin "SwisSnapin"

} 

$swis = Connect-Swis –Trusted –Hostname localhost

#Run the script with the NTP Server hostname as the argument (e.g. PS D:\> & 'D:\Scripts\NTP Time and Drift Monitor.ps1' antp)

$NTPServer = $args[0];
$CurrentTime = w32tm /monitor /computers:$NTPserver

#Error Check and exit with 1 value for SolarWinds to interpret as down
if($CurrentTime -match "Error")
{
    Write-Host Message:NTP request to $NTPServer failed to query for time statistics

    Exit 1
}
else
{
    #Pulling Array of Characters out of w32tm command output
    $Stratum = $CurrentTime | Select-String -Pattern "Stratum:" #-Context 9
    $Latency = $CurrentTime | Select-String -Pattern "ICMP:" #-Context 35,15
    $Source = $CurrentTime | Select-String -Pattern "RefID:" #-Context 9,20
    $Drift = $CurrentTime | Select-String -Pattern "NTP:" #-Context 10,5
                
    #Turning array object types into strings
    $StratumShort = [string]$Stratum
    $LatencyShort = [string]$Latency
    $SourceShort = [string]$Source
    $DriftShort = [string]$Drift

    #Trim strings to only numbers for statistic ingest by SolarWinds
    $SourceShort = $SourceShort.Substring(35)
    $StratumShort = $StratumShort.Split(@(" "))
    $StratumShort = $StratumShort[1]
    $LatencyShort = $LatencyShort.Substring(10)
    $DriftShort = $DriftShort.Substring(9,20)
    
    #Output variables in the correct format of either message or statistic for SolarWinds ingest
    Write-Host Message.Source: $SourceShort
    Write-Host Statistic.Stratum: $StratumShort
    Write-Host Statistic.Drift: $DriftShort
    Write-Host Statistic.Latency: $LatencyShort

    Exit 0
}