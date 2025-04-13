#Requires -RunAsAdministrator
$SageSet = "StateFlags0099"
$Base = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\"
$Locations= @(
    "Thumbnail Cache"
)
ForEach($Location in $Locations) {
    Set-ItemProperty -Path $($Base+$Location) -Name $SageSet -Type DWORD -Value 2 -ea silentlycontinue | Out-Null
}
# do the cleanup . have to convert the SageSet number
$Args = "/sagerun:$([string]([int]$SageSet.Substring($SageSet.Length-4)))"
Start-Process -Wait "$env:SystemRoot\System32\cleanmgr.exe" -ArgumentList $Args -WindowStyle Hidden
# Removw the Stateflags
ForEach($Location in $Locations)
{
    Remove-ItemProperty -Path $($Base+$Location) -Name $SageSet -Force -ea silentlycontinue | Out-Null
}