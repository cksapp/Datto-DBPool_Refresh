function Remove-RefreshDBPoolLog {
<#
    .SYNOPSIS
        Remove log files older than a specified number of days.

    .DESCRIPTION
        The Remove-RefreshDBPoolLog cmdlet removes log files older than a specified number of days.

        By default, log files are stored in the following location and will be removed:
            $env:USERPROFILE\RefreshDBPool\Logs

    .PARAMETER LogPath
        Define the location of the log files.

        By default, log files are stored in the following location:
            $env:USERPROFILE\RefreshDBPool\Logs

    .PARAMETER LogFileName
        Define the name of the log files.

        By default, log files are named:
            RefreshDBPool_*.log

    .PARAMETER LogRotationDays
        Define the number of days to keep log files.
        By default, log files older than 90 days will be removed.

    .PARAMETER Force
        If specified, the function will not prompt for confirmation before removing the log files.

    .EXAMPLE
        Remove-RefreshDBPoolLog

        Remove log files older than 90 days.

    .EXAMPLE
        Remove-RefreshDBPoolLog -LogPath C:\RefreshDBPool\Logs -LogFileName "RefreshDBPool_*.log" -LogRotationDays 7 -Force

        Remove log files older than 7 days from the specified location.

    .INPUTS
        N/A

    .OUTPUTS
        N/A

    .NOTES
        N/A

    .LINK
        N/A
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [string]$LogPath = $RefreshDBPool_LogPath,

        [string]$LogFileName = $RefreshDBPool_LogFileName,

        [int]$LogRotationDays = $RefreshDBPool_LogRotationDays,

        [switch]$Force
    )

    begin {

        if (-not (Test-Path -Path $LogPath -ErrorAction SilentlyContinue)) {
            throw "Log path does not exist. Run 'Export-RefreshDBPoolModuleSetting' first."
        }

    }

    process {

        $logFiles = Get-ChildItem -Path $LogPath -Filter "*$LogFileName" -File -ErrorAction SilentlyContinue
        if (-not $logFiles) {
            Write-Warning "No log files matching '*$LogFileName' found in '$LogPath'."
            return
        }

        $logFilesToRemove = $logFiles | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$LogRotationDays) }
        if (-not $logFilesToRemove) {
            Write-Warning "No log files found in [ $LogPath ] older than '$LogRotationDays' days."
            return
        }

        foreach ($log in $logFilesToRemove) {

            if ($Force -or $PSCmdlet.ShouldProcess("[ $log ]", 'Remove Log file')) {
                try {
                    Remove-Item -Path $log.FullName -Force -ErrorAction Stop
                    Write-Verbose -Message "Removed log file: [ $($log.FullName) ]"
                }
                catch {
                    Write-Verbose -Message "Failed to remove log file: [ $($log.FullName) ]"
                    Write-Error -Message "$_"
                }
            }

        }

    }

    end {}

}
