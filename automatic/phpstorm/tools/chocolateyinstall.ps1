$ErrorActionPreference = 'Stop'

$tools = Split-Path $MyInvocation.MyCommand.Definition

. $tools\helper.ps1
# Cleanup-EAP #Can't verify this actually works. Comment out until I add install param and warning for it

$packageArgs = @{
    PackageName     = 'phpstorm'
    FileType        = 'exe'
    Silent          = '/S'
    ChecksumType    = 'sha256'
    Checksum        = 'b381c2087ccbe6d126685cf05c3bfe17aea7be038dd9466fcf7a6261c092face'
    Url             = 'https://download.jetbrains.com/webide/PhpStorm-EAP-172.2103.5.exe'
    validExitCodes  = @(0)
}
Install-ChocolateyPackage @packageArgs
