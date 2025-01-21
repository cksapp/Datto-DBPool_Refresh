function Copy-DBPoolParentContainer {
<#
    .SYNOPSIS
        Clones the specified DBPool parent container(s) using the DBPool API.

    .DESCRIPTION
        This function clones the specified DBPool parent container(s) using the DBPool API. The cloned container(s) will have the same parent container as the original container(s) and will be appended with the specified string.

    .PARAMETER Id
        The ID(s) of the parent container(s) to clone.

    .PARAMETER DefaultDatabase
        The DefaultDatabase(s) of the parent container(s) to clone.

    .PARAMETER ContainerName_Append
        The string to append to the cloned container name. The default value is 'clone'.

    .PARAMETER Duplicate
        If specified, the function will clone the parent container(s) even if a similar container already exists.

    .INPUTS
        [int] - Array of ID(s) of the parent container(s) to clone.
        [string] - Array of DefaultDatabase(s) of the parent container(s) to clone.

    .OUTPUTS
        [PSCustomObject] - Object containing the cloned container(s) information.

    .EXAMPLE
        Copy-DBPoolParentContainer -Id 1234

        Clones the DBPool parent container with the ID 1234.

    .EXAMPLE
        Copy-DBPoolParentContainer -DefaultDatabase 'exampleParentA'

        Clones the DBPool parent container with the DefaultDatabase 'exampleParentA'.

    .EXAMPLE
        Copy-DBPoolParentContainer -Id 1234, 5678 -ContainerName_Append 'copy'

        Clones the DBPool parent containers with the IDs 1234 and 5678 and appends 'copy' to the cloned container name.

    .EXAMPLE
        Copy-DBPoolParentContainer -DefaultDatabase 'exampleParentA', 'exampleParentB' -Duplicate

        Clones the DBPool parent containers with the DefaultDatabase 'exampleParentA' and 'exampleParentB' even if similar containers already exist.

    .EXAMPLE
        Copy-DBPoolParentContainer -DefaultDatabase 'exampleParentA', 'exampleParentB', 'exampleParentA

        Clones the DBPool parent containers with the DefaultDatabase 'exampleParentA' and 'exampleParentB' and appends a number to any duplicate clones.

        ------------------------------
        Parent Container [ Id: 7, Name: exampleParentB staging ] 'create' command sent for new Container [ exampleB staging(clone) ]
        Parent Container [ Id: 3, Name: exampleParentA on SQL 1.2.3 ] 'create' command sent for new Container [ exampleA(clone-1) ]
        Parent Container [ Id: 3, Name: exampleParentA on SQL 1.2.3 ] 'create' command sent for new Container [ exampleA(clone-2) ]
        Parent Container [ Id: 4, Name: exampleParentB on 4.5.6 ] 'create' command sent for new Container [ exampleB(clone) ]

    .NOTES
        Does not clone any parent containers with 'BETA' in the name. Also removes parent name suffixes like 'on Database v1.2.3' before appending the ContainerName_Append string.
        This function will also append a number to the cloned container name if multiple matching clones are created with same parent at once, or for any matching clones that already exist when using the -Duplicate switch.

    .LINK
        https://datto-dbpool-refresh.kentsapp.com/Copy-DBPoolParentContainer/
#>
    [CmdletBinding(DefaultParameterSetName = 'byId')]
    [Alias('Clone-DBPoolParentContainer')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'byId')]
        [int[]]$Id,

        [Parameter(Mandatory = $true, ParameterSetName = 'byDefaultDatabase')]
        [string[]]$DefaultDatabase,

        [Parameter()]
        [string]$ContainerName_Append = 'clone',

        [switch]$Duplicate
    )

    begin {

        # Pass the InformationAction parameter if bound, default to 'Continue'
        if ($PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSBoundParameters['InformationAction'] } else { $InformationPreference = 'Continue' }

        if (-not $DBPool_ApiKey) {
            Write-Warning "DBPool_ApiKey is not set. Please run 'Get-RefreshDBPoolAPIKey' to set the API key."
            return
        }

    }

    process {

        # Retrieve current parent containers
        $parentContainer = Get-DBPoolContainer -ParentContainer

        switch ($PSCmdlet.ParameterSetName) {
            'byId' {
                $myContainers = Get-DBPoolContainer
                # Filter containers based on Id and exclude those with 'BETA' in the name
                $filteredParentContainer = $parentContainer | Where-Object {
                    $_.Id -in $Id -and $_.Name -notmatch 'BETA'
                }
            }

            'byDefaultDatabase' {
                $myContainers = Get-DBPoolContainer -DefaultDatabase $DefaultDatabase
                # Filter containers based on DefaultDatabase and exclude those with 'BETA' in the name
                $filteredParentContainer = $parentContainer | Where-Object {
                    $_.defaultDatabase -in $DefaultDatabase -and $_.Name -notmatch 'BETA'
                }
            }
        }
        if ($filteredParentContainer.Count -eq 0) {
            Write-Error 'No parent container found to clone.'
            return
        }

        # Create clones of the matched containers
        $maxRunspaces = [Math]::Min($filteredParentContainer.Count, ([Environment]::ProcessorCount * 2))
        $runspacePool = [runspacefactory]::CreateRunspacePool(1, $maxRunspaces)
        $runspacePool.Open()
        $runspaces = New-Object System.Collections.ArrayList
        foreach ($parent in $filteredParentContainer) {
            # Extract the first part of the container name before 'on'; i.e. 'Parent Container Name on Database v1.2.3'
            $baseContainerName = $parent.Name -split ' on ' | Select-Object -First 1

            Write-Verbose "Checking DBPool for any container matching Parent: $($parent | Select-Object -Property 'id','name','defaultDatabase')"
            # Check if similar container already exists based on the parent container
            $existingContainerClone = $myContainers | Where-Object { $_.parent -match $parent }

            if ($existingContainerClone -and -not $Duplicate) {
                $existingContainerCloneInfo = ($existingContainerClone | ForEach-Object { "Id: $($_.Id), Name: $($_.Name)" }) -join '; '
                Write-Warning "Container with parent [ $($parent | Select-Object -Property 'id','name','defaultDatabase') ] already exists for container(s) [ $existingContainerCloneInfo ] - Skipping clone."
                Write-Debug "Use '-Duplicate' switch to force clone of existing containers."
                continue
            }

            # Determine the starting index for the clone name
            $existingCloneCount = ($existingContainerClone | Measure-Object).Count + 1

            # Clone the parent container as many times as it appears in the Id or DefaultDatabase parameter
            $cloneCount = switch ($PSCmdlet.ParameterSetName) {
                'byId' { ($Id | Where-Object { $_ -eq $parent.Id }).Count }
                'byDefaultDatabase' { ($DefaultDatabase | Where-Object { $_ -eq $parent.defaultDatabase }).Count }
            }

            for ($i = 0; $i -lt $cloneCount; $i++) {
                try {
                    if ($existingCloneCount + $i -eq 1 -and $cloneCount -eq 1) {
                        $newContainerName = "$baseContainerName($ContainerName_Append)"
                    } else {
                        $newContainerName = "$baseContainerName($ContainerName_Append-$($existingCloneCount + $i))"
                    }
                    $runspace = [powershell]::Create().AddScript({
                            param ($containerName, $parentId, $apiKey)
                            try {
                                Import-Module 'Datto.DBPool.API'
                                Add-DBPoolApiKey -apiKey $apiKey
                                New-DBPoolContainer -ParentId $parentId -ContainerName $containerName -Force
                            } catch {
                                Write-Error "Error in runspace execution: $_"
                            }
                        }).AddArgument($newContainerName).AddArgument($parent.Id).AddArgument($DBPool_ApiKey)

                    $runspace.RunspacePool = $runspacePool
                    $runspaces.Add(@{Runspace = $runspace; Handle = $runspace.BeginInvoke(); ContainerName = $newContainerName }) | Out-Null
                    Write-Information "Parent Container [ Id: $($parent.Id), Name: $($parent.Name) ] 'create' command sent for new Container [ $newContainerName ]"
                } catch {
                    Write-Error "Error sending 'create' command for new Container [ $newContainerName ]: $_"
                }
            }
            Start-Sleep -Milliseconds 500

        }

        while ($runspaces.Count -gt 0) {
            for ($i = 0; $i -lt $runspaces.Count; $i++) {
                $runspace = $runspaces[$i].Runspace
                $handle = $runspaces[$i].Handle
                if ($handle.IsCompleted) {
                    Write-Information "Success: Created DBPool container [ $($runspaces[$i].ContainerName) ]"
                    $runspace.EndInvoke($handle)
                    $runspace.Dispose()
                    $runspaces.RemoveAt($i)
                    $i--
                }
            }
            Start-Sleep -Milliseconds 500
        }

    }

    end {

        $runspacePool.Close()
        $runspacePool.Dispose()

    }

}
