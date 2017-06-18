$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
    packageName   = 'flac'
    unzipLocation = $toolsDir
    fileType      = 'ZIP'
    url           = 'http://downloads.xiph.org/releases/flac/flac-1.3.2-win.zip'
    checksum      = '4cca0acfa829921ab647f48e83f4b40288f2018d7819f0b15230d3992c13c966'
    checksumType  = 'sha256'
}

Install-ChocolateyZipPackage @packageArgs


$packageVersion = '1.3.2'
$installFolder = "flac-$packageVersion-win"

if (Get-OSArchitectureWidth -eq 64) {
	Remove-Item -Recurse (Join-Path "$toolsDir" (Join-Path "$installFolder" 'win32'))
} else {
	Remove-Item -Recurse (Join-Path "$toolsDir" (Join-Path "$installFolder" 'win64'))
}
