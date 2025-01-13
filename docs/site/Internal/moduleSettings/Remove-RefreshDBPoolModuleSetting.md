---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version:
schema: 2.0.0
---

# Remove-RefreshDBPoolModuleSetting

## SYNOPSIS

Removes the stored Refresh DBPool configuration folder.

## SYNTAX

```PowerShell
Remove-RefreshDBPoolModuleSetting [-RefreshDBPoolConfPath <String>] [-andVariables] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

The Remove-RefreshDBPoolModuleSetting cmdlet removes the Refresh DBPool folder and its files.
This cmdlet also has the option to remove sensitive Refresh DBPool variables as well.

By default configuration files are stored in the following location and will be removed:
    $env:USERPROFILE\RefreshDBPool

## EXAMPLES

### EXAMPLE 1

```PowerShell
Remove-RefreshDBPoolModuleSetting
```

Checks to see if the default configuration folder exists and removes it if it does.

The default location of the Refresh DBPool configuration folder is:
    $env:USERPROFILE\RefreshDBPool

### EXAMPLE 2

```PowerShell
Remove-RefreshDBPoolModuleSetting -RefreshDBPoolConfPath C:\RefreshDBPool -andVariables
```

Checks to see if the defined configuration folder exists and removes it if it does.
If sensitive Refresh DBPool variables exist then they are removed as well.

The location of the Refresh DBPool configuration folder in this example is:
    C:\RefreshDBPool

## PARAMETERS

### -RefreshDBPoolConfPath

Define the location of the Refresh DBPool configuration folder.

By default the configuration folder is located at:
    $env:USERPROFILE\RefreshDBPool

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop'){"RefreshDBPool"}else{".RefreshDBPool"}) )
Accept pipeline input: False
Accept wildcard characters: False
```

### -andVariables

Define if sensitive Refresh DBPool variables should be removed as well.

By default the variables are not removed.

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

[N/A]()
