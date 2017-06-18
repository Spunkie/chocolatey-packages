$fileName = "color-sustainer.exe"
$linkName = "Color Sustainer.lnk"
$destdir = $(Split-Path -parent $MyInvocation.MyCommand.Definition)

#install start menu shortcut
$programs = [environment]::GetFolderPath([environment+specialfolder]::Programs)
$shortcutFilePath = Join-Path $programs $linkName
$targetPath = Join-Path $destdir $fileName
Install-ChocolateyShortcut -shortcutFilePath $shortcutFilePath -targetPath $targetPath -RunAsAdmin

#make usable in commandline
Install-ChocolateyPath $destdir
