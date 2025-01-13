---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version:
schema: 2.0.0
---

# Get-RefreshDBPoolModuleSetting

## SYNOPSIS

Gets the saved DBPool configuration settings

## SYNTAX

### index (Default)

```PowerShell
Get-RefreshDBPoolModuleSetting [-RefreshDBPoolConfPath <String>] [-RefreshDBPoolConfFile <String>]
 [<CommonParameters>]
```

### show

```PowerShell
Get-RefreshDBPoolModuleSetting [-openConfFile] [<CommonParameters>]
```

## DESCRIPTION

The Get-RefreshDBPoolModuleSetting cmdlet gets the saved DBPool refresh configuration settings
from the local system.

By default the configuration file is stored in the following location:
    $env:USERPROFILE\RefreshDBPool

## EXAMPLES

### EXAMPLE 1

```PowerShell
Get-RefreshDBPoolModuleSetting
```

Gets the contents of the configuration file that was created with the
Export-RefreshDBPoolModuleSettings

The default location of the DBPool configuration file is:
    $env:USERPROFILE\RefreshDBPool\config.psd1

### EXAMPLE 2

```PowerShell
Get-RefreshDBPoolModuleSetting -RefreshDBPoolConfig C:\RefreshDBPool -DBPoolConfFile MyConfig.psd1 -openConfFile
```

Opens the configuration file from the defined location in the default editor

The location of the DBPool configuration file in this example is:
    C:\RefreshDBPool\MyConfig.psd1

## PARAMETERS

### -RefreshDBPoolConfPath

Define the location to store the DBPool configuration file.

By default the configuration file is stored in the following location:
    $env:USERPROFILE\RefreshDBPool

```yaml
Type: String
Parameter Sets: index
Aliases:

Required: False
Position: Named
Default value: $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop'){"RefreshDBPool"}else{".RefreshDBPool"}) )
Accept pipeline input: False
Accept wildcard characters: False
```

### -RefreshDBPoolConfFile

Define the name of the DBPool configuration file.

By default the configuration file is named:
    config.psd1

```yaml
Type: String
Parameter Sets: index
Aliases:

Required: False
Position: Named
Default value: Config.psd1
Accept pipeline input: False
Accept wildcard characters: False
```

### -openConfFile

Opens the DBPool configuration file

```yaml
Type: SwitchParameter
Parameter Sets: show
Aliases:

Required: False
Position: Named
Default value: False
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
