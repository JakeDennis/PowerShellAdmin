$server1 = Read-Host "Server 1"
$server2 = Read-Host "Server 2"
$creds = Get-Credential 

$server1Patches = get-hotfix -computer $server1 -Credential $creds | Where-Object {$_.HotFixID -ne "File 1"}

$server2Patches = get-hotfix -computer $server2 -Credential $creds | Where-Object {$_.HotFixID -ne "File 1"}

$m = Compare-Object ($server1Patches) ($server2Patches) -Property HotFixID | measure

$m.Count