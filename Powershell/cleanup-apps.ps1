# Remove extra UWP apps
$exceptions='DesktopAppInstaller|HEIFImageExtension|MSPaint|ScreenSketch|Store|VP9VideoExtensions|WebMediaExtensions|WebpImageExtension|Photos|WindowsCalculator|WindowsCamera|WindowsSoundRecorder|YourPhone|NET|VCLibs'
Get-AppxProvisionedPackage -Online | Where-Object {$_.packagename -NotMatch $exceptions} | Remove-AppxProvisionedPackage -Online 
Get-AppxPackage -AllUsers | Where-Object {$_.name -NotMatch $exceptions} | Remove-AppxPackage