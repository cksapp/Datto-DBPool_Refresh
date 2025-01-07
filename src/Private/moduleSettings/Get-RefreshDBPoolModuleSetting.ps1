function Get-RefreshDBPoolModuleSetting {
<#
    .SYNOPSIS
        Gets the saved DBPool configuration settings

    .DESCRIPTION
        The Get-RefreshDBPoolModuleSetting cmdlet gets the saved DBPool refresh configuration settings
        from the local system.

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

    .PARAMETER openConfFile
        Opens the DBPool configuration file

    .EXAMPLE
        Get-RefreshDBPoolModuleSetting

        Gets the contents of the configuration file that was created with the
        Export-RefreshDBPoolModuleSettings

        The default location of the DBPool configuration file is:
            $env:USERPROFILE\RefreshDBPool\config.psd1

    .EXAMPLE
        Get-RefreshDBPoolModuleSetting -RefreshDBPoolConfig C:\RefreshDBPool -DBPoolConfFile MyConfig.psd1 -openConfFile

        Opens the configuration file from the defined location in the default editor

        The location of the DBPool configuration file in this example is:
            C:\RefreshDBPool\MyConfig.psd1

    .NOTES
        N/A

    .LINK
        N/A
#>

    [CmdletBinding(DefaultParameterSetName = 'index')]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'index')]
        [string]$RefreshDBPoolConfPath = $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop'){"RefreshDBPool"}else{".RefreshDBPool"}) ),

        [Parameter(Mandatory = $false, ParameterSetName = 'index')]
        [String]$RefreshDBPoolConfFile = 'config.psd1',

        [Parameter(Mandatory = $false, ParameterSetName = 'show')]
        [Switch]$openConfFile
    )

    begin {
        $RefreshDBPoolConfig = Join-Path -Path $RefreshDBPoolConfPath -ChildPath $RefreshDBPoolConfFile
    }

    process {

        if ( Test-Path -Path $RefreshDBPoolConfig ){

            if($openConfFile){
                Invoke-Item -Path $RefreshDBPoolConfig
            }
            else{
                Import-LocalizedData -BaseDirectory $RefreshDBPoolConfPath -FileName $RefreshDBPoolConfFile
            }

        }
        else{
            Write-Verbose "No configuration file found at [ $RefreshDBPoolConfig ] run 'Export-RefreshDBPoolModuleSetting' to create one."
        }

    }

    end {}

}
