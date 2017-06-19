import-module au

. "..\_scripts\all.ps1"

$releases = 'https://sourceforge.net/projects/snappy-driver-installer-origin/files/'

function global:au_SearchReplace {
   @{
        "tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*url\s*=\s*)('.*')"          = "`$1'$($Latest.URL32)'"
            "(?i)(^\s*checksum\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum32)'"
            "(?i)(^\s*.fullVersion\s*=\s*)('.*')" = "`$1'$($Latest.fullVersion)'"
            "(?i)(^\s*.baseVersion\s*=\s*)('.*')" = "`$1'$($Latest.baseVersion)'"
            "(?i)(^\s*.fileName32\s*=\s*)('.*')"  = "`$1'SDIO_R$($Latest.baseVersion).exe'"
            "(?i)(^\s*.fileName64\s*=\s*)('.*')"  = "`$1'SDIO_x64_R$($Latest.baseVersion).exe'"
        }

        ".\legal\VERIFICATION.txt" = @{
          "(?i)(\s+x32:).*"              = "`${1} $($Latest.URL32)"
          "(?i)(checksum32:).*"          = "`${1} $($Latest.Checksum32)"
          "(?i)(Get-RemoteChecksum32).*" = "`${1} $($Latest.URL32)"
        }
    }
}

function global:au_AfterUpdate  {
    $baseVersion = $Latest.baseVersion
    $fullVersion = $Latest.fullVersion

    Remove-Item ".\*.nupkg"
    Set-DescriptionFromReadme -SkipFirst 2
    New-Item ".\tools\SDIO_${fullVersion}" -ItemType Directory
    New-Item ".\tools\SDIO_${fullVersion}\SDIO_R${baseVersion}.exe.gui" -ItemType file
    New-Item ".\tools\SDIO_${fullVersion}\SDIO_x64_R${baseVersion}.exe.gui" -ItemType file
}

function global:au_BeforeUpdate {
    Remove-Item ".\tools\SDIO_*" -Force -Recurse
}

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases
    $title = $download_page.Links | ? href -EQ '/projects/snappy-driver-installer-origin/files/latest/download?source=files' | % title | select -First 1 # /SDIO_0.6.0.558.zip
    $version = [regex]::match($title, '[a-zA-Z_]*([\d\.]*)\.zip').Groups[1].Value # 0.6.0.558
    $baseVersion = $version.split('.')[-1] # 558

    @{
        Version      = $version
        fullVersion  = $version
        baseVersion  = $baseVersion
        URL32        = "https://downloads.sourceforge.net/project/snappy-driver-installer-origin/SDIO_${version}.zip"
    }
}

try {
    update -ChecksumFor 32
} catch {
    $ignore = "Unable to connect to the remote server"
    if ($_ -match $ignore) { Write-Host $ignore; 'ignore' } else { throw $_ }
}
