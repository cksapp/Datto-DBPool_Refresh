function Sync-DBPoolContainer {
<#
    .SYNOPSIS
        Refreshes the specified DBPool container(s) using the DBPool API. By default, this function will refresh all containers if no IDs are provided.

    .DESCRIPTION
        This function refreshes the specified DBPool container(s) using the DBPool API. By default, this function will refresh all containers if no IDs are provided.

    .PARAMETER Id
        The ID(s) of the container(s) to refresh. If no IDs are provided, all containers will be refreshed.

    .PARAMETER TimeoutSeconds
        The maximum time in seconds to wait for the container(s) to refresh. The default value is 3600 seconds (1 hour).

    .PARAMETER Force
        If specified, the function will not prompt for confirmation before refreshing the container(s).

    .INPUTS
        [int] - Array of ID(s) of the container(s) to perform the refresh action on.

    .OUTPUTS
        [void] - No output is returned.

    .EXAMPLE
        Sync-DBPoolContainer
        Refreshes all DBPool containers.

    .EXAMPLE
        Sync-DBPoolContainer -Id 1234
        Refreshes the DBPool container with the ID 1234.

    .EXAMPLE
        Sync-DBPoolContainer -Id 1234, 5678
        Refreshes the DBPool containers with the IDs 1234 and 5678.

    .EXAMPLE
        Sync-DBPoolContainer -Id $(Get-DBPoolContainer -DefaultDatabase "Database_Name").Id
        Refreshes all DBPool containers matching the specified database name.

    .EXAMPLE
        Sync-DBPoolContainer -Id $(Get-DBPoolContainer -NotLike -Name "*Container_Name*").Id -Force
        Refreshes all DBPool containers not matching the specified container name.

    .NOTES
        N/A

    .LINK
        N/A
#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('ContainerId')]
        [int[]]$Id = $RefreshDBPool_Container_Ids,

        [Parameter(DontShow = $true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$TimeoutSeconds = $RefreshDBPool_TimeoutSeconds,

        [switch]$Force
    )

    begin {

        if (!(Get-Variable -Name 'DBPool_ApiKey' -Scope Global -ErrorAction SilentlyContinue)) {
            try {
                Get-RefreshDBPoolApiKey -Force -Verbose:$false -ErrorAction Stop
            }
            catch {
                throw $_
            }
        }

        if (-not $PSBoundParameters['TimeoutSeconds']) {
            $TimeoutSeconds = 3600
        }
    }

    process {

        if (!$Id) {
            Write-Warning 'No container IDs provided. Retrieving all container IDs.'
            try {
                $Id = Get-DBPoolContainer -ListContainer -ErrorAction Stop | Select-Object -ExpandProperty Id
            } catch {
                Write-Error $_
            }
        }

        $IdsToRefresh = [System.Collections.ArrayList]::new()
        foreach ($n in $Id) {
            if ($Force -or $PSCmdlet.ShouldProcess("Container [ ID: $n ]", '[ Refresh ]')) {
                $IdsToRefresh.Add($n) | Out-Null
            }
        }

        if ($IdsToRefresh.Count -gt 0) {
            Invoke-DBPoolContainerAction -Action refresh -Id $IdsToRefresh -Force -Verbose:$VerbosePreference -ThrottleLimit $IdsToRefresh.Count -TimeoutSeconds $TimeoutSeconds
        } elseif ($IdsToRefresh.Count -eq 0) {
            Write-Warning 'No containers refreshed.'
        }

    }

    end {}

}
