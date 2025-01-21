---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version:
schema: 2.0.0
---

# Sync-DBPoolContainer

## SYNOPSIS

Refreshes the specified DBPool container(s) using the DBPool API.
By default, this function will refresh all containers if no IDs are provided.

## SYNTAX

```PowerShell
Sync-DBPoolContainer [[-Id] <Int32[]>] [-TimeoutSeconds <Int32>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

This function refreshes the specified DBPool container(s) using the DBPool API.
By default, this function will refresh all containers if no IDs are provided.

## EXAMPLES

### EXAMPLE 1

```PowerShell
Sync-DBPoolContainer
```

Refreshes all DBPool containers.

### EXAMPLE 2

```PowerShell
Sync-DBPoolContainer -Id 1234
```

Refreshes the DBPool container with the ID 1234.

### EXAMPLE 3

```PowerShell
Sync-DBPoolContainer -Id 1234, 5678
```

Refreshes the DBPool containers with the IDs 1234 and 5678.

### EXAMPLE 4

```PowerShell
Sync-DBPoolContainer -Id $(Get-DBPoolContainer -DefaultDatabase "Database_Name").Id
```

Refreshes all DBPool containers matching the specified database name.

### EXAMPLE 5

```PowerShell
Sync-DBPoolContainer -Id $(Get-DBPoolContainer -NotLike -Name "*Container_Name*").Id -Force
```

Refreshes all DBPool containers not matching the specified container name.

## PARAMETERS

### -Id

The ID(s) of the container(s) to refresh.
If no IDs are provided, all containers will be refreshed.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases: ContainerId

Required: False
Position: 1
Default value: $RefreshDBPool_Container_Ids
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -TimeoutSeconds

The maximum time in seconds to wait for the container(s) to refresh.
The default value is 3600 seconds (1 hour).

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $RefreshDBPool_TimeoutSeconds
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

If specified, the function will not prompt for confirmation before refreshing the container(s).

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

### [int] - Array of ID(s) of the container(s) to perform the refresh action on

## OUTPUTS

### [void] - No output is returned

## NOTES

N/A

## RELATED LINKS

[https://datto-dbpool-refresh.kentsapp.com/Sync-DBPoolContainer/](https://datto-dbpool-refresh.kentsapp.com/Sync-DBPoolContainer/)
