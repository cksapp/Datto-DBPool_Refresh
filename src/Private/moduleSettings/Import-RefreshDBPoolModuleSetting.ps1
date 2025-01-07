function Import-RefreshDBPoolModuleSetting {
<#
    .SYNOPSIS
        Imports the DBPool BaseURI, API, & JSON configuration information to the current session.

    .DESCRIPTION
        The Import-RefreshDBPoolModuleSetting cmdlet imports the DBPool BaseURI, API, & JSON configuration
        information stored in the DBPool refresh configuration file to the users current session.

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\RefreshDBPool

    .PARAMETER RefreshDBPoolConfPath
        Define the location to store the DBPool configuration file.

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\RefreshDBPool

    .PARAMETER RefreshDBPoolConfFile
        Define the name of the DBPool configuration file.

        By default the configuration file is named:
            config.psd1

    .EXAMPLE
        Import-RefreshDBPoolModuleSetting

        Validates that the configuration file created with the Export-RefreshDBPoolModuleSettings cmdlet exists
        then imports the stored data into the current users session.

        The default location of the DBPool configuration file is:
            $env:USERPROFILE\RefreshDBPool\config.psd1

    .EXAMPLE
        Import-RefreshDBPoolModuleSetting -RefreshDBPoolConfPath C:\RefreshDBPool -RefreshDBPoolConfFile MyConfig.psd1

        Validates that the configuration file created with the Export-RefreshDBPoolModuleSettings cmdlet exists
        then imports the stored data into the current users session.

        The location of the DBPool configuration file in this example is:
            C:\RefreshDBPool\MyConfig.psd1

    .NOTES
        N\A

    .LINK
        N/A
#>

    [CmdletBinding(DefaultParameterSetName = 'set')]
    Param (
        [Parameter(ParameterSetName = 'set')]
        [string]$RefreshDBPoolConfPath = $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop'){"RefreshDBPool"}else{".RefreshDBPool"}) ),

        [Parameter(ParameterSetName = 'set')]
        [string]$RefreshDBPoolConfFile = 'config.psd1'
    )

    begin {
        $RefreshDBPoolConfig = Join-Path -Path $RefreshDBPoolConfPath -ChildPath $RefreshDBPoolConfFile
    }

    process {

        if ( Test-Path $RefreshDBPoolConfig ) {
            Import-LocalizedData -BaseDirectory $RefreshDBPoolConfPath -FileName $RefreshDBPoolConfFile -BindingVariable tmp_config

            foreach ($key in $tmp_config.Keys) {
                #Write-Verbose "Setting variable [ $key ] to [ $($tmp_config[$key]) ]"
                $value = $tmp_config[$key]
                if ($value -eq 'True') { $value = $true } elseif ($value -eq 'False') { $value = $false }
                if (-not [string]::IsNullOrEmpty($value)) {
                    Set-Variable -Name $key -Value $value -Scope Global -Force -Verbose:$VerbosePreference
                }
            }

            if ($tmp_config.DBPool_Base_URI) {
                # Send to function to strip potentially superfluous slash (/)
                Add-DBPoolBaseURI $tmp_config.DBPool_Base_URI -Verbose:$VerbosePreference
            } else {
                Add-DBPoolBaseURI -Verbose:$VerbosePreference
            }

            Write-Verbose "RefreshDBPool Module configuration loaded successfully from [ $RefreshDBPoolConfig ]"

            # Clean things up
            Remove-Variable "tmp_config" -Force
        }
        else {
            Write-Verbose "No configuration file found at [ $RefreshDBPoolConfig ] run 'Set-RefreshDBPoolApiKey' to get started."

            Add-DBPoolBaseURI -Verbose:$VerbosePreference

            Set-Variable -Name 'RefreshDBPool_Enable_AutoUpdate' -Value $true -Option ReadOnly -Scope Global -Force -Verbose:$VerbosePreference
        }

    }

    end {}

}
