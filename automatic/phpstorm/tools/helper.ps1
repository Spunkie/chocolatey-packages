function Get-Uninstaller {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Name
  )

  $local_key     = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
  $machine_key32 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
  $machine_key64 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'

  $keys = @($local_key, $machine_key32, $machine_key64)

  Get-ItemProperty -Path $keys | ?{ $_.DisplayName -eq $Name } | Select-Object -ExpandProperty UninstallString
}


# UNTESTED!! -- Based on https://github.com/rohm1/phpstorm-eap-installer
function Cleanup-EAP {
    #cleanup old EAP license before install
    Write-Host 'Cleaning up old EAP license before install' -foregroundcolor "magenta"

    # Looking for multiple eval paths
    # Old EAPs save in something like $HOME\.WebIde90\config\eval\PhpStorm9.evaluation.key
    # New EAPs save in something like $HOME\.PhpStorm2016.2\config\eval\PhpStorm162.evaluation.key
    Get-ChildItem -path $HOME\.*\config\ -recurse -filter eval | Remove-Item -force -recurse -verbose

    Write-Host 'Cleaning up old EAP license params in options before install' -foregroundcolor "magenta"

    Get-ChildItem -path $HOME\.*\config\options -recurse -filter options.xml | Foreach-Object {
        Write-Host 'Found options.xml           --' ($_.FullName) -foregroundcolor "magenta";
        $content = Get-Content $_.FullName;


        Write-Host 'Creating backup             --' ($_.FullName + '.bak') -foregroundcolor "magenta";
        $content | Set-Content ($_.FullName + '.bak') -Force -Verbose;


        Write-Host 'Writing new options.xml     --' ($_.FullName) -foregroundcolor "magenta";
        $content | Where-Object {$_ -notmatch 'evlsprt'} | Set-Content $_.FullName -Force -Verbose;


        Write-Host 'Done!' -foregroundcolor "magenta";
        Write-Host "`n"
    }
    Write-Host 'Done cleaning up old old EAP license' -foregroundcolor "magenta"
}
