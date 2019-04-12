import-module au

. "..\_scripts\all.ps1"

$releases = 'https://sourceforge.net/projects/flac/files/'

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
    $title = $download_page.Links | ? href -EQ '/projects/flac/files/latest/download' | % title | select -First 1 # /flac-win/flac-1.3.2-win.zip:  released on 2017-01-01 02:11:25 UTC
    $version = [regex]::match($title, '([\d\.]*)-win.zip').Groups[1].Value # 1.3.2

    @{
        Version      = $version
        # URL32        = "https://downloads.sourceforge.net/project/flac/flac-win/flac-${version}-win.zip"
        URL32        = "http://downloads.xiph.org/releases/flac/flac-${version}-win.zip"
    }
}

try {
    update -ChecksumFor 32
} catch {
    $ignore = "Unable to connect to the remote server"
    if ($_ -match $ignore) { Write-Host $ignore; 'ignore' } else { throw $_ }
}
