---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version:
schema: 2.0.0
---

# Update-RefreshDBPoolModule

## SYNOPSIS
Updates the Datto.DBPool.Refresh module if a newer version is available online.

## SYNTAX

```
Update-RefreshDBPoolModule [[-ModuleName] <String>] [-AutoUpdate] [-AllowPrerelease] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This function checks for updates to the Datto.DBPool.Refresh module and updates it if a newer version is available online.
The auto-update feature can be disabled by setting the AutoUpdate parameter to $false otherwise, it will default to $true.

## EXAMPLES

### EXAMPLE 1
```
Update-RefreshDBPoolModule -ModuleName 'Datto.DBPool.Refresh' -AutoUpdate:$true -AllowPrerelease:$false
```

Updates the Datto.DBPool.Refresh module if a newer version is available online.

## PARAMETERS

### -ModuleName
The name of the module to update.
Defaults to 'Datto.DBPool.Refresh'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Datto.DBPool.Refresh
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -AutoUpdate
If specified, the module will be updated if a newer version is available online.
Defaults to $RefreshDBPool_Enable_AutoUpdate variable.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $RefreshDBPool_Enable_AutoUpdate
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowPrerelease
If specified, the module will be updated to the latest prerelease version if available.
Defaults to $false.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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

### [string] - ModuleName
## OUTPUTS

### N/A
## NOTES
N/A

## RELATED LINKS

[N/A]()

