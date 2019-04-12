import-module au

. "..\_scripts\all.ps1"

$releases = 'https://www.snappy-driver-installer.org/feed/'

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
    New-Item ".\tools\SDIO_${fullVersion}\SDIOTranslationTool.exe.gui" -ItemType file
}

function global:au_BeforeUpdate {
    Remove-Item ".\tools\SDIO_*" -Force -Recurse
}

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases
    [xml]$download_page = $download_page.Content

    $title = $download_page.rss.channel.item[0].description.InnerText
    $version = [regex]::match($title, '([\d]+\.[\d]+\.[\d]+\.[\d]+)').Groups[0].Value # 1.5.0.699
    $baseVersion = $version.split('.')[-1] # 699

    @{
        Version      = $version
        fullVersion  = $version
        baseVersion  = $baseVersion
        URL32        = "https://snappy-driver-installer.org/downloads/SDIO_${version}.zip"
    }
}

try {
    update -ChecksumFor 32
} catch {
    $ignore = "Unable to connect to the remote server"
    if ($_ -match $ignore) { Write-Host $ignore; 'ignore' } else { throw $_ }
}
