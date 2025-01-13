---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version: https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtask
schema: 2.0.0
---

# Register-RefreshDBPoolTask

## SYNOPSIS

Creates a scheduled task to automate the refresh of Datto DBPool containers.

## SYNTAX

```PowerShell
Register-RefreshDBPoolTask [-TriggerTime] <DateTime> [[-ExcludeDaysOfWeek] <DayOfWeek[]>] [<CommonParameters>]
```

## DESCRIPTION

This function sets up a scheduled task that runs a PowerShell script to refresh Datto DBPool containers.
The task can be configured to run on specific days of the week and at a specified time.

## EXAMPLES

### EXAMPLE 1

```PowerShell
Register-RefreshDBPoolTask -TriggerTime "7AM"
```

This example creates a scheduled task that runs every day at 7:00 AM, except on Sundays and Saturdays.

### EXAMPLE 2

```PowerShell
Register-RefreshDBPoolTask -TriggerTime "15:00"
```

This example creates a scheduled task that runs every day at 3:00 PM, except on Sundays and Saturdays.

### EXAMPLE 3

```PowerShell
Register-RefreshDBPoolTask -ExcludeDaysOfWeek 'Sunday','Monday' -TriggerTime "4:30PM"
```

This example creates a scheduled task that runs every day at 4:30 PM, except on Sunday and Monday.

## PARAMETERS

### -TriggerTime

Specifies the time of day at which the scheduled task should run.
This should be set to roughly ~1 hour before shift start, so that all containers are refreshed and ready for use.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDaysOfWeek

Specifies the days of the week on which the scheduled task should NOT be run.
This will generally be days off work, by default the task will not run on Sundays and Saturdays.

```yaml
Type: DayOfWeek[]
Parameter Sets: (All)
Aliases:
Accepted values: Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday

Required: False
Position: 2
Default value: @('Sunday','Saturday')
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### N/A

## OUTPUTS

### N/A

## NOTES

This function is currently designed to work only on Windows systems.
It uses the Task Scheduler to create and manage the scheduled task.
Will look to add support for Linux/MacOS using cron jobs or similar such as anacron in the future.

## RELATED LINKS

[https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtask](https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtask)
