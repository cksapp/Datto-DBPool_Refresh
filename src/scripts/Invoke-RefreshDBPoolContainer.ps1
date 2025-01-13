
<#PSScriptInfo

.VERSION 1.0

.GUID 262d1367-1935-4054-b250-04fe75cf4fa3

.AUTHOR Kent Sapp (@cksapp)

.COMPANYNAME

.COPYRIGHT © 2023 Kent sapp. All rights reserved.

.TAGS

.LICENSEURI https://github.com/cksapp/DBPool_Refresh/blob/main/LICENSE

.PROJECTURI https://github.com/cksapp/DBPool_Refresh

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#>

<#Requires -Module Datto.DBPool.Refresh

<#

.DESCRIPTION
 PowerShell script to `Refresh` all child containers in Datto (Kaseya) DBPool, this can be combined with Scheduled Tasks in Windows or a Cron job to automate the refresh script on a set interval.

#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $False, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
    [Alias('Id')]
    [int[]]$ContainerId = $RefreshDBPool_Container_Ids,

    [switch]$Bootstrap
)

begin {
    if (-not $PSBoundParameters.ContainsKey('InformationAction')) {
        $InformationPreference = 'Continue'
    }

    if (-not $PSBoundParameters.ContainsKey('Bootstrap')) {
        $Bootstrap = $true
    }

    if ((Get-ExecutionPolicy) -ne "Bypass") {
        Set-ExecutionPolicy "Bypass" -Force -Scope Process
    }

    if ($Bootstrap) {
        if (!(Get-Module -Name 'Datto.DBPool.API' -ListAvailable)) {
            if (Get-Command -Name 'Install-PSResource' -ErrorAction SilentlyContinue) {
                Install-PSResource -Name 'Datto.DBPool.API' -Scope CurrentUser -Reinstall -TrustRepository -Verbose:$false
            } else {
                Install-Module -Name 'Datto.DBPool.API' -Scope CurrentUser -AllowClobber -Force -Verbose:$false
            }
        }
        try {
            Import-Module -Name 'Datto.DBPool.API' -Force -Verbose:$false
        }
        catch {
            Write-Error $_
            return
        }

        if (!(Get-Module -Name 'Datto.DBPool.Refresh' -ListAvailable)) {
            if (Get-Command -Name 'Install-PSResource' -ErrorAction SilentlyContinue) {
                Install-PSResource -Name 'Datto.DBPool.Refresh' -Scope CurrentUser -Reinstall -TrustRepository -Verbose:$false -Prerelease
            } else {
                Install-Module -Name 'Datto.DBPool.Refresh' -Scope CurrentUser -AllowClobber -Force -Verbose:$false -AllowPrerelease
            }
        }

        Write-Information 'Bootstrap complete.'
    }
}

process {
    if ($Bootstrap) {}

    if ($RefreshDBPool_Logging_Enabled) {
        Start-Transcript -Path $( Join-Path -Path $RefreshDBPool_LogPath -ChildPath ("$(Get-Date -Format 'yyyy-MM-dd')_$RefreshDBPool_LogFileName") ) -Append -Force -NoClobber -Verbose:$false -ErrorAction SilentlyContinue | Out-Null
    }

    Set-DBPoolSecurityProtocol -Verbose:$false

    try {
        Update-RefreshDBPoolModule -Verbose:$PSBoundParameters.ContainsKey('Verbose')
        Update-RefreshDBPoolTask -Verbose:$false -ErrorAction SilentlyContinue | Out-Null

        Get-RefreshDBPoolAPIKey -Force -Verbose:$PSBoundParameters.ContainsKey('Verbose') -ErrorAction SilentlyContinue
    }
    catch {
        Write-Error $_
    }

    if (Test-DBPoolApi -Verbose:$false) {
        Write-Verbose -Message "API Uri 200 Sucess"
        if ($(Test-DBPoolApiKey -Verbose:$false).StatusCode -eq 200) {
            Write-Verbose -Message "ApiKey 200 Sucess"
            Sync-DBPoolContainer -Id $ContainerId -Force -Verbose:$PSBoundParameters.ContainsKey('Verbose')
        }
    }

}

end {

    if ($RefreshDBPool_Logging_Enabled) {

        if ($RefreshDBPool_LogRotationEnabled) {
            Remove-RefreshDBPoolLog -Force -Verbose:$true -ErrorAction SilentlyContinue
        }

        try {
            Stop-Transcript -Verbose:$false
        }
        catch {
            Write-Debug -Message $_
        }

    }

}
