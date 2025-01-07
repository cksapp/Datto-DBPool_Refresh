function Copy-DBPoolParentContainer {
    [CmdletBinding(DefaultParameterSetName = 'byId')]
    [Alias('Clone-DBPoolParentContainer')]
    param (
        [Parameter(ParameterSetName = 'byId')]
        [int[]]$Id = @(17, 27, 14),

        [Parameter(ParameterSetName = 'byDefaultDatabase')]
        [string[]]$DefaultDatabase = @('dattoAuth', 'dattoSystem', 'legoCloud'),

        [Parameter()]
        [string]$ContainerName_Append = 'clone',

        [Parameter(DontShow = $true)]
        [int]$LegoCloudCloneCount = 2,

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
            'ById' {
                $myContainers = Get-DBPoolContainer
                # Filter containers based on Id and exclude those with 'BETA' in the name
                $filteredParentContainer = $parentContainer | Where-Object {
                    $_.Id -in $Id -and $_.Name -notmatch 'BETA'
                }
            }

            'ByDefaultDatabase' {
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
            # Extract the first part of the container name before 'on'
            $baseContainerName = $parent.Name -split ' on ' | Select-Object -First 1

            Write-Verbose "Checking DBPool for any container matching Parent: $($parent | Select-Object -Property 'id','name','defaultDatabase')"
            # Check if similar container already exists based on the parent container
            $existingContainer = $myContainers | Where-Object { $_.parent -match $parent }

            if ($existingContainer -and -not $Duplicate) {
                $existingContainerInfo = ($existingContainer | ForEach-Object { "Id: $($_.Id), Name: $($_.Name)" }) -join '; '
                Write-Warning "Container with parent [ $($parent | Select-Object -Property 'id','name','defaultDatabase') ] already exists for container(s) [ $existingContainerInfo ] - Skipping clone."
                Write-Debug "Use '-Duplicate' switch to force clone of existing containers."
                continue
            }


            if ($parent.defaultDatabase -eq 'legoCloud') {
                for ($i = 1; $i -le $LegoCloudCloneCount; $i++) {
                    try {
                        $newContainerName = "$baseContainerName($ContainerName_Append-$i)"
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
            } else {
                try {
                    $newContainerName = "$baseContainerName($ContainerName_Append)"
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
