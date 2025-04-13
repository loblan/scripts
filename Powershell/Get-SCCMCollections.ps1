# Import the SCCM module
Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

Set-Location '100:\'

Get-CMDeviceCollection | Select-Object CollectionID,Name,Description
