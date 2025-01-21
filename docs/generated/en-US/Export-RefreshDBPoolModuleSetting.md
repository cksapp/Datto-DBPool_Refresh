---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version: https://datto-dbpool-refresh.kentsapp.com/Internal/moduleSettings/Export-RefreshDBPoolModuleSetting/
schema: 2.0.0
---

# Export-RefreshDBPoolModuleSetting

## SYNOPSIS
Exports various module settings to a configuration file.

## SYNTAX

```
Export-RefreshDBPoolModuleSetting [-RefreshDBPoolConfPath <String>] [-RefreshDBPoolConfFile <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Export-RefreshDBPoolSettings cmdlet exports various module settings to a configuration file which can be used to override default settings.

## EXAMPLES

### EXAMPLE 1
```
Export-RefreshDBPoolSettings
```

Validates that the BaseURI, and JSON depth are set then exports their values
to the current user's DBPool configuration file located at:
    $env:USERPROFILE\RefreshDBPool\config.psd1

### EXAMPLE 2
```
Export-RefreshDBPoolSettings -DBPoolConfPath C:\RefreshDBPool -DBPoolConfFile MyConfig.psd1
```

Validates that the BaseURI, and JSON depth are set then exports their values
to the current user's DBPool configuration file located at:
    C:\RefreshDBPool\MyConfig.psd1

## PARAMETERS

### -RefreshDBPoolConfPath
Define the location to store the Refresh DBPool configuration file.

By default the configuration file is stored in the following location:
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

### -RefreshDBPoolConfFile
Define the name of the refresh DBPool configuration file.

By default the configuration file is named:
    config.psd1

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Config.psd1
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

[https://datto-dbpool-refresh.kentsapp.com/Internal/moduleSettings/Export-RefreshDBPoolModuleSetting/](https://datto-dbpool-refresh.kentsapp.com/Internal/moduleSettings/Export-RefreshDBPoolModuleSetting/)

