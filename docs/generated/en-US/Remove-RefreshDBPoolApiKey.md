---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version: https://datto-dbpool-refresh.kentsapp.com/Internal/apiKey/Remove-RefreshDBPoolApiKey/
schema: 2.0.0
---

# Remove-RefreshDBPoolApiKey

## SYNOPSIS
This function removes the DBPool API key to the default PowerShell SecretManagement vault.

## SYNTAX

```
Remove-RefreshDBPoolApiKey [[-SecretName] <String>] [[-SecretStoreName] <String>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This function removes the DBPool API key from the specified SecretManagement vault.

## EXAMPLES

### EXAMPLE 1
```
Remove-RefreshDBPoolApiKey
```

Removes the API key from the SecretManagement vault.

### EXAMPLE 2
```
Remove-RefreshDBPoolApiKey -SecretName 'Different_SecretName' -SecretStoreName 'Custom_SecretsVault' -Force
```

Removes the API key from the 'Custom_SecretsVault' SecretManagement vault with the name 'Different_SecretName'.

## PARAMETERS

### -SecretName
The name to use for the secret in the SecretManagement vault.
Defaults to 'DBPool_ApiKey'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: DBPool_ApiKey
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecretStoreName
The name of the SecretManagement vault where the secret is stored.
Defaults to the value of the environment variable 'Datto_SecretStore'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Datto_SecretStore
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
If specified, forces the function to remove the secret from the vault.

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

[https://datto-dbpool-refresh.kentsapp.com/Internal/apiKey/Remove-RefreshDBPoolApiKey/](https://datto-dbpool-refresh.kentsapp.com/Internal/apiKey/Remove-RefreshDBPoolApiKey/)

