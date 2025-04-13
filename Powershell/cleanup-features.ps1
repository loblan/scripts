# Cleanup windows features
Write-Host 'Removing optional features...'
$features = @(
    'MediaPlayback',
    'SMB1Protocol',
    #'Xps-Foundation-Xps-Viewer',
    'WorkFolders-Client',
    'WCF-Services45',
    'NetFx4-AdvSrvs',
    #'Printing-Foundation-Features',
    #'Printing-PrintToPDFServices-Features',
    #'Printing-XPSServices-Features',
    'MSRDC-Infrastructure',
    #'MicrosoftWindowsPowerShellV2Root',
    'Internet-Explorer-Optional-amd64'
)
foreach ($feature in $features) {
    Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart
}