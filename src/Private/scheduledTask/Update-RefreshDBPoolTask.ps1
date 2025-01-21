function Update-RefreshDBPoolTask {
<#
    .SYNOPSIS
        Updates the refresh DBPool scheduled task.

    .DESCRIPTION
        This function updates the scheduled task that runs the refresh DBPool script by updating path and arguments.

    .PARAMETER Force
        Forces the update of the scheduled task.

    .INPUTS
        N/A

    .OUTPUTS
        N/A

    .EXAMPLE
        Update-RefreshDBPoolTask

        This example updates the scheduled task that runs the refresh DBPool script.

    .NOTES
        This function is currently only supported on Windows systems.

    .LINK
        https://datto-dbpool-refresh.kentsapp.com/Internal/scheduledTask/Update-RefreshDBPoolTask/
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [switch]$Force
    )

    begin {

        if ($PSEdition -eq 'Desktop') {
            $PSExecutable = if (Get-Command -Name 'pwsh' -ErrorAction SilentlyContinue) {
                (Get-Command pwsh).Source
            } else {
                (Get-Command powershell).Source
            }
        } elseif ($PSEdition -eq 'Core') {
            if ($IsWindows) {
                $PSExecutable = Join-Path -Path $PSHOME -ChildPath 'pwsh.exe'
            } elseif ($IsLinux) {
            } elseif ($IsMacOS) {
            }
        }

    }

    process {

        $moduleBasePath = $( Split-Path -Path $((Get-Command Register-RefreshDBPoolTask).Module).path )
        $scriptDir = $( Join-Path -Path $moduleBasePath -ChildPath 'scripts' )
        $scriptFile = $( Join-Path -Path $scriptDir -ChildPath 'Invoke-RefreshDBPoolContainer.ps1' )

        if ($IsWindows -or $PSEdition -eq 'Desktop') {

            $taskPath = 'Datto'
            $taskName = 'DBPool-Refresh'
            try {
                $task = Get-ScheduledTask -TaskPath "*$taskPath*" -TaskName $taskName -ErrorAction SilentlyContinue

                if (-not $task) {
                    Write-Warning "Scheduled task [ $taskName ] not found. Run 'Register-RefreshDBPoolTask' first."
                    return
                }

                if ($Force -or $PSCmdlet.ShouldProcess("Scheduled task [ $taskName ]", 'Update')) {
                    $actionParams = @{
                        Execute          = "`"$PSExecutable`""
                        Argument         = "-WindowStyle Minimized -NoProfile -ExecutionPolicy Bypass -File `"$scriptFile`""
                        WorkingDirectory = "$moduleBasePath"
                    }
                    $task.Actions = New-ScheduledTaskAction @actionParams

                    Set-ScheduledTask -InputObject $task -Verbose:$VerbosePreference
                }

            }
            catch {
                Write-Error $_
            }
        }
        else {
            Write-Warning "This function is currently only supported on Windows."
            #TODO: Add support for Linux/MacOS using cron jobs or similar such as anacron
        }

    }

    end {}

}
