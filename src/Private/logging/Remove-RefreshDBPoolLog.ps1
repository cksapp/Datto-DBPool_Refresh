function Remove-RefreshDBPoolLog {
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
