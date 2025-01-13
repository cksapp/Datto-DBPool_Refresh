---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version:
schema: 2.0.0
---

# Set-RefreshDBPoolApiKey

## SYNOPSIS
This function adds the DBPool API key to the default PowerShell SecretManagement vault.

## SYNTAX

```
Set-RefreshDBPoolApiKey [-SecretName <String>] [-DBPool_ApiKey] <SecureString> [-SecretStoreName <String>]
 [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function securely stores the DBPool API key in the specified SecretManagement vault.
It can be used to add or update the API key for later use in scripts and automation tasks.
If the secret already exists, the function can overwrite it if the -Force switch is used.

## EXAMPLES

### EXAMPLE 1
```
Set-RefreshDBPoolApiKey -DBPool_ApiKey $secureApiKey -Verbose
```

Adds the DBPool API key to the default SecretManagement vault with the name 'DBPool_ApiKey'.

### EXAMPLE 2
```
Set-RefreshDBPoolApiKey -DBPool_ApiKey $secureApiKey -SecretName 'Custom_ApiKey' -SecretStoreName 'MySecretStore' -Force
```

Adds the DBPool API key to the 'MySecretStore' SecretManagement vault with the name 'Custom_ApiKey'.
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
Position: Named
Default value: DBPool_ApiKey
Accept pipeline input: False
Accept wildcard characters: False
```

### -DBPool_ApiKey
The secure string containing the DBPool API key.
This parameter is mandatory.
DBPool API key can be retrieved from the web interface at "$DBPool_Base_URI/web/self".

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -SecretStoreName
The name of the SecretManagement vault where the secret will be stored.
Default value is 'Datto_SecretStore'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Datto_SecretStore
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

### [securestring] - The secure string containing the DBPool API key.
## OUTPUTS

### N/A
## NOTES
Ensure that the PowerShell SecretManagement module is installed and configured before using this function.

## RELATED LINKS

[N/A]()

