function Remove-RefreshDBPoolModuleSetting {
<#
    .SYNOPSIS
        Removes the stored Refresh DBPool configuration folder.

    .DESCRIPTION
        The Remove-RefreshDBPoolModuleSetting cmdlet removes the Refresh DBPool folder and its files.
        This cmdlet also has the option to remove sensitive Refresh DBPool variables as well.

        By default configuration files are stored in the following location and will be removed:
            $env:USERPROFILE\RefreshDBPool

    .PARAMETER RefreshDBPoolConfPath
        Define the location of the Refresh DBPool configuration folder.

        By default the configuration folder is located at:
            $env:USERPROFILE\RefreshDBPool

    .PARAMETER andVariables
        Define if sensitive Refresh DBPool variables should be removed as well.

        By default the variables are not removed.

    .EXAMPLE
        Remove-RefreshDBPoolModuleSetting

        Checks to see if the default configuration folder exists and removes it if it does.

        The default location of the Refresh DBPool configuration folder is:
            $env:USERPROFILE\RefreshDBPool

    .EXAMPLE
        Remove-RefreshDBPoolModuleSetting -RefreshDBPoolConfPath C:\RefreshDBPool -andVariables

        Checks to see if the defined configuration folder exists and removes it if it does.
        If sensitive Refresh DBPool variables exist then they are removed as well.

        The location of the Refresh DBPool configuration folder in this example is:
            C:\RefreshDBPool

    .INPUTS
        N/A

    .OUTPUTS
        N/A

    .NOTES
        N/A

    .LINK
        N/A
#>

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'set')]
    Param (
        [Parameter(ParameterSetName = 'set')]
        [string]$RefreshDBPoolConfPath = $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop'){"RefreshDBPool"}else{".RefreshDBPool"}) ),

        [Parameter(ParameterSetName = 'set')]
        [switch]$andVariables
    )

    begin {

        # Pass the InformationAction parameter if bound, default to 'Continue'
        if ($PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSBoundParameters['InformationAction'] } else { $InformationPreference = 'Continue' }

    }

    process {

        if (Test-Path $RefreshDBPoolConfPath) {

            Remove-Item -Path $RefreshDBPoolConfPath -Recurse -Force -WhatIf:$WhatIfPreference

            If ($andVariables) {
                Remove-RefreshDBPoolAPIKey -Force -Confirm:$ConfirmPreference -WhatIf:$WhatIfPreference
                Remove-DBPoolBaseURI
            }

            if (!(Test-Path $RefreshDBPoolConfPath)) {
                Write-Information "The RefreshDBPool configuration folder has been removed successfully from [ $RefreshDBPoolConfPath ]"
            }
            else {
                Write-Error "The RefreshDBPool configuration folder could not be removed from [ $RefreshDBPoolConfPath ]"
            }

        }
        else {
            Write-Warning "No configuration folder found at [ $RefreshDBPoolConfPath ]"
        }

    }

    end {}

}
