$2012Servers = @(
"Server1"
"Server2"
)
$2016Servers = @(
"Server3"
"Server4"
)
$Creds = Get-Credential -UserName 'admin' -Message "Enter Windows Server admin credentials."
$Date = Get-Date -Format yyyyMMdd-hhmmss
$2012HotFixReport = @()
$2016HotFixReport = @()

#loop 2012 server array to pull hotfixes remotely
foreach($2012Server in $2012Servers){
    $Hotfixes = Get-HotFix -ComputerName $2012Server -Credential $Creds 
    foreach($Hotfix in $Hotfixes){
        $2012HotFixReport += New-Object PSCustomObject -Property @{
            'Name' = $Hotfix | Select -ExpandProperty CSName
            'HotFixID' = $Hotfix | Select -ExpandProperty HotfixID
            'Description' = $Hotfix | Select -ExpandProperty Description
            'InstalledBy' = $Hotfix | Select -ExpandProperty InstalledBy
            'Source' = $Hotfix | Select -ExpandProperty Caption
        }
    $2012HotfixReport | Export-Csv -Path "C:\temp\2012HotfixReport-$($Date).csv" -Append -NoTypeInformation
    }
    #$2012HotFixReport
}


#loop 2016 server array to pull hotfixes remotely
foreach($2016Server in $2016Servers){
        $Hotfixes = Get-HotFix -ComputerName $2012Server -Credential $Creds 
    foreach($Hotfix in $Hotfixes){
        $2016HotFixReport += New-Object PSCustomObject -Property @{
            'Name' = $Hotfix | Select -ExpandProperty CSName
            'HotFixID' = $Hotfix | Select -ExpandProperty HotfixID
            'Description' = $Hotfix | Select -ExpandProperty Description
            'InstalledBy' = $Hotfix | Select -ExpandProperty InstalledBy
            'Source' = $Hotfix | Select -ExpandProperty Caption
        }
    $2016HotfixReport | Export-Csv -Path "C:\temp\2016HotfixReport-$($Date).csv" -Append -NoTypeInformation
    }
    #$2016HotFixReport
}