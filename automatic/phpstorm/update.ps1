import-module au

. "..\_scripts\all.ps1"

$releases = 'https://confluence.jetbrains.com/display/PhpStorm/PhpStorm+Early+Access+Program'
$directory = Split-Path $MyInvocation.MyCommand.Definition

function global:au_SearchReplace {
   @{
        "tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*url\s*=\s*)('.*')"          = "`$1'$($Latest.URL)'"
            "(?i)(^\s*checksum\s*=\s*)('.*')"     = "`$1'$($Latest.lChecksum)'"
            "(?i)(^\s*checksumType\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType)'"
        }

        "tools\chocolateyUninstall.ps1" = @{
            "(?i)(build_version\s*=\s*)('.*')"    = "`$1'$($Latest.build_version)'"
        }

        "$($Latest.PackageName).nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$($Latest.ReleaseNotes)`$2"
        }
    }
}

function global:au_AfterUpdate  {
    Remove-Item ".\*.nupkg"
    Set-DescriptionFromReadme -SkipFirst 2
}

function global:au_GetLatest {
    # Unlike the stable version there is no API to get the latest version#.
    # The only way I've found to get EAP version# info is by scrapping docs.
    # So because of that, below this point is a bunch of bullshit.

    $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing
    $tmp_url = [regex]::match($download_page.RawContent, 'http(.*).exe"').Value # fullurl of exe download with junk

    $major_version = [regex]::match($download_page.RawContent, 'Download version[\D]*([0-9\.]*).*EAP').Groups[1].Value # 2017.1

    if($major_version -ne '') {
        # if( $major_version.Split('.').count -eq 2 ) {
            # $major_version = $major_version + '.0' # 2017.1.0
        # }
        $build_version = [regex]::match($tmp_url, 'PhpStorm-EAP-(.*).exe').Groups[1].Value # 171.3780.27
        # $version = $major_version + '.' + $build_version.Replace('.', '') + '-EAP' # 2017.1.0.171378027-EAP
        $version = $major_version + '-EAP' # 2017.1-EAP

        $url = "https://download.jetbrains.com/webide/PhpStorm-EAP-$build_version.exe"
        $sha_url = $url + '.sha256';
        $download_sha = Invoke-WebRequest -Uri $sha_url -UseBasicParsing
        $sha256 = ([regex]::match($download_sha.RawContent, '.*(\bPhpStorm\b).*').Value) -split ' ' | select -First 1

        $build_array = $build_version.Split('.')[0..1]
        $short_build_version = $build_array -join '.' # 171.3780

        # Jetbrains can be a little inconsistent in their naming of document pages.
        # So we verify the release specific page actually exist where we think it should.
        # If not fallback to a documentation page that contains a list of all release note pages.
        try {
            Write-Host "Test version specific releaseNotes url"
            $release_url = "https://confluence.jetbrains.com/display/PhpStorm/PhpStorm+EAP+$short_build_version+Release+Notes"
            $response = Invoke-WebRequest -Uri $release_url -method head
        } catch {
            Write-Host ">>`tERROR:`t`tVersion specific releaseNotes url test failed" -foreground "red"
            # Check for 404 status code and ignore other status codes that might be temporary only (i.e. 5xx codes)
            if ($_.Exception.Response.StatusCode -eq 404) {
                Write-Host ">>`t404 response`tFalling back to generic releaseNotes url" -foreground "red"
                $release_url = "https://confluence.jetbrains.com/display/PhpStorm/PhpStorm+Release+Notes"
            } else {
                Write-Host ">>`t$($_.Exception.Response.StatusCode) response" -foreground "red"
            }
        }
        Write-Host ">>`t$($release_url)" -foreground "DarkGreen"

        @{
            Version         = $version
            ReleaseNotes    = $release_url
            URL             = $url
            lChecksum       = $sha256
            ChecksumType    = 'sha256'
            build_version   = $build_version
        }
    } else {
        # If no version was found it's likely there is no valid EAP series right now.
        # Return the current nuspec version so AU does not error out.
        Write-Host "Error`t: No version was found" -foreground "red"
        Write-Host ">>`t: It's likely there is no valid EAP series right now or the format of the release page has changed." -foreground "red"
        Write-Host ">>`t: Check " -foreground red -nonewline; Write-Host "$releases" -foreground cyan;

        [xml]$cnuspec = (Get-Content "${directory}\phpstorm.nuspec")
        $version = $cnuspec.package.metadata.version

        @{
            Version         = $version
        }
    }
}

try {
    update -ChecksumFor none
} catch {
    $ignore = "Unable to connect to the remote server"
    if ($_ -match $ignore) { Write-Host $ignore; 'ignore' } else { throw $_ }
}
