function Update-RefreshDBPoolModule {
<#
    .SYNOPSIS
        Updates the Datto.DBPool.Refresh module if a newer version is available online.

    .DESCRIPTION
        This function checks for updates to the Datto.DBPool.Refresh module and updates it if a newer version is available online.
        The auto-update feature can be disabled by setting the AutoUpdate parameter to $false otherwise, it will default to $true.

    .PARAMETER ModuleName
        The name of the module to update. Defaults to 'Datto.DBPool.Refresh'.

    .PARAMETER AutoUpdate
        If specified, the module will be updated if a newer version is available online. Defaults to $RefreshDBPool_Enable_AutoUpdate variable.

    .PARAMETER AllowPrerelease
        If specified, the module will be updated to the latest prerelease version if available. Defaults to $false.

    .INPUTS
        [string] - ModuleName

    .OUTPUTS
        N/A

    .EXAMPLE
        Update-RefreshDBPoolModule -ModuleName 'Datto.DBPool.Refresh' -AutoUpdate:$true -AllowPrerelease:$false

        Updates the Datto.DBPool.Refresh module if a newer version is available online.

    .NOTES
        N/A

    .LINK
        N/A
#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param (
        [Parameter( Position = 0, Mandatory = $False, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True )]
        [String]$ModuleName = 'Datto.DBPool.Refresh',

        [Parameter(Position = 1, Mandatory = $False)]
        [switch]$AutoUpdate = $RefreshDBPool_Enable_AutoUpdate,

        [Parameter(Position = 2, Mandatory = $False)]
        [switch]$AllowPrerelease = $False
    )

    begin {

        # Pass the InformationAction parameter if bound, default to 'Continue'
        if ($PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSBoundParameters['InformationAction'] } else { $InformationPreference = 'Continue' }

        if ($null -eq $PSBoundParameters['AutoUpdate'] -and $null -eq $RefreshDBPool_Enable_AutoUpdate) {
            $AutoUpdate = $true
            Write-Warning "[ RefreshDBPool_Enable_AutoUpdate ] variable not set, defaulting to $AutoUpdate."
        }
    }

    process {

        switch ($AutoUpdate) {
            $True {
                # Check to update the module if the online version seen is higher than the installed version
                Write-Verbose "Module AutoUpdate is enabled, checking for updates to the module [ $ModuleName ]..."
                try {

                    $installedModule = if (Get-Command -Name Get-InstalledPSResource -ErrorAction SilentlyContinue) {
                        Get-InstalledPSResource -Name $ModuleName -ErrorAction SilentlyContinue -Verbose:$false
                    } else {
                        Get-InstalledModule -Name $ModuleName -AllowPrerelease:$AllowPrerelease -ErrorAction SilentlyContinue -Verbose:$false
                    }
                    $onlineModule = if (Get-Command -Name Find-PSResource -ErrorAction SilentlyContinue) {
                        Find-PSResource -Name $ModuleName -Prerelease:$AllowPrerelease -ErrorAction SilentlyContinue -Verbose:$false
                    } else {
                        Find-Module -Name $ModuleName -AllowPrerelease:$AllowPrerelease -ErrorAction SilentlyContinue -Verbose:$false
                    }
                    $installedModule = $installedModule | Sort-Object -Property { [version]$_.Version } -Descending | Select-Object -First 1
                    $onlineModule = $onlineModule | Sort-Object -Property { [version]$_.Version } -Descending | Select-Object -First 1

                    if (!$installedModule) {
                        try {
                            Write-Warning "Module [ $ModuleName ] does not appear to be installed, attempting to install."
                            if (Get-Command -Name Install-PSResource -ErrorAction SilentlyContinue) {
                                Install-PSResource -Name $ModuleName -Scope 'CurrentUser' -TrustRepository -Prerelease:$AllowPrerelease -ErrorAction Stop -Verbose:$false
                            } else {
                                Install-Module $ModuleName -Scope 'CurrentUser' -Force -AllowPrerelease:$AllowPrerelease -SkipPublisherCheck -ErrorAction Stop -Verbose:$false
                            }
                            Write-Information "Module [ $ModuleName ] successfully installed."
                            Import-Module -Name $ModuleName -Force -Verbose:$false
                        } catch {
                            throw "Error installing module $ModuleName`: $_"
                        }
                    } else {
                        Write-Verbose "Module [ $($installedModule.Name) ] is already installed on the local system."

                        $installedVersion = [version]$installedModule.Version
                        $onlineVersion = [version]$onlineModule.Version

                        Write-Debug "Installed version: [ $installedVersion ] and Online version: [ $onlineVersion ]"

                        if ($installedVersion -eq $onlineVersion) {
                            Write-Host "$ModuleName version installed is [ $installedVersion ] which matches the online version [ $onlineVersion ]" -ForegroundColor Green
                        } elseif ($installedVersion -gt $onlineVersion) {
                            Write-Host "$ModuleName version installed is [ $installedVersion ] which is greater than the online version [ $onlineVersion ]`nStrange, but okay I guess?`n" -ForegroundColor Gray
                        } elseif ($installedVersion -lt $onlineVersion) {
                            Write-Warning "$ModuleName version installed is [ $installedVersion ] which is less than the online version [ $onlineVersion ]"

                            Write-Information "Updating [ $ModuleName ] from version [ $installedVersion ] to [ $onlineVersion ]."
                            if (Get-Command -Name Update-PSResource -ErrorAction SilentlyContinue) {
                                Update-PSResource -Name $ModuleName -Force -Prerelease:$AllowPrerelease -ErrorAction Stop -Verbose:$false
                            } else {
                                Update-Module -Name $ModuleName -Force -TrustRepository -AllowPrerelease:$AllowPrerelease -ErrorAction Stop -Verbose:$false
                            }

                            Import-Module -Name $ModuleName -Force -Verbose:$false
                        }

                    }
                } catch {
                    Write-Error $_
                }

            } Default {
                Write-Information "Module AutoUpdate is disabled, skipping update for module '$ModuleName'."
            }

        }

    }

    end {}

}
