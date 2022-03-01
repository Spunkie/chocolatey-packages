import-module au

. "..\_scripts\all.ps1"

$releases = 'https://ftp.osuosl.org/pub/xiph/releases/flac/'

function global:au_SearchReplace {
   @{
        "tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*url\s*=\s*)('.*')"             = "`$1'$($Latest.URL32)'"
            "(?i)(^\s*checksum\s*=\s*)('.*')"        = "`$1'$($Latest.Checksum32)'"
            "(?i)(^\s*.packageVersion\s*=\s*)('.*')" = "`$1'$($Latest.Version)'"
        }
    }
}

function global:au_AfterUpdate  {
    Remove-Item ".\*.nupkg"
    Set-DescriptionFromReadme -SkipFirst 2
}

function global:au_BeforeUpdate {
    Remove-Item ".\tools\flac-*" -Force -Recurse
}

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases

    $versions = foreach ($href in $download_page.links.href) {
        if ($href -notmatch "^.+?\w+?-(\d+\.\d+\.\d+).+$") {
            continue
        }
        [Version]$matches[1]
    }
    $latest_version = -join ($versions | Sort-Object -Descending | Select -First 1) # 1.3.4

    @{
        Version      = $version
        URL32        = "https://downloads.xiph.org/releases/flac/flac-${latest_version}-win.zip"
    }
}

try {
    update -ChecksumFor 32
} catch {
    $ignore = "Unable to connect to the remote server"
    if ($_ -match $ignore) { Write-Host $ignore; 'ignore' } else { throw $_ }
}
