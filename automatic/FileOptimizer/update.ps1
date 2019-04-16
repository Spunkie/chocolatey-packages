import-module au

. "..\_scripts\all.ps1"

$releases = 'https://sourceforge.net/projects/nikkhokkho/files/FileOptimizer/'

function global:au_SearchReplace {
   @{
        "tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*url\s*=\s*)('.*')"          = "`$1'$($Latest.URL32)'"
            "(?i)(^\s*checksum\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum32)'"
        }
    }
}

function global:au_AfterUpdate  {
    Remove-Item ".\*.nupkg"
    Set-DescriptionFromReadme -SkipFirst 2
}

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases
    $title = $download_page.Links | ? href -EQ '/projects/nikkhokkho/files/latest/download' | % title | select -First 1
    $version = $title -split '/' | select -First 1 -Skip 2

    @{
        Version      = $version
        URL32        = "https://iweb.dl.sourceforge.net/project/nikkhokkho/FileOptimizer/${version}/FileOptimizerSetup.exe"
    }
}

try {
    update -ChecksumFor 32
} catch {
    $ignore = "Unable to connect to the remote server"
    if ($_ -match $ignore) { Write-Host $ignore; 'ignore' } else { throw $_ }
}
