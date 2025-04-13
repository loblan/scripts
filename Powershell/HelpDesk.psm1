
function Find-ADUser {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Name")]
        [string]$Name
    )

    process {
        $Query = "*$Query*"

        get-aduser -filter {
        (CN -like $Query) -or
        (DisplayName -like $Query) -or
        (Name -like $Query) -or
        (GivenName -like $Query) -or
        (Surname -like $Query) -or
        (UserPrincipalName -like $Query) -or
        (mail -like $Query) -or
        (mailNickname -like $Query) -or
        (SamAccountName -like $Query)
        } -Properties * `
        | Select DisplayName,SamAccountName,UserPrincipalName,Description `
        | ft -AutoSize
        }
}


function Get-RemoteUserMappedDrives {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        [Parameter(Mandatory = $false)]
        [string]$Domain = $env:USERDNSDOMAIN,
        [Parameter(Mandatory = $false)]
        [string]$Username
    )

    process {
        $scriptBlock = {
            $user = New-Object System.Security.Principal.NTAccount($Domain,$Username)
            $sid = $user.Translate([System.Security.Principal.SecurityIdentifier]).Value
            Get-Item -LiteralPath "Registry::HKEY_USERS\$sid\Network"
        }
        Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptBlock
    }
}

function Get-RemoteUserMappedDrives {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        [Parameter(Mandatory = $false)]
        [string]$Domain = $env:USERDNSDOMAIN,
        [Parameter(Mandatory = $false)]
        [string]$Username
    )

    process {
        $scriptBlock = {
            $user = New-Object System.Security.Principal.NTAccount($Domain,$Username)
            $sid = $user.Translate([System.Security.Principal.SecurityIdentifier]).Value
            Get-Item -LiteralPath "Registry::HKEY_USERS\$sid\Network"
        }
        Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptBlock
    }
}