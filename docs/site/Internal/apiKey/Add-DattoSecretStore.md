---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version:
schema: 2.0.0
---

# Add-DattoSecretStore

## SYNOPSIS

Adds a local secret store using the Microsoft.PowerShell.SecretStore module.

## SYNTAX

```PowerShell
Add-DattoSecretStore [[-Name] <String>] [[-ModuleName] <String>] [<CommonParameters>]
```

## DESCRIPTION

This function adds a local secret store using the Microsoft.PowerShell.SecretStore module.
Checks if the secret store is installed and install if not found.
The function also sets the secret store configuration for the default vault.

## EXAMPLES

### EXAMPLE 1

```PowerShell
Add-DattoSecretStore
```

Adds a local secret store named 'Datto_SecretStore' using the Microsoft.PowerShell.SecretStore module.

### EXAMPLE 2

```PowerShell
Add-DattoSecretStore -Name 'Custom_SecretsVault' -ModuleName 'Custom.SecretStore'
```

Adds a local secret store named 'Custom_SecretsVault' using the 'Custom.SecretStore' module.

## PARAMETERS

### -Name

The name of the secret store to add.
Defaults to 'Datto_SecretStore'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Datto_SecretStore
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleName

The name of the module to use for the secret store.
Defaults to 'Microsoft.PowerShell.SecretStore'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Microsoft.PowerShell.SecretStore
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
