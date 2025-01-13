<#

    .SYNOPSIS
    A PowerShell module that connects to the Datto DBPool API to refresh containers.

    .DESCRIPTION
    This module is used to refresh all child containers in Datto (Kaseya) DBPool, by default all containers will be refreshed.
    Several parameters can be set with the use of an environment override file to specify the container IDs to refresh, and more.

    .COPYRIGHT
    Copyright (c) Kent Sapp. All rights reserved. Licensed under the MIT license.
    See https://github.com/cksapp/Datto.DBPool.Refresh/blob/main/LICENSE for license information.

#>

# Root Module Parameters
# This section is used to dot source all the module functions for development
if (Test-Path -Path $(Join-Path -Path $PSScriptRoot -ChildPath 'Public')) {
    # Directories to import from
    $directory = 'Public', 'Private'

    # Import functions
    $functionsToExport = @()
    $aliasesToExport = @()

    foreach ($dir in $directory) {
        $Functions = @( Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "$dir") -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue)
        foreach ($Import in @($Functions)) {
            try {
                . $Import.fullname
                $functionsToExport += $Import.BaseName
            } catch {
                throw "Could not import function [$($Import.fullname)]: $_"
                continue
            }
        }
    }

    if ($functionsToExport.Count -gt 0) {
        Export-ModuleMember -Function $functionsToExport
    }

    foreach ($alias in Get-Alias) {
        if ($functionsToExport -contains $alias.Definition) {
            $aliasesToExport += $alias.Name
        }
    }
    if ($aliasesToExport.Count -gt 0) {
        Export-ModuleMember -Alias $aliasesToExport
    }

}
