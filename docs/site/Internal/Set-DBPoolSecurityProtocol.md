---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version:
schema: 2.0.0
---

# Set-DBPoolSecurityProtocol

## SYNOPSIS

The Set-DBPoolSecurityProtocol function is used to set the Security Protocol in the current context.

## SYNTAX

```PowerShell
Set-DBPoolSecurityProtocol [[-Protocol] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Sets the Security Protocol for a .NET application to use TLS 1.2 by default.
This function is useful for ensuring secure communication in .NET applications.

## EXAMPLES

### EXAMPLE 1

```PowerShell
Set-DBPoolSecurityProtocol -Protocol Tls12
```

Sets the Security Protocol to use TLS 1.2.

## PARAMETERS

### -Protocol

The security protocol to use.
Can be set to 'Ssl3', 'SystemDefault', 'Tls', 'Tls11', 'Tls12', and 'Tls13'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Tls12
Accept pipeline input: True (ByPropertyName, ByValue)
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

### [string] - The security protocol to use

## OUTPUTS

### N/A

## NOTES

Make sure to run this function in the appropriate context, as it affects .NET-wide security settings.

## RELATED LINKS

[https://datto-dbpool-refresh.kentsapp.com/Internal/Set-DBPoolSecurityProtocol/](https://datto-dbpool-refresh.kentsapp.com/Internal/Set-DBPoolSecurityProtocol/)
