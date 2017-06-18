$tools = Split-Path $MyInvocation.MyCommand.Definition

. $tools\helper.ps1

$build_version = '172.2103.5'

$packageArgs = @{
    PackageName     = 'phpstorm'
    FileType        = 'exe'
    Silent          = '/S'
    File            = (Get-Uninstaller -Name "JetBrains PhpStorm $build_version")
}
Uninstall-ChocolateyPackage @packageArgs
