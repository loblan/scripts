# Basic text based options menu

$MenuOptions = @(
    "View system information",
    "View network information",
    "View disk information",
    "Exit"
)

Function Show-Menu {
    $SelectedIndex = 0

    # Loop until the user confirms their selection
    $Confirmed = $false
    while (-not $Confirmed) {
        Clear-Host
        Write-Host "Welcome to the PowerShell Console UI!"
        Write-Host "Please select an option from the menu:"

        for ($i = 0; $i -lt $MenuOptions.Count; $i++) {
            if ($i -eq $SelectedIndex) {
                # Write Selected item
                Write-Host ("{0}. {1}" -f ($i + 1), $MenuOptions[$i]) -BackgroundColor Yellow -ForegroundColor Black
            } else {
                Write-Host ("{0}. {1}" -f ($i + 1), $MenuOptions[$i])
            }
        }

        $KeyInfo = $Host.UI.RawUI.ReadKey("IncludeKeyDown,NoEcho")
        switch ($KeyInfo.VirtualKeyCode) {
            38 { # Up arrow
                $SelectedIndex = [Math]::Max(0, $SelectedIndex - 1)
            }
            40 { # Down arrow
                $SelectedIndex = [Math]::Min($SelectedIndex + 1, $MenuOptions.Count - 1)
            }
            13 {# enter key
                $Confirmed = $true
            }
        }
    }

    Clear-Host

    # Execute selected option
    switch ($MenuOptions[$SelectedIndex]) {
        "View system information" {
            Show-SystemInfo
        }
        "View network information" {
            Show-NetworkInfo
        }
        "View disk information" {
            Show-DiskInfo
        }
        "Exit" {
            Exit
        }
    }

    #wait for input key
    $null = $Host.UI.RawUI.ReadKey("IncludeKeyDown,NoEcho")
    
    Show-Menu
}

Function Show-SystemInfo {
    
    Get-ComputerInfo | Format-List
}

Function Show-NetworkInfo {
    Get-NetIPAddress | Format-Table
}

Function Show-DiskInfo {
    Get-Volume | Format-Table
}

Show-Menu
