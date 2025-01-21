---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version:
schema: 2.0.0
---

# Update-RefreshDBPoolTask

## SYNOPSIS

Updates the refresh DBPool scheduled task.

## SYNTAX

```PowerShell
Update-RefreshDBPoolTask [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This function updates the scheduled task that runs the refresh DBPool script by updating path and arguments.

## EXAMPLES

### EXAMPLE 1

```PowerShell
Update-RefreshDBPoolTask
```

This example updates the scheduled task that runs the refresh DBPool script.

## PARAMETERS

### -Force

Forces the update of the scheduled task.

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

This function is currently only supported on Windows systems.

## RELATED LINKS

[https://datto-dbpool-refresh.kentsapp.com/Internal/scheduledTask/Update-RefreshDBPoolTask/](https://datto-dbpool-refresh.kentsapp.com/Internal/scheduledTask/Update-RefreshDBPoolTask/)
