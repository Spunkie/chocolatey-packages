$packageName = 'FileOptimizer'
$installerType = 'exe'
$silentArgs = '/S'
$path = "$env:ProgramFiles\FileOptimizer"
$path86 = "${env:ProgramFiles(x86)}\FileOptimizer"

if (Test-Path $path) {
    Uninstall-ChocolateyPackage $packageName $installerType $silentArgs "$path\Uninstall.exe"
}

if (Test-Path $path86) {
    Uninstall-ChocolateyPackage $packageName $installerType $silentArgs "$path86\Uninstall.exe"
}
