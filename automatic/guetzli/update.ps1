import-module au

. "..\_scripts\all.ps1"

$releases = 'https://api.github.com/repos/google/guetzli/releases/latest'

function global:au_SearchReplace {
   @{
        "$($Latest.PackageName).nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$($Latest.releaseNotes)`$2"
            "(\<licenseUrl\>).*?(\</licenseUrl\>)" = "`${1}$($Latest.LICENSE)`$2"
        }

        ".\legal\VERIFICATION.txt" = @{
          "(?i)(\s+x32:).*"              = "`${1} $($Latest.URL32)"
          "(?i)(\s+x64:).*"              = "`${1} $($Latest.URL64)"
          "(?i)(checksum32:).*"          = "`${1} $(Get-RemoteChecksum -Url $Latest.URL32)"
          "(?i)(checksum64:).*"          = "`${1} $(Get-RemoteChecksum -Url $Latest.URL64)"
          "(?i)(Get-RemoteChecksum32).*" = "`${1} $($Latest.URL32)"
          "(?i)(Get-RemoteChecksum64).*" = "`${1} $($Latest.URL64)"
          "(?i)(LICENSE:).*"             = "`${1} $($Latest.LICENSE)"
        }
    }
}

function global:au_BeforeUpdate { Get-RemoteFiles -Purge }
function global:au_AfterUpdate  { Set-DescriptionFromReadme -SkipFirst 2 }

function global:au_GetLatest {
    $download_page = (Invoke-RestMethod -Uri $releases -UseBasicParsing)
    $tag_name = $download_page.tag_name

    $version = $tag_name -replace "[^\d\.]"

    foreach($obj in $download_page.assets) {
        if ($obj.name -eq 'guetzli_windows_x86-64.exe') {
            $URL64 = $obj.browser_download_url
        } elseif ($obj.name -eq 'guetzli_windows_x86.exe') {
            $URL32 = $obj.browser_download_url
        }
    }

    @{
        Version      = $version
        URL32        = $URL32
        URL64        = $URL64
        releaseNotes = "https://github.com/google/guetzli/releases/tag/$tag_name"
        LICENSE      = "https://raw.githubusercontent.com/google/guetzli/$tag_name/LICENSE"
    }
}


try {
    update -ChecksumFor none
} catch {
    $ignore = "Unable to connect to the remote server"
    if ($_ -match $ignore) { Write-Host $ignore; 'ignore' } else { throw $_ }
}
