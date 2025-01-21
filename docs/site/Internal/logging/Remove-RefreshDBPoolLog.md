---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version:
schema: 2.0.0
---

# Remove-RefreshDBPoolLog

## SYNOPSIS

Remove log files older than a specified number of days.

## SYNTAX

```PowerShell
Remove-RefreshDBPoolLog [[-LogPath] <String>] [[-LogFileName] <String>] [[-LogRotationDays] <Int32>] [-Force]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The Remove-RefreshDBPoolLog cmdlet removes log files older than a specified number of days.

By default, log files are stored in the following location and will be removed:
    $env:USERPROFILE\RefreshDBPool\Logs

## EXAMPLES

### EXAMPLE 1

```PowerShell
Remove-RefreshDBPoolLog
Remove log files older than 90 days.
```

### EXAMPLE 2

```PowerShell
Remove-RefreshDBPoolLog -LogPath C:\RefreshDBPool\Logs -LogFileName "RefreshDBPool_*.log" -LogRotationDays 7 -Force
Remove log files older than 7 days from the specified location.
```

## PARAMETERS

### -LogPath

Define the location of the log files.

By default, log files are stored in the following location:
    $env:USERPROFILE\RefreshDBPool\Logs

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $RefreshDBPool_LogPath
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogFileName

Define the name of the log files.

By default, log files are named:
    RefreshDBPool_*.log

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $RefreshDBPool_LogFileName
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogRotationDays

Define the number of days to keep log files.
By default, log files older than 90 days will be removed.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: $RefreshDBPool_LogRotationDays
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

If specified, the function will not prompt for confirmation before removing the log files.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
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

N/A

## RELATED LINKS

[https://datto-dbpool-refresh.kentsapp.com/Internal/logging/Remove-RefreshDBPoolLog/](https://datto-dbpool-refresh.kentsapp.com/Internal/logging/Remove-RefreshDBPoolLog/)
