#Compare directories 
$Dir1 = get-childitem -recurse 'C:\folder1'
$Dir2 = get-childitem -recurse 'C:\folder2'
$Diff = Compare-Object -referenceobject $Dir1 -differenceobject $Dir2
$Report = @()

#Create output for csv report
foreach ($File in $Diff){
    $Path = $File.InputObject.Fullname
    $DiffFile = Get-childitem -Recurse $Path
    $Table = New-Object PSCustomObject -property @{
        'Name'       = $Path
        'Created'    = $DiffFile.CreationTime
        'LastAccess' = $DiffFile.LastAccessTime
        'Size'       = $DiffFile.Length
    }
    $Report += $Table
}
$Report | Export-CSV -Path .\DirectoryDiff.csv -NoTypeInformation