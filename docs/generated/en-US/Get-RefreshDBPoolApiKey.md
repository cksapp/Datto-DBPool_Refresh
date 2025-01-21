---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version: https://datto-dbpool-refresh.kentsapp.com/Internal/apiKey/Get-RefreshDBPoolApiKey/
schema: 2.0.0
---

# Get-RefreshDBPoolApiKey

## SYNOPSIS
This function gets the DBPool API key from the default PowerShell SecretManagement vault and sets the global variable.

## SYNTAX

```
Get-RefreshDBPoolApiKey [[-SecretName] <String>] [[-SecretStoreName] <String>] [-AsPlainText] [-Force]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function gets the DBPool API key from the default PowerShell SecretManagement vault and sets the global variable.
If the global variable is already set, confirm with the user before overwriting the value or set the value without confirmation using the -Force switch.

## EXAMPLES

### EXAMPLE 1
```
Get-RefreshDBPoolApiKey
```

Retrieves the DBPool API key from the default SecretManagement vault with the default name 'DBPool_ApiKey' as a secure string.

### EXAMPLE 2
```
Get-RefreshDBPoolApiKey -AsPlainText
```

Retrieves the DBPool API key from the default SecretManagement vault with the default name 'DBPool_ApiKey' as a plaintext string.

### EXAMPLE 3
```
Get-RefreshDBPoolApiKey -SecretName 'Different_SecretName' -SecretStoreName 'Custom_SecretsVault' -Force
```

Retrieves the DBPool API key and adds it to the 'Custom_SecretsVault' SecretManagement vault with the name 'Different_SecretName'.
If the secret already exists, it will be overwritten.

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
The name of the SecretManagement vault where the secret will be stored.
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

### -AsPlainText
If specified, the function will return the API key as a plaintext string.

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

### -Force
If specified, forces the function to overwrite the existing secret if it already exists in the vault.

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

### [securestring] - The DBPool API key as a secure string.
### [string] - The DBPool API key as a plaintext string.
## NOTES
This function is designed to work with the default SecretManagement vault.
Ensure the vault is installed and configured before using this function.

## RELATED LINKS

[https://datto-dbpool-refresh.kentsapp.com/Internal/apiKey/Get-RefreshDBPoolApiKey/](https://datto-dbpool-refresh.kentsapp.com/Internal/apiKey/Get-RefreshDBPoolApiKey/)

