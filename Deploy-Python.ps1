param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName,

    [switch]$InstallPython,
    [switch]$InstallPip,
    [switch]$InstallRequirements
)
$script:Cred = Get-Credential -Message "Enter admin credentials to copy and install software to the server."
$script:Session = New-PSSession -ComputerName $ComputerName -Credential $Cred

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if ($InstallPython) {
    $PythonVersion = Read-Host -Prompt 'Enter desired Python version for installation (ex: 3.7.6)'
    Write-Host "Downloading Python $($PythonVersion)..."
    $PythonURI = 'https://www.python.org/ftp/python/' + $PythonVersion + '/python-' + $PythonVersion + '-amd64.exe'
    $PythonFilePath = 'C:\Temp\' + 'python-' + $PythonVersion + '-amd64.exe'
    Invoke-WebRequest -Uri $PythonURI -OutFile $PythonFilePath
    Copy-Item -Path $PythonFilePath -ToSession $Session -Destination $PythonFilePath
    Write-Host 'Installing Python...'
    Invoke-Command -Session $Session -ScriptBlock { & $using:PythonFilePath /quiet InstallAllUsers=1 PrependPath=1 Shortcuts=1 }
}
if ($InstallPip) {
    Write-Host 'Downloading pip...'
    $PipURI = 'https://bootstrap.pypa.io/get-pip.py'
    $PipFilePath = 'C:\Temp\get-pip.py'
    Invoke-WebRequest -Uri $PipURI -OutFile $PipFilePath
    Copy-Item -Path $PipFilePath -ToSession $Session -Destination $PipFilePath
    Write-Host 'Installing pip...'
    Invoke-Command -Session $Session -ScriptBlock { & $using:PipFilePath }
}
if ($InstallRequirements) {
    $RequirementsFilePath = Read-Host -Prompt 'Enter file path to requirements.txt file'
    Write-Host 'Transferring requirements.txt to server...'
    Copy-Item -Path $RequirementsFilePath -ToSession $Session -Destination 'C:\temp\requirements.txt'
    Write-Host 'Installing requirements.txt...'
    $PipCommand = {
        $PipUpdate = Get-Content 'C:\temp\requirements.txt' | ForEach-Object { py -m pip install $_ --no-warn-script-location }
        return $PipUpdate
    }
    Invoke-Command -Session $Session -ScriptBlock $PipCommand
}
$Session = Exit-PSSession