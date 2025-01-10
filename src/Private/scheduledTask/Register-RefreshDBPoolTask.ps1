function Register-RefreshDBPoolTask {
<#
    .SYNOPSIS
        Creates a scheduled task to automate the refresh of Datto DBPool containers.

    .DESCRIPTION
        This function sets up a scheduled task that runs a PowerShell script to refresh Datto DBPool containers.
        The task can be configured to run on specific days of the week and at a specified time.

    .PARAMETER TriggerTime
        Specifies the time of day at which the scheduled task should run.
        This should be set to roughly ~1 hour before shift start, so that all containers are refreshed and ready for use.

    .PARAMETER ExcludeDaysOfWeek
        Specifies the days of the week on which the scheduled task should NOT be run.
        This will generally be days off work, by default the task will not run on Sundays and Saturdays.

    .INPUTS
        N/A

    .OUTPUTS
        N/A

    .EXAMPLE
        Register-RefreshDBPoolTask -TriggerTime "7AM"

        This example creates a scheduled task that runs every day at 7:00 AM, except on Sundays and Saturdays.

    .EXAMPLE
        Register-RefreshDBPoolTask -TriggerTime "15:00"

        This example creates a scheduled task that runs every day at 3:00 PM, except on Sundays and Saturdays.

    .EXAMPLE
        Register-RefreshDBPoolTask -ExcludeDaysOfWeek 'Sunday','Monday' -TriggerTime "4:30PM"

        This example creates a scheduled task that runs every day at 4:30 PM, except on Sunday and Monday.

    .NOTES
        This function is currently designed to work only on Windows systems. It uses the Task Scheduler to create and manage the scheduled task.
        Will look to add support for Linux/MacOS using cron jobs or similar such as anacron in the future.

    .LINK
        https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtask
#>

    [CmdletBinding()]
    [Alias('New-RefreshDBPoolTask')]
    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "The time of day at which the scheduled task should run.")]
        [DateTime]$TriggerTime,

        [Parameter(Mandatory = $false, HelpMessage = "The days of the week on which the scheduled task should NOT be run.")]
        [ValidateSet('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')]
        [string[]]$ExcludeDaysOfWeek = @('Sunday','Saturday')
    )

    begin {

        # Days of the week to run the task
        $daysToRun = $( [System.DayOfWeek].GetEnumValues() ) | Where-Object { $ExcludeDaysOfWeek -notcontains [System.DayOfWeek]::$_ }

        if ($PSEdition -eq 'Desktop') {
            #$PSExecutable = Join-Path -Path $PSHOME -ChildPath 'powershell.exe'
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
            $taskDescription = 'Scheduled task to automate refresh of Datto DBPool containers.'

            # Task trigger
            $triggerParams = @{
                Weekly     = $true
                DaysOfWeek = $daysToRun
                At         = $TriggerTime
            }
            $taskTrigger = New-ScheduledTaskTrigger @triggerParams

            # Task Action
            $actionParams = @{
                Execute          = "`"$PSExecutable`""
                Argument         = "-WindowStyle Minimized -NoProfile -ExecutionPolicy Bypass -File `"$scriptFile`" -Bootstrap"
                WorkingDirectory = "$moduleBasePath"
            }
            $taskAction = New-ScheduledTaskAction @actionParams

            # Task Settings
            $settingsParams = @{
                AllowStartIfOnBatteries = $true
                Compatibility           = 'Win8'
                ExecutionTimeLimit      = (New-TimeSpan -Hours 2)
                RestartCount            = 3
                RestartInterval         = (New-TimeSpan -Minutes 5)
                StartWhenAvailable      = $true
                WakeToRun               = $true
            }
            $taskSettings = New-ScheduledTaskSettingsSet @settingsParams
            # 3 corresponds to 'Stop the existing instance' https://stackoverflow.com/questions/59113643/stop-existing-instance-option-when-creating-windows-scheduled-task-using-powersh/59117015#59117015
            $taskSettings.CimInstanceProperties.Item('MultipleInstances').Value = 3

            # Task
            $taskParams = @{
                Action   = $taskAction
                Description = $taskDescription
                Settings = $taskSettings
                Trigger  = $taskTrigger
            }
            $task = New-ScheduledTask @taskParams
            $task.Author = "Kent Sapp (@cksapp)"

            $registerParams = @{
                InputObject = $task
                TaskName    = $taskName
                TaskPath    = $taskPath
                User        = $env:USERNAME
                Force       = $true
                ErrorAction = 'Stop'
            }
            try {
                $scheduledTask = Register-ScheduledTask @registerParams

                try {
                    $scheduledTask.Date = '2023-08-30T12:34:56.7890000'
                    Set-ScheduledTask -InputObject $scheduledTask -Verbose:$VerbosePreference -ErrorAction Stop | Out-Null
                }
                catch {
                    Write-Warning "Error updating 'Created Date' for scheduled task [ $taskName ]: $_"
                }
            }
            catch {
                Write-Error $_.Exception.Message
            }
        }
        else {
            Write-Warning "This function is currently only supported on Windows."
            #TODO: Add support for Linux/MacOS using cron jobs or similar such as anacron
        }

    }

    end {}

}
