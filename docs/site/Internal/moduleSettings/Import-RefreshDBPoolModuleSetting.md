---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version:
schema: 2.0.0
---

# Import-RefreshDBPoolModuleSetting

## SYNOPSIS

Imports the DBPool BaseURI, API, & JSON configuration information to the current session.

## SYNTAX

```PowerShell
Import-RefreshDBPoolModuleSetting [-RefreshDBPoolConfPath <String>] [-RefreshDBPoolConfFile <String>]
 [<CommonParameters>]
```

## DESCRIPTION

The Import-RefreshDBPoolModuleSetting cmdlet imports the DBPool BaseURI, API, & JSON configuration
information stored in the DBPool refresh configuration file to the users current session.

By default the configuration file is stored in the following location:
    $env:USERPROFILE\RefreshDBPool

## EXAMPLES

### EXAMPLE 1

```PowerShell
Import-RefreshDBPoolModuleSetting
```

Validates that the configuration file created with the Export-RefreshDBPoolModuleSettings cmdlet exists
then imports the stored data into the current users session.

The default location of the DBPool configuration file is:
    $env:USERPROFILE\RefreshDBPool\config.psd1

### EXAMPLE 2

```PowerShell
Import-RefreshDBPoolModuleSetting -RefreshDBPoolConfPath C:\RefreshDBPool -RefreshDBPoolConfFile MyConfig.psd1
```

Validates that the configuration file created with the Export-RefreshDBPoolModuleSettings cmdlet exists
then imports the stored data into the current users session.

The location of the DBPool configuration file in this example is:
    C:\RefreshDBPool\MyConfig.psd1

## PARAMETERS

### -RefreshDBPoolConfPath

Define the location to store the DBPool configuration file.

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

Define the name of the DBPool configuration file.

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

[N/A]()
