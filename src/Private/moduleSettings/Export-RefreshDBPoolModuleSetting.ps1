function Export-RefreshDBPoolModuleSetting {
<#
    .SYNOPSIS
        Exports various module settings to a configuration file.

    .DESCRIPTION
        The Export-RefreshDBPoolSettings cmdlet exports various module settings to a configuration file which can be used to override default settings.

    .PARAMETER RefreshDBPoolConfPath
        Define the location to store the Refresh DBPool configuration file.

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\RefreshDBPool

    .PARAMETER RefreshDBPoolConfFile
        Define the name of the refresh DBPool configuration file.

        By default the configuration file is named:
            config.psd1

    .EXAMPLE
        Export-RefreshDBPoolSettings

        Validates that the BaseURI, and JSON depth are set then exports their values
        to the current user's DBPool configuration file located at:
            $env:USERPROFILE\RefreshDBPool\config.psd1

    .EXAMPLE
        Export-RefreshDBPoolSettings -DBPoolConfPath C:\RefreshDBPool -DBPoolConfFile MyConfig.psd1

        Validates that the BaseURI, and JSON depth are set then exports their values
        to the current user's DBPool configuration file located at:
            C:\RefreshDBPool\MyConfig.psd1

    .INPUTS
        N/A

    .OUTPUTS
        N/A

    .NOTES
        N/A

    .LINK
        https://datto-dbpool-refresh.kentsapp.com/Internal/moduleSettings/Export-RefreshDBPoolModuleSetting/
#>

    [CmdletBinding(DefaultParameterSetName = 'set')]
    Param (
        [Parameter(ParameterSetName = 'set')]
        [string]$RefreshDBPoolConfPath = $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop'){"RefreshDBPool"}else{".RefreshDBPool"}) ),

        [Parameter(ParameterSetName = 'set')]
        [string]$RefreshDBPoolConfFile = 'config.psd1'
    )

    begin {}

    process {

        $RefreshDBPoolConfig = Join-Path -Path $RefreshDBPoolConfPath -ChildPath $RefreshDBPoolConfFile
        Write-Verbose "Exporting 'Refresh DBPool Module' settings to [ $RefreshDBPoolConfig ]"

        # Confirm variables exist and are not null before exporting
        if ($DBPool_Base_URI -and $DBPool_JSON_Conversion_Depth) {

            if ($IsWindows -or $PSEdition -eq 'Desktop') {
                New-Item -Path $RefreshDBPoolConfPath -ItemType Directory -Force | ForEach-Object { $_.Attributes = $_.Attributes -bor "Hidden" }
            }
            else{
                New-Item -Path $RefreshDBPoolConfPath -ItemType Directory -Force
            }
@"
    @{
        ### DBPOOL REFRESH OVERRIDE CONFIG VARIABLES ###
        ## This config file is used to override variables for the DBPool Refresh module.
        ## Variables can be set below and uncommented as required.


        # Container IDs to refresh, by default all containers will be refreshed.

#        RefreshDBPool_Container_Ids = @( 123, 456, 789 )


        # URL of the API to be checked.
        # Defaulted to "$DBPool_Base_URI" in the script already and should not need to be changed or uncommented.

#        DBPool_Base_URI = 'https://dbpool.domain.tld'


        # Enable / Disable Auto-Update of the Refresh DBPool Module and its dependencies.

        RefreshDBPool_Enable_AutoUpdate = "True"


        # Enable / Disable Logging for the Refresh DBPool Module.

        RefreshDBPool_Logging_Enabled      = "True"
        RefreshDBPool_LogPath              = "$(Join-Path -Path $RefreshDBPoolConfPath -ChildPath 'Logs')"
        RefreshDBPool_LogFileName          = 'RefreshDBPool.log'
        RefreshDBPool_LogRotationEnabled   = "True"
        RefreshDBPool_LogRotationDays      = 90


        # Timeout for the script to wait for child process jobs to "complete" and return a response (success or failure error) before exiting.
        # Default in the script is set to 3600 seconds (60 minutes).

#        RefreshDBPool_TimeoutSeconds = 300

        # Refresh DBPool Script Verbose Preference
#	    RefreshDBPool_VerbosePreference = "True"


        ## END OF CONFIG FILE
    }
"@ | Out-File -FilePath $RefreshDBPoolConfig -Force
        }
        else {
            Write-Error "Failed to export DBPool Module settings to [ $RefreshDBPoolConfig ]"
            Write-Error $_ -ErrorAction Stop
        }

    }

    end {}

}
