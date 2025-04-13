if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process -Verb runAs -FilePath Powershell -Args "-windowstyle hidden $PSCommandPath"
    exit
}

##############################################################################

# Initialize Winforms

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

# Initiliaze MainForm

$MainForm = New-Object system.Windows.Forms.Form
$MainForm.ClientSize = New-Object System.Drawing.Point(529,400)
$MainForm.text= "Windows Components"
#$MainForm.TopMost = $false

# Initialize Tabcontrol

$TabControl = New-Object System.Windows.Forms.TabControl
$TabControl.Width = $MainForm.ClientRectangle.Width
$TabControl.Height = $MainForm.ClientRectangle.Height
$TabControl.Anchor = "Top, Left, Right, Bottom"

# Integrate TabControl

$MainForm.controls.Add($TabControl)

##############################################################################

# Initilialize Tabs

##############################################################################

# Appx Packages

$AppxTab = New-Object System.Windows.Forms.TabPage
$AppxTab.Text = "Appx Packages"
$AppxTab.Width = $TabControl.ClientRectangle.Width
$AppxTab.Height = $TabControl.ClientRectangle.Height
$AppxTab.Anchor = "Top, Left, Right, Bottom"
#$AppxTab.TabIndex = 0

# Windows Packages

$WindowsPackagesTab = New-Object System.Windows.Forms.TabPage
$WindowsPackagesTab.Text = "Windows Packages"
$WindowsPackagesTab.Width = $TabControl.ClientRectangle.Width
$WindowsPackagesTab.Height = $TabControl.ClientRectangle.Height
$WindowsPackagesTab.Anchor = "Top, Left, Right, Bottom"

# Optional Features

$OptionalFeaturesTab = New-Object System.Windows.Forms.TabPage
$OptionalFeaturesTab.Text = "Optional Features"
$OptionalFeaturesTab.Width = $TabControl.ClientRectangle.Width
$OptionalFeaturesTab.Height = $TabControl.ClientRectangle.Height
$OptionalFeaturesTab.Anchor = "Top, Left, Right, Bottom"

# Services

$ServicesTab = New-Object System.Windows.Forms.TabPage
$ServicesTab.Text = "Services"
$ServicesTab.Width = $TabControl.ClientRectangle.Width
$ServicesTab.Height = $TabControl.ClientRectangle.Height
$ServicesTab.Anchor = "Top, Left, Right, Bottom"

# Integrate Tabs

$TabControl.Controls.Add($AppxTab)
$TabControl.Controls.Add($WindowsPackagesTab)
$TabControl.Controls.Add($OptionalFeaturesTab)
$TabControl.Controls.Add($ServicesTab)

##############################################################################

# Initialize ListViews

##############################################################################

# Appx Packages

$AppxListView = New-Object system.Windows.Forms.ListView
$AppxListView.View = [System.Windows.Forms.View]::Details
$AppxListView.Width = $AppxTab.ClientRectangle.Width
$AppxListView.Height = $AppxTab.ClientRectangle.Height
$AppxListView.Anchor = "Top, Left, Right, Bottom"

$AppxListView.Columns.Add("Name", -2) | Out-Null
$AppxListView.Columns.Add("Arch", -2) | Out-Null
$AppxListView.Columns.Add("Version", -2, 1) | Out-Null
$AppxListView.Columns.Add("Provisioned", -2) | Out-Null
$AppxListView.Columns.Add("Type", -2) | Out-Null
$AppxListView.Columns.Add("Status", -2) | Out-Null

# Appx context menus

$AppxListView.ContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip

$AppxMenuItems = @()
    
$AppxMenuItems += New-Object System.Windows.Forms.ToolStripMenuItem("&Remove")
$AppxMenuItems += New-Object System.Windows.Forms.ToolStripMenuItem("&Provisioned")

$AppxListView.ContextMenuStrip.Items.AddRange($AppxMenuItems)

$AppxListView.ContextMenuStrip.add_Opening({

    # Don't show context menu if there's no Selected Items
    if ($AppxListView.SelectedItems.Count -eq 0) {
        $_.Cancel = $true
        }
    Else {
        # If selected Appx package is provisioned add a checkmark to "Provisioned" menu item
            if($AppxListView.SelectedItems[0].SubItems[3].Text -eq "True") {
                $AppxMenuItems[1].Checked = $true
                }
            Else {
                $AppxMenuItems[1].Checked = $false
            }
        }
    })

# Event Handlers

$AppxMenuItems[0].add_click({
    $SelectedItems = $AppxListView.SelectedItems[0].SubItems
    $SelectedPackage = $AppxPackages | Where-Object {$_.DisplayName -eq $SelectedItems[0].Text}

    Remove-AppxPackage -Package $SelectedItems[0].Text
    })

$AppxMenuItems[1].add_click({
    $SelectedItems = $AppxListView.SelectedItems[0].SubItems
    $Package = $AppxPackages | Where-Object {$_.Name -eq $SelectedItems[0].Text}
    $AppxFilePath = Join-Path -Path $Package.InstallLocation -ChildPath "$package.appx"

    If($SelectedItems[3].Text -eq "True") {
        Remove-AppxProvisionedPackage -Online -PackageName $Package.PackageFullName
        if($?) {
            $SelectedItems[3].Text = "False"
            }
        }
    Else {
        Add-AppxProvisionedPackage -Online -FolderPath $Package.InstallLocation -SkipLicense #doesnt actually work LOL!
        if($?) {
            $SelectedItems[3].Text = "True"
            }
        }
    })

##############################################################################

# Windows Packages

$WindowsPackagesListView = New-Object system.Windows.Forms.ListView
$WindowsPackagesListView.View = [System.Windows.Forms.View]::Details
$WindowsPackagesListView.Width = $WindowsPackagesTab.ClientRectangle.Width
$WindowsPackagesListView.Height = $WindowsPackagesTab.ClientRectangle.Height
$WindowsPackagesListView.Anchor = "Top, Left, Right, Bottom"

$WindowsPackagesListView.Columns.Add("Name", -2) | Out-Null
$WindowsPackagesListView.Columns.Add("State", -2) | Out-Null
$WindowsPackagesListView.Columns.Add("Type", -2) | Out-Null
$WindowsPackagesListView.Columns.Add("Install Time", -2, 1) | Out-Null

# Windows Packages context menus

$WindowsPackagesListView.ContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip

$WindowsPackagesMenuItems = @()
    
$WindowsPackagesMenuItems += New-Object System.Windows.Forms.ToolStripMenuItem("&Uninstall")

$WindowsPackagesListView.ContextMenuStrip.Items.AddRange($WindowsPackagesMenuItems)

$WindowsPackagesListView.ContextMenuStrip.add_Opening({
    # Don't show context menu if there's no Selected Items
    if ($AppxListView.SelectedItems.Count -eq 0) {
        $_.Cancel = $true
        }
    Else {
        # Disable "Start" menu item if service is running
            if($AppxListView.SelectedItems[0].SubItems[1].Text -eq "Running") {
                $AppxMenuItems[1].Enabled  = $true
                }
            Else {
                $AppxMenuItems[1].Enabled  = $false
                }
        # Disable "Stop" menu item if service is stopped
            if($AppxListView.SelectedItems[0].SubItems[1].Text -eq "Stopped") {
                $AppxMenuItems[1].Enabled  = $true
                }
            Else {
                $AppxMenuItems[1].Enabled  = $false
                }
        }
    })

# Event Handlers

$WindowsPackagesMenuItems[0].add_click({

    })

##############################################################################

# Optional Features

$OptionalFeaturesListView = New-Object system.Windows.Forms.ListView
$OptionalFeaturesListView.View = [System.Windows.Forms.View]::Details
$OptionalFeaturesListView.Width = $OptionalFeaturesTab.ClientRectangle.Width
$OptionalFeaturesListView.Height = $OptionalFeaturesTab.ClientRectangle.Height
$OptionalFeaturesListView.Anchor = "Top, Left, Right, Bottom"

$OptionalFeaturesListView.Columns.Add("Name", -2) | Out-Null
$OptionalFeaturesListView.Columns.Add("State", -2) | Out-Null

# Optional Features context menus

$OptionalFeaturesListView.ContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip

$OptionalFeaturesMenuItems = @()
    
$OptionalFeaturesMenuItems += New-Object System.Windows.Forms.ToolStripMenuItem("&Enable")

$OptionalFeaturesListView.ContextMenuStrip.Items.AddRange($OptionalFeaturesMenuItems)

$OptionalFeaturesListView.ContextMenuStrip.add_Opening({

    })

# Event Handlers

$OptionalFeaturesMenuItems[0].add_click({

    })

##############################################################################

# Services

$ServicesListView = New-Object system.Windows.Forms.ListView
$ServicesListView.View = [System.Windows.Forms.View]::Details
$ServicesListView.Width = $ServicesTab.ClientRectangle.Width
$ServicesListView.Height = $ServicesTab.ClientRectangle.Height
$ServicesListView.Anchor = "Top, Left, Right, Bottom"

$ServicesListView.Columns.Add("Name", -2) | Out-Null
$ServicesListView.Columns.Add("Status", -2) | Out-Null
$ServicesListView.Columns.Add("StartType", -2) | Out-Null
$ServicesListView.Columns.Add("Description", -2) | Out-Null
$ServicesListView.Columns.Add("ServiceType", -2) | Out-Null

# Services context menus

$ServicesListView.ContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip

$ServicesMenuItems = @()
    
$ServicesMenuItems += New-Object System.Windows.Forms.ToolStripMenuItem("&Start")
$ServicesMenuItems += New-Object System.Windows.Forms.ToolStripMenuItem("&Stop")
$ServicesMenuItems += New-Object System.Windows.Forms.ToolStripMenuItem("&Restart")

$ServicesListView.ContextMenuStrip.Items.AddRange($ServicesMenuItems)

$ServicesListView.ContextMenuStrip.add_Opening({
    # Don't show context menu if there's no Selected Items
    if ($ServicesListView.SelectedItems.Count -eq 0) {
        $_.Cancel = $true
        }
    Else {
        # Disable "Start" menu item if service is running
            if($ServicesListView.SelectedItems[0].SubItems[1].Text -eq "Running") {
                $ServicesMenuItems[0].Enabled  = $false
                }
            Else {
                $ServicesMenuItems[0].Enabled  = $true
                }
        # Disable "Stop" menu item if service is stopped
            if($ServicesListView.SelectedItems[0].SubItems[1].Text -eq "Stopped") {
                $ServicesMenuItems[1].Enabled  = $false
                }
            Else {
                $ServicesMenuItems[1].Enabled  = $true
                }

        # Disable "Restart" menu item if service is stopped
            if($ServicesListView.SelectedItems[0].SubItems[1].Text -eq "Stopped") {
                $ServicesMenuItems[2].Enabled  = $false
                }
            Else {
                $ServicesMenuItems[2].Enabled  = $true
                }
        }
    })

# Event Handlers

$ServicesMenuItems[0].add_click({
    $SelectedItems = $ServicesListView.SelectedItems[0].SubItems
    $Service = $Services | Where-Object {$_.Name -eq $SelectedItems[0].Text}

    If($SelectedItems[1].Text -eq "Stopped") {
        Start-Service -Name $SelectedItems[0].Text
        if($?) {
            $SelectedItems[1].Text = "Running"
            }
        }
    })

$ServicesMenuItems[1].add_click({
    $SelectedItems = $ServicesListView.SelectedItems[0].SubItems
    $Service = $Services | Where-Object {$_.Name -eq $SelectedItems[0].Text}

    If($SelectedItems[1].Text -eq "Running") {
        Start-Service -Name $SelectedItems[0].Text
        if($?) {
            $SelectedItems[1].Text = "Stopped"
            }
        }
    })

$ServicesMenuItems[2].add_click({
    $SelectedItems = $ServicesListView.SelectedItems[0].SubItems
    $Service = $Services | Where-Object {$_.Name -eq $SelectedItems[0].Text}

    If($SelectedItems[1].Text -eq "Running") {
        Restart-Service -Name $SelectedItems[0].Text
        }
    })

##############################################################################

# Integrate ListViews

$AppxTab.controls.Add($AppxListView)
$WindowsPackagesTab.controls.Add($WindowsListView)
$OptionalFeaturesTab.controls.Add($OptionalFeaturesListView)
$ServicesTab.controls.Add($ServicesListView)

##############################################################################

# Initiliaze data set

##############################################################################

$AppxPackages = Get-AppxPackage
$ProvisionedAppxPackages = Get-AppxProvisionedPackage -online

for ( $i = 0; $i -lt $AppxPackages.length; $i++)
{
    $AppxPackages[$i] | Add-Member -MemberType NoteProperty -Name "Provisioned" -Value $False -Force
    foreach($ProvisionedAppxPackage in $ProvisionedAppxPackages )
    {
        if( $AppxPackages[$i].Name -eq $ProvisionedAppxPackage.DisplayName )
        {
            #$AppxPackages[$i] | Add-Member -MemberType NoteProperty -Name "Provisioned" -Value $True -Force
            $AppxPackages[$i].Provisioned = $True
            #Write-Host $ProvisionedAppxPackage.PackageName "true"
        }
    }
}

$WindowsPackages = Get-WindowsPackage -Online
$OptionalFeatures = Get-WindowsOptionalFeature -Online
$Services = Get-Service

##############################################################################

# Integrate data set

##############################################################################

# Appx Packages
Function Update-AppxPackages {
    foreach($AppxPackage in $AppxPackages)
    {
        $AppxListViewItem = New-Object System.Windows.Forms.ListViewItem($AppxPackage.Name) 
        #$AppxListViewItem.Checked = $True
    
        $AppxListViewItem.Subitems.Add($AppxPackage.Architecture.ToString()) | Out-Null
        $AppxListViewItem.Subitems.Add($AppxPackage.Version) | Out-Null
        $AppxListViewItem.SubItems.Add($AppxPackage.Provisioned.ToString()) | Out-Null
        $AppxListViewItem.Subitems.Add($AppxPackage.SignatureKind.ToString()) | Out-Null
        $AppxListViewItem.Subitems.Add($AppxPackage.Status.ToString()) | Out-Null

        $AppxListView.Items.Add($AppxListViewItem) | Out-Null
    }
}

##############################################################################

# Windows Packages
Function Update-WindowsPackages {
    foreach($WindowsPackage in $WindowsPackages)
    {
        $WindowsListViewItem = New-Object System.Windows.Forms.ListViewItem($WindowsPackage.PackageName) 
    
        $WindowsListViewItem.Subitems.Add($WindowsPackage.PackageState.ToString()) | Out-Null
        $WindowsListViewItem.Subitems.Add($WindowsPackage.ReleaseType.ToString()) | Out-Null
        $WindowsListViewItem.SubItems.Add($WindowsPackage.InstallTime.ToString()) | Out-Null

        $WindowsListView.Items.Add($WindowsListViewItem) | Out-Null
    }
}

##############################################################################

# Optional Features
Function Update-OptionalFeatures {
    foreach($OptionalFeatures in $OptionalFeatures)
    {
        $OptionalFeaturesListViewItem = New-Object System.Windows.Forms.ListViewItem($OptionalFeatures.FeatureName) 
    
        $OptionalFeaturesListViewItem.Subitems.Add($OptionalFeatures.State.ToString()) | Out-Null

        $OptionalFeaturesListView.Items.Add($OptionalFeaturesListViewItem) | Out-Null
    }
}

##############################################################################

# Services

Function Update-Services {
    foreach($Service in $Services)
    {
        $ServicesListViewItem = New-Object System.Windows.Forms.ListViewItem($Service.Name) 
    
        $ServicesListViewItem.Subitems.Add($Service.Status.ToString()) | Out-Null
        $ServicesListViewItem.Subitems.Add($Service.StartType.ToString()) | Out-Null
        $ServicesListViewItem.Subitems.Add($Service.DisplayName.ToString()) | Out-Null
        $ServicesListViewItem.Subitems.Add($Service.ServiceType.ToString()) | Out-Null

        $ServicesListView.Items.Add($ServicesListViewItem) | Out-Null
    }
}

##############################################################################

Update-AppxPackages
Update-WindowsPackages
Update-OptionalFeatures
Update-Services

##############################################################################

[void]$MainForm.ShowDialog()