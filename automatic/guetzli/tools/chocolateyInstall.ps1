$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path $MyInvocation.MyCommand.Definition
if ((Get-ProcessorBits 64) -and $env:chocolateyForceX86 -ne 'true') {
    Write-Host "Installing 64 bit version"
    rm $toolsDir\guetzli_windows_x86_x32.exe
    mv $toolsDir\guetzli_windows_x86-64_x64.exe $toolsDir\guetzli.exe -Force
} else {
    Write-Host "Installing 32 bit version"
    rm $toolsDir\guetzli_windows_x86-64_x64.exe
    mv $toolsDir\guetzli_windows_x86_x32.exe $toolsDir\guetzli.exe -Force
}
