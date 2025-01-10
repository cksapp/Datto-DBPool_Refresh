---
external help file: Datto.DBPool.Refresh-help.xml
Module Name: Datto.DBPool.Refresh
online version:
schema: 2.0.0
---

# Copy-DBPoolParentContainer

## SYNOPSIS
Clones the specified DBPool parent container(s) using the DBPool API.

## SYNTAX

### byId (Default)
```
Copy-DBPoolParentContainer -Id <Int32[]> [-ContainerName_Append <String>] [-Duplicate] [<CommonParameters>]
```

### byDefaultDatabase
```
Copy-DBPoolParentContainer -DefaultDatabase <String[]> [-ContainerName_Append <String>] [-Duplicate]
 [<CommonParameters>]
```

## DESCRIPTION
This function clones the specified DBPool parent container(s) using the DBPool API.
By default, this function will clone all containers if no IDs or DefaultDatabase values are provided.

## EXAMPLES

### EXAMPLE 1
```
Copy-DBPoolParentContainer -Id 1234
```

Clones the DBPool parent container with the ID 1234.

### EXAMPLE 2
```
Copy-DBPoolParentContainer -DefaultDatabase 'exampleParentA'
```

Clones the DBPool parent container with the DefaultDatabase 'exampleParentA'.

### EXAMPLE 3
```
Copy-DBPoolParentContainer -Id 1234, 5678 -ContainerName_Append 'copy'
```

Clones the DBPool parent containers with the IDs 1234 and 5678 and appends 'copy' to the cloned container name.

### EXAMPLE 4
```
Copy-DBPoolParentContainer -DefaultDatabase 'exampleParentA', 'exampleParentB' -Duplicate
```

Clones the DBPool parent containers with the DefaultDatabase 'exampleParentA' and 'exampleParentB' even if similar containers already exist.

## PARAMETERS

### -Id
The ID(s) of the parent container(s) to clone.

```yaml
Type: Int32[]
Parameter Sets: byId
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DefaultDatabase
The DefaultDatabase(s) of the parent container(s) to clone.

```yaml
Type: String[]
Parameter Sets: byDefaultDatabase
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ContainerName_Append
The string to append to the cloned container name.
The default value is 'clone'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Clone
Accept pipeline input: False
Accept wildcard characters: False
```

### -Duplicate
If specified, the function will clone the parent container(s) even if a similar container already exists.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [int] - Array of ID(s) of the parent container(s) to clone.
### [string] - Array of DefaultDatabase(s) of the parent container(s) to clone.
## OUTPUTS

### [PSCustomObject] - Object containing the cloned container(s) information.
## NOTES
N/A

## RELATED LINKS

[N/A]()

