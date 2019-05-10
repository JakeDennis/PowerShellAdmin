function Resolve-SamAccount {
<#
.SYNOPSIS
    Helper function that resolves SAMAccount
#>
    param(
        [string]
            $SamAccount
    )
    
    process {
        try
        {
            $ADResolve = ([adsisearcher]"(samaccountname=$Users)").findone().properties['samaccountname']
        }
        catch
        {
            $ADResolve = $null
        }

        if (!$ADResolve) {
            Write-Warning "User `'$SamAccount`' not found in AD, please input correct SAM Account"
        }
        $ADResolve
    }
}

function Add-ADAccounttoRDPUser {
<#
.SYNOPSIS   
	Script to add an AD User or group to the Remote Desktop Users group    
.DESCRIPTION 
	The script can use either a plaintext file or a computer name as input and will add the trustee (user or group) to the Remote Desktop Users group on the computer
.PARAMETER InputFile
	A path that contains a plaintext file with computer names
.PARAMETER Computer
	This parameter can be used instead of the InputFile parameter to specify a single computer or a series of computers using a comma-separated format
.PARAMETER Trustee
	The SamAccount name of an AD User or AD Group that is to be added to the Remote Desktop Users group
.EXAMPLE   
	Add-ADAccounttoRDPUser -Computer Server01 -Trustee domain\user
.EXAMPLE   
	Add-ADAccounttoRDPUser -Computer 'Server01','Server02' -Trustee domain\group
.EXAMPLE   
	Add-ADAccounttoRDPUser -InputFile C:\Computers.txt -Trustee User01
#>
    param(
        [Parameter(ParameterSetName= 'InputFile',
                   Mandatory       = $true
        )]
        [string]
            $InputFile,
        [Parameter(ParameterSetName= 'Computer',
                   Mandatory       = $true
        )]
        [string[]]
            $Computer,
        [Parameter(Mandatory=$true)]
        [string]
            $Users
    )

$UserGroup = "Remote Desktop Users"

    if ($Users -notmatch '\\') {
        $ADResolved = (Resolve-SamAccount -SamAccount $Users)
        $Users = 'WinNT://',"$env:userdomain",'/',$ADResolved -join ''
    } else {
        $ADResolved = ($Users -split '\\')[1]
        $DomainResolved = ($Users -split '\\')[0]
        $Users = 'WinNT://',$DomainResolved,'/',$ADResolved -join ''
    }

    if (!$InputFile) {
	    $Computer | ForEach-Object {
		    Write-Verbose "Adding '$ADResolved' to Remote Desktop Users group on '$_'"
		    try {
			    ([adsi]"WinNT://$_/$UserGroup,group").add($Users)
			    Write-Verbose "Successfully completed command for '$ADResolved' on '$_'"
		    } catch {
			    Write-Warning $_
		    }	
	    }
    } else {
	    if (!(Test-Path -Path $InputFile)) {
		    Write-Warning 'Input file not found, please enter correct path'
	    }
	    Get-Content -Path $InputFile | ForEach-Object {
		    Write-Verbose "Adding '$ADResolved' to Remote Desktop Users group on '$_'"
		    try {
			    ([adsi]"WinNT://$_/$UserGroup,group").add($Users)
			    Write-Verbose 'Successfully completed command'
		    } catch {
			    Write-Warning $_
		    }        
	    }
    }
}

foreach($Server in $Servers){
    Add-ADAccounttoRDPUser -Computer $Server -Trustee $Users
    $Server
}
