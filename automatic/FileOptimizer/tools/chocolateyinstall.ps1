$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
    packageName     = 'FileOptimizer'
    installerType   = 'exe'
    url             = 'https://downloads.sourceforge.net/project/nikkhokkho/FileOptimizer/9.80.1769/FileOptimizerSetup.exe'
    checksum        = 'f9481503c9aa832d4f880700ccd7af9b6ad569b22e2937210b2abd4416d84bbe'
    checksumType    = 'sha256'
    silentArgs      = '/S'
    validExitCodes  = @(0)
}
Install-ChocolateyPackage @packageArgs
