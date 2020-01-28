[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$ParentFolderPath,

    #File Age in Days
    [Parameter(Mandatory)]
    [int]$AgeThreshold
)
$Threshold = (Get-Date).AddDays(-$AgeThreshold)
$OldFiles = Get-ChildItem $ParentFolderPath -Recurse -Force | Where-Object { $_.LastWriteTime -lt $Threshold -and !$_.PsIsContainer}

$OldFiles |
Sort-Object -Property Length |
Select-Object FullName, LastWriteTime, @{Name = "MBytes"; Expression = { "{0:N0}" -f ($_.Length / 1MB) } } |
Format-Table -AutoSize

$Prompt = Read-Host "Would you like to delete the files in $($ParentFolderPath) older than $($Threshold) (Y/N)?"
if ($Prompt -like 'y') {
    $Size = $OldFiles | Measure-Object -Property Length
    $Prompt2 = Read-Host "$($Size.Count) files totaling $([math]::Round($Size.Sum/1MB,2)) MB will be deleted. Are you sure (Y/N)?"
    if ($Prompt2 -eq 'y') {
        foreach ($Path in $OldFiles.FullName) {
            Remove-Item -Path $Path -Force
        }
    }
    else {
        Break
    }
}
else {
    Break
}
