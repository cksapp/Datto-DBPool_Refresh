

#Region
function Set-DBPoolSecurityProtocol {
<#
    .SYNOPSIS
        The Set-DBPoolSecurityProtocol function is used to set the Security Protocol in the current context.

    .DESCRIPTION
        Sets the Security Protocol for a .NET application to use TLS 1.2 by default.
        This function is useful for ensuring secure communication in .NET applications.

    .PARAMETER Protocol
        The security protocol to use. Can be set to 'Ssl3', 'SystemDefault', 'Tls', 'Tls11', 'Tls12', and 'Tls13'.

    .EXAMPLE
        Set-DBPoolSecurityProtocol -Protocol Tls12

        Sets the Security Protocol to use TLS 1.2.

    .INPUTS
        [string] - The security protocol to use.

    .OUTPUTS
        N/A

    .NOTES
        Make sure to run this function in the appropriate context, as it affects .NET-wide security settings.

    .LINK
        N/A
#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param (
        [Parameter(Position = 0, Mandatory = $False, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('Ssl3', 'SystemDefault', 'Tls', 'Tls11', 'Tls12', 'Tls13')]
        [string]$Protocol = 'Tls12'
    )

    Process{

        if ($PSCmdlet.ShouldProcess($Protocol, "Set Security Protocol")) {
            try {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::$Protocol
                Write-Verbose "Security Protocol set to: $Protocol"
            } catch {
                Write-Error "Failed to set Security Protocol. $_"
            }
        }

    }
}
#EndRegion

#Region
function Get-RefreshDBPoolApiKey {
<#
    .SYNOPSIS
        This function gets the DBPool API key from the default PowerShell SecretManagement vault and sets the global variable.

    .DESCRIPTION
        This function gets the DBPool API key from the default PowerShell SecretManagement vault and sets the global variable.
        If the global variable is already set, confirm with the user before overwriting the value or set the value without confirmation using the -Force switch.

    .PARAMETER SecretName
        The name to use for the secret in the SecretManagement vault. Defaults to 'DBPool_ApiKey'.

    .PARAMETER SecretStoreName
        The name of the SecretManagement vault where the secret will be stored. Defaults to the value of the environment variable 'Datto_SecretStore'.

    .PARAMETER AsPlainText
        If specified, the function will return the API key as a plaintext string.

    .PARAMETER Force
        If specified, forces the function to overwrite the existing secret if it already exists in the vault.

    .EXAMPLE
        Get-RefreshDBPoolApiKey

        Retrieves the DBPool API key from the default SecretManagement vault with the default name 'DBPool_ApiKey' as a secure string.

    .EXAMPLE
        Get-RefreshDBPoolApiKey -AsPlainText

        Retrieves the DBPool API key from the default SecretManagement vault with the default name 'DBPool_ApiKey' as a plaintext string.

    .EXAMPLE
        Get-RefreshDBPoolApiKey -SecretName 'Different_SecretName' -SecretStoreName 'Custom_SecretsVault' -Force

        Retrieves the DBPool API key and adds it to the 'Custom_SecretsVault' SecretManagement vault with the name 'Different_SecretName'.
        If the secret already exists, it will be overwritten.

    .INPUTS
        N/A

    .OUTPUTS
        [securestring] - The DBPool API key as a secure string.
        [string] - The DBPool API key as a plaintext string.

    .NOTES
        This function is designed to work with the default SecretManagement vault. Ensure the vault is installed and configured before using this function.

    .LINK
        N/A
#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$SecretName = 'DBPool_ApiKey',

        [Parameter(Mandatory = $false)]
        [string]$SecretStoreName = 'Datto_SecretStore',

        [switch]$AsPlainText,

        [switch]$Force

    )

    begin {

        $secretExists = Get-SecretInfo -Vault $SecretStoreName -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Verbose:$false | Where-Object { $_.Name -eq $SecretName }

    }

    process {

        if ( !(Test-SecretVault -Name $SecretStoreName -ErrorAction SilentlyContinue -Verbose:$false) -or !($secretExists) ) {
            Write-Error "Ensure the default SecretManagement Vault is installed and configured. Use 'Set-RefreshDBPoolApiKey' first!"
        } else {
            try {

                if (!$DBPool_ApiKey) {
                    Add-DBPoolApiKey -apiKey $( Get-Secret -Name $SecretName -Vault $SecretStoreName -ErrorAction Stop ) -Verbose:$VerbosePreference
                } elseif (Get-Variable -Name 'DBPool_ApiKey' -ErrorAction SilentlyContinue) {
                    if ($Force -or $PSCmdlet.ShouldProcess('$DBPool_ApiKey', 'Set DBPool API Key')) {
                        Add-DBPoolApiKey -apiKey $( Get-Secret -Name $SecretName -Vault $SecretStoreName -ErrorAction Stop ) -Verbose:$VerbosePreference
                    }
                }

            } catch {
                Write-Error $_
            }
        }

    }

    end {
        (Get-DBPoolApiKey -AsPlainText:$AsPlainText -ErrorAction SilentlyContinue).ApiKey
    }

}
#EndRegion

#Region
function Remove-RefreshDBPoolApiKey {
<#
    .SYNOPSIS
        This function removes the DBPool API key to the default PowerShell SecretManagement vault.

    .DESCRIPTION
        This function removes the DBPool API key from the specified SecretManagement vault.

    .PARAMETER SecretName
        The name to use for the secret in the SecretManagement vault. Defaults to 'DBPool_ApiKey'.

    .PARAMETER SecretStoreName
        The name of the SecretManagement vault where the secret is stored. Defaults to the value of the environment variable 'Datto_SecretStore'.

    .PARAMETER Force
        If specified, forces the function to remove the secret from the vault.

    .EXAMPLE
        Remove-RefreshDBPoolApiKey

        Removes the API key from the SecretManagement vault.

    .EXAMPLE
        Remove-RefreshDBPoolApiKey -SecretName 'Different_SecretName' -SecretStoreName 'Custom_SecretsVault' -Force

        Removes the API key from the 'Custom_SecretsVault' SecretManagement vault with the name 'Different_SecretName'.

    .INPUTS
        N/A

    .OUTPUTS
        N/A

    .NOTES
        N/A

    .LINK
        N/A
#>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$SecretName = 'DBPool_ApiKey',

        [Parameter(Mandatory = $false)]
        [string]$SecretStoreName = 'Datto_SecretStore',

        [switch]$Force
    )

    begin {

        if ( !(Test-SecretVault -Name $SecretStoreName -ErrorAction Stop) ) {
            Write-Error "Ensure the default SecretManagement Vault is installed and configured. Use 'Register-SecretVault' -Name $SecretStoreName -DefaultVault' first!" -ErrorAction Stop
        }

    }

    process {

        $secretExists = Get-Secret -Name $SecretName -Vault $SecretStoreName -ErrorAction SilentlyContinue
        if ($secretExists) {
            if ($Force -or $PSCmdlet.ShouldProcess("Secret name [ $SecretName ] from vault [ $SecretStoreName ]")) {
                Remove-Secret -Name $SecretName -Vault $SecretStoreName
            }
        } else {
            Write-Warning "The secret '$SecretName' does not exist in the vault '$SecretStoreName'."
        }

    }

    end {}

}
#EndRegion

#Region
function Set-RefreshDBPoolApiKey {
<#
    .SYNOPSIS
        This function adds the DBPool API key to the default PowerShell SecretManagement vault.

    .DESCRIPTION
        This function securely stores the DBPool API key in the specified SecretManagement vault.
        It can be used to add or update the API key for later use in scripts and automation tasks.
        If the secret already exists, the function can overwrite it if the -Force switch is used.

    .PARAMETER SecretName
        The name to use for the secret in the SecretManagement vault. Defaults to 'DBPool_ApiKey'.

    .PARAMETER DBPool_ApiKey
        The secure string containing the DBPool API key. This parameter is mandatory.
        DBPool API key can be retrieved from the web interface at "$DBPool_Base_URI/web/self".

    .PARAMETER SecretStoreName
        The name of the SecretManagement vault where the secret will be stored.
        Default value is 'Datto_SecretStore'.

    .PARAMETER Force
        If specified, forces the function to overwrite the existing secret if it already exists in the vault.

    .EXAMPLE
        Set-RefreshDBPoolApiKey -DBPool_ApiKey $secureApiKey -Verbose

        Adds the DBPool API key to the default SecretManagement vault with the name 'DBPool_ApiKey'.

    .EXAMPLE
        Set-RefreshDBPoolApiKey -DBPool_ApiKey $secureApiKey -SecretName 'Custom_ApiKey' -SecretStoreName 'MySecretStore' -Force

        Adds the DBPool API key to the 'MySecretStore' SecretManagement vault with the name 'Custom_ApiKey'.
        If the secret already exists, it will be overwritten.

    .INPUTS
        [securestring] - The secure string containing the DBPool API key.

    .OUTPUTS
        N/A

    .NOTES
        Ensure that the PowerShell SecretManagement module is installed and configured before using this function.

    .LINK
        N/A
#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [Alias('Add-RefreshDBPoolApiKey')]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$SecretName = 'DBPool_ApiKey',

        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = { "Get API key from '$(Get-DBPoolBaseURI)/web/self'" })]
        [ValidateNotNullOrEmpty()]
        [securestring]$DBPool_ApiKey,

        [Parameter(Mandatory = $false)]
        [string]$SecretStoreName = 'Datto_SecretStore',

        [Parameter()]
        [switch]$Force
    )

    begin {

        # Pass the InformationAction parameter if bound, default to 'Continue'
        if ($PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSBoundParameters['InformationAction'] } else { $InformationPreference = 'Continue' }

        if ( !(Test-SecretVault -Name $SecretStoreName -ErrorAction Stop) ) {
            Write-Error "Ensure the default SecretManagement Vault is installed and configured. Use 'Register-SecretVault' -Name $SecretStoreName -DefaultVault' first!" -ErrorAction Stop
        }

    }

    process {

        $secretExists = Get-Secret -Name $SecretName -Vault $SecretStoreName -ErrorAction SilentlyContinue
        if ($secretExists) {
            $confirmValue = -not $Force

            try {
                if ($Force) { Write-Verbose "Overwriting secret [ $SecretName ]" }
                Set-Secret -Name $SecretName -Secret $DBPool_ApiKey -Vault $SecretStoreName -Confirm:$confirmValue -ErrorAction Stop
            } catch {
                Write-Error $_
            }
        } else {
            if ($PSCmdlet.ShouldProcess("Secret [ $SecretName ]", "Set secret in vault [ $SecretStoreName ]")) {
                try {
                    Set-Secret -Name $SecretName -Secret $DBPool_ApiKey -Vault $SecretStoreName -ErrorAction Stop
                    Write-Information "Secret [ $SecretName ] has been successfully set."
                } catch {
                    Write-Error $_
                }
            }
        }

    }

    end {

        Add-DBPoolApiKey -apiKey $DBPool_ApiKey -Verbose:$false -Force

    }

}
#EndRegion

#Region
function Add-DattoSecretStore {
<#
    .SYNOPSIS
        Adds a local secret store using the Microsoft.PowerShell.SecretStore module.

    .DESCRIPTION
        This function adds a local secret store using the Microsoft.PowerShell.SecretStore module. Checks if the secret store is installed and install if not found.
        The function also sets the secret store configuration for the default vault.

    .PARAMETER Name
        The name of the secret store to add. Defaults to 'Datto_SecretStore'.

    .PARAMETER ModuleName
        The name of the module to use for the secret store. Defaults to 'Microsoft.PowerShell.SecretStore'.

    .EXAMPLE
        Add-DattoSecretStore

        Adds a local secret store named 'Datto_SecretStore' using the Microsoft.PowerShell.SecretStore module.

    .EXAMPLE
        Add-DattoSecretStore -Name 'Custom_SecretsVault' -ModuleName 'Custom.SecretStore'

        Adds a local secret store named 'Custom_SecretsVault' using the 'Custom.SecretStore' module.

    .INPUTS
        N/A

    .OUTPUTS
        N/A

    .NOTES
        N/A

    .LINK
        N/A
#>
    [CmdletBinding()]
    param (
       [Parameter(Mandatory = $false)]
        [string]$Name = 'Datto_SecretStore',

        [Parameter(Mandatory = $false)]
        [string]$ModuleName = 'Microsoft.PowerShell.SecretStore'
    )

    begin {

        # Pass the InformationAction parameter if bound, default to 'Continue'
        if ($PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSBoundParameters['InformationAction'] } else { $InformationPreference = 'Continue' }

        # Check if the SecretManagement module is installed
        $installedModule = Get-InstalledModule -Name $ModuleName -ErrorAction SilentlyContinue
        if ($null -eq $installedModule) {
            try {
                # Use PSResourceGet to install the module
                if (Get-InstalledModule -Name 'PSResourceGet' -ErrorAction SilentlyContinue) {
                    try {
                        Install-PSResource -Name $ModuleName -Scope CurrentUser -TrustRepository -Reinstall -NoClobber -ErrorAction Stop
                    } catch {
                        Write-Error "Failed to install $ModuleName module using 'PSResourceGet': $_"
                        return
                    }
                } else {
                    # Fall back to using Install-Module
                    try {
                        Install-Module -Name $ModuleName -Scope CurrentUser -Force -ErrorAction Stop
                    } catch {
                        Write-Error "Failed to install $ModuleName module using 'Install-Module': $_"
                        return
                    }
                }
            } catch {
                Write-Error $_
                return
            }
        }

    }

    process {

        $secretStore = Get-SecretVault -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $Name }
        if ($null -eq $secretStore) {
            # Add a local secret store if the specified one is not found
            try {
                Register-SecretVault -Name $Name -ModuleName $ModuleName -DefaultVault -ErrorAction Stop
                Write-Information "Local secret store [ $Name ] has been added and set as the default vault."
            } catch {
                Write-Error "Failed to register the local secret store: $_"
            }
        } else {
            Write-Information "The secret store [ $Name ] is already set."
        }

        if ($ModuleName -eq 'Microsoft.PowerShell.SecretStore') {
            $storeConfiguration = @{
                Authentication  = 'None'
                PasswordTimeout = 600 # 10 minutes
                Interaction     = 'None'
                #Password        = $password
                Confirm         = $false
            }
            Set-SecretStoreConfiguration @storeConfiguration
        }

    }

    end {
        #$Env:Datto_SecretStore = $Name
    }
}
#EndRegion

#Region
function Unlock-DattoSecretStore {
    [CmdletBinding()]
    param (

    )

    begin {}

    process {

    }

    end {}
}
#EndRegion

#Region
function Update-RefreshDBPoolModule {
<#
    .SYNOPSIS
        Updates the Datto.DBPool.Refresh module if a newer version is available online.

    .DESCRIPTION
        This function checks for updates to the Datto.DBPool.Refresh module and updates it if a newer version is available online.
        The auto-update feature can be disabled by setting the AutoUpdate parameter to $false otherwise, it will default to $true.

    .PARAMETER ModuleName
        The name of the module to update. Defaults to 'Datto.DBPool.Refresh'.

    .PARAMETER AutoUpdate
        If specified, the module will be updated if a newer version is available online. Defaults to $RefreshDBPool_Enable_AutoUpdate variable.

    .PARAMETER AllowPrerelease
        If specified, the module will be updated to the latest prerelease version if available. Defaults to $false.

    .INPUTS
        [string] - ModuleName

    .OUTPUTS
        N/A

    .EXAMPLE
        Update-RefreshDBPoolModule -ModuleName 'Datto.DBPool.Refresh' -AutoUpdate:$true -AllowPrerelease:$false

        Updates the Datto.DBPool.Refresh module if a newer version is available online.

    .NOTES
        N/A

    .LINK
        N/A
#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param (
        [Parameter( Position = 0, Mandatory = $False, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True )]
        [String]$ModuleName = 'Datto.DBPool.Refresh',

        [Parameter(Position = 1, Mandatory = $False)]
        [switch]$AutoUpdate = $RefreshDBPool_Enable_AutoUpdate,

        [Parameter(Position = 2, Mandatory = $False)]
        [switch]$AllowPrerelease = $False
    )

    begin {

        # Pass the InformationAction parameter if bound, default to 'Continue'
        if ($PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSBoundParameters['InformationAction'] } else { $InformationPreference = 'Continue' }

        if ($null -eq $PSBoundParameters['AutoUpdate'] -and $null -eq $RefreshDBPool_Enable_AutoUpdate) {
            $AutoUpdate = $true
            Write-Warning "[ RefreshDBPool_Enable_AutoUpdate ] variable not set, defaulting to $AutoUpdate."
        }
    }

    process {

        switch ($AutoUpdate) {
            $True {
                # Check to update the module if the online version seen is higher than the installed version
                Write-Verbose "Module AutoUpdate is enabled, checking for updates to the module [ $ModuleName ]..."
                try {

                    $installedModule = if (Get-Command -Name Get-InstalledPSResource -ErrorAction SilentlyContinue) {
                        Get-InstalledPSResource -Name $ModuleName -ErrorAction SilentlyContinue -Verbose:$false
                    } else {
                        Get-InstalledModule -Name $ModuleName -AllowPrerelease:$AllowPrerelease -ErrorAction SilentlyContinue -Verbose:$false
                    }
                    $onlineModule = if (Get-Command -Name Find-PSResource -ErrorAction SilentlyContinue) {
                        Find-PSResource -Name $ModuleName -Prerelease:$AllowPrerelease -ErrorAction SilentlyContinue -Verbose:$false
                    } else {
                        Find-Module -Name $ModuleName -AllowPrerelease:$AllowPrerelease -ErrorAction SilentlyContinue -Verbose:$false
                    }
                    $installedModule = $installedModule | Sort-Object -Property { [version]$_.Version } -Descending | Select-Object -First 1
                    $onlineModule = $onlineModule | Sort-Object -Property { [version]$_.Version } -Descending | Select-Object -First 1

                    if (!$installedModule) {
                        try {
                            Write-Warning "Module [ $ModuleName ] does not appear to be installed, attempting to install."
                            if (Get-Command -Name Install-PSResource -ErrorAction SilentlyContinue) {
                                Install-PSResource -Name $ModuleName -Scope 'CurrentUser' -TrustRepository -Prerelease:$AllowPrerelease -ErrorAction Stop -Verbose:$false
                            } else {
                                Install-Module $ModuleName -Scope 'CurrentUser' -Force -AllowPrerelease:$AllowPrerelease -ErrorAction Stop -Verbose:$false
                            }
                            Write-Information "Module [ $ModuleName ] successfully installed."
                            Import-Module -Name $ModuleName -Force -Verbose:$false
                        } catch {
                            throw "Error installing module $ModuleName`: $_"
                        }
                    } else {
                        Write-Verbose "Module [ $($installedModule.Name) ] is already installed on the local system."

                        $installedVersion = [version]$installedModule.Version
                        $onlineVersion = [version]$onlineModule.Version

                        Write-Debug "Installed version: [ $installedVersion ] and Online version: [ $onlineVersion ]"

                        if ($installedVersion -eq $onlineVersion) {
                            Write-Host "$ModuleName version installed is [ $installedVersion ] which matches the online version [ $onlineVersion ]" -ForegroundColor Green
                        } elseif ($installedVersion -gt $onlineVersion) {
                            Write-Host "$ModuleName version installed is [ $installedVersion ] which is greater than the online version [ $onlineVersion ]`nStrange, but okay I guess?`n" -ForegroundColor Gray
                        } elseif ($installedVersion -lt $onlineVersion) {
                            Write-Warning "$ModuleName version installed is [ $installedVersion ] which is less than the online version [ $onlineVersion ]"

                            Write-Information "Updating [ $ModuleName ] from version [ $installedVersion ] to [ $onlineVersion ]."
                            if (Get-Command -Name Update-PSResource -ErrorAction SilentlyContinue) {
                                Update-PSResource -Name $ModuleName -Force -Prerelease:$AllowPrerelease -ErrorAction Stop -Verbose:$false
                            } else {
                                Update-Module -Name $ModuleName -Force -TrustRepository -AllowPrerelease:$AllowPrerelease -ErrorAction Stop -Verbose:$false
                            }

                            Import-Module -Name $ModuleName -Force -Verbose:$false
                        }

                    }
                } catch {
                    Write-Error $_
                }

            } Default {
                Write-Information "Module AutoUpdate is disabled, skipping update for module '$ModuleName'."
            }

        }

    }

    end {}

}
#EndRegion

#Region
function Initialize-RefreshDBPoolLog {
    [CmdletBinding()]
    param ()

    begin {

        if ($RefreshDBPool_Logging_Enabled -eq $false) {
            Write-Verbose "Logging is disabled in the module settings. Skipping log initialization."
            return
        } elseif ($RefreshDBPool_Logging_Enabled -eq $true) {
            Write-Verbose "Logging is enabled in the module settings. Initializing log."
        } elseif ($null -eq $RefreshDBPool_Logging_Enabled) {
            Write-Warning "Logging is not set in the module settings. Defaulting to enabled."
            $Global:RefreshDBPool_Logging_Enabled = $true
        }

        if (!(Get-Module -Name 'PSFramework' -ListAvailable)) {
            try {
                Import-Module PSFramework -ErrorAction Stop
            }
            catch {
                Write-Error $_
                return
            }
        }

        $logDirectory = $RefreshDBPool_LogPath
        $logFileName = "%date%-$RefreshDBPool_LogFileName"
        $logFilePath = Join-Path -Path $logDirectory -ChildPath $logFileName

    }

    process {

        if (-not (Test-Path -Path $logDirectory)) {
            try {
                New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
            } catch {
                Write-Error -Message "Failed to create log directory: $_"
                return
            }
        }

        try {
            # Configure PSFramework logging provider
            $paramSetPSFLoggingProvider = @{
                Name            = 'logfile'
                InstanceName    = 'RefreshDBPool'
                FilePath        = $logFilePath
                FileType        = 'CSV'
                Headers         = @('Timestamp', 'Level', 'Message', 'DataCompact')
                EnableException = $true
                Enabled         = $true
                LogRotatePath   = $logDirectory
                LogRetentionTime    = $RefreshDBPool_LogRotationDays

            }
            Set-PSFLoggingProvider @paramSetPSFLoggingProvider -ErrorAction Stop
            Write-Verbose "Logging configured successfully. Logs will be written to: $logFilePath"
        } catch {
            Write-Error $_
            return
        }

    }

    end {

    }
}
#EndRegion

#Region
function Remove-RefreshDBPoolLog {
<#
    .SYNOPSIS
        Remove log files older than a specified number of days.

    .DESCRIPTION
        The Remove-RefreshDBPoolLog cmdlet removes log files older than a specified number of days.

        By default, log files are stored in the following location and will be removed:
            $env:USERPROFILE\RefreshDBPool\Logs

    .PARAMETER LogPath
        Define the location of the log files.

        By default, log files are stored in the following location:
            $env:USERPROFILE\RefreshDBPool\Logs

    .PARAMETER LogFileName
        Define the name of the log files.

        By default, log files are named:
            RefreshDBPool_*.log

    .PARAMETER LogRotationDays
        Define the number of days to keep log files.
        By default, log files older than 90 days will be removed.

    .PARAMETER Force
        If specified, the function will not prompt for confirmation before removing the log files.

    .EXAMPLE
        Remove-RefreshDBPoolLog

        Remove log files older than 90 days.

    .EXAMPLE
        Remove-RefreshDBPoolLog -LogPath C:\RefreshDBPool\Logs -LogFileName "RefreshDBPool_*.log" -LogRotationDays 7 -Force

        Remove log files older than 7 days from the specified location.

    .INPUTS
        N/A

    .OUTPUTS
        N/A

    .NOTES
        N/A

    .LINK
        N/A
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [string]$LogPath = $RefreshDBPool_LogPath,

        [string]$LogFileName = $RefreshDBPool_LogFileName,

        [int]$LogRotationDays = $RefreshDBPool_LogRotationDays,

        [switch]$Force
    )

    begin {

        if (-not (Test-Path -Path $LogPath -ErrorAction SilentlyContinue)) {
            throw "Log path does not exist. Run 'Export-RefreshDBPoolModuleSetting' first."
        }

    }

    process {

        $logFiles = Get-ChildItem -Path $LogPath -Filter "*$LogFileName" -File -ErrorAction SilentlyContinue
        if (-not $logFiles) {
            Write-Warning "No log files matching '*$LogFileName' found in '$LogPath'."
            return
        }

        $logFilesToRemove = $logFiles | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$LogRotationDays) }
        if (-not $logFilesToRemove) {
            Write-Warning "No log files found in [ $LogPath ] older than '$LogRotationDays' days."
            return
        }

        foreach ($log in $logFilesToRemove) {

            if ($Force -or $PSCmdlet.ShouldProcess("[ $log ]", 'Remove Log file')) {
                try {
                    Remove-Item -Path $log.FullName -Force -ErrorAction Stop
                    Write-Verbose -Message "Removed log file: [ $($log.FullName) ]"
                }
                catch {
                    Write-Verbose -Message "Failed to remove log file: [ $($log.FullName) ]"
                    Write-Error -Message "$_"
                }
            }

        }

    }

    end {}

}
#EndRegion

#Region
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
        N/A
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
#EndRegion

#Region
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

    .INPUTS
        N/A

    .OUTPUTS
        N/A

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
#EndRegion

#Region
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

    .INPUTS
        N/A

    .OUTPUTS
        N/A

    .NOTES
        N/A

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
#EndRegion

#Region
# Used to auto load either baseline settings or saved configurations when the module is imported
Import-RefreshDBPoolModuleSetting -Verbose:$VerbosePreference

if (Test-SecretVault -Name 'Datto_SecretStore' -WarningAction SilentlyContinue -ErrorAction SilentlyContinue) {
    try {
        Get-RefreshDBPoolApiKey -Force -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning $_
    }
}
#EndRegion

#Region
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
#EndRegion

#Region
function Register-RefreshDBPoolTask {
<#
    .SYNOPSIS
        Creates a scheduled task to automate the refresh of Datto DBPool containers.

    .DESCRIPTION
        This function sets up a scheduled task that runs a PowerShell script to refresh Datto DBPool containers.
        The task can be configured to run on specific days of the week and at a specified time.

    .PARAMETER TriggerTime
        Specifies the time of day at which the scheduled task should run.
        This should be set to roughly ~1 hour before shift start, so that all containers are refreshed and ready for use.

    .PARAMETER ExcludeDaysOfWeek
        Specifies the days of the week on which the scheduled task should NOT be run.
        This will generally be days off work, by default the task will not run on Sundays and Saturdays.

    .INPUTS
        N/A

    .OUTPUTS
        N/A

    .EXAMPLE
        Register-RefreshDBPoolTask -TriggerTime "7AM"

        This example creates a scheduled task that runs every day at 7:00 AM, except on Sundays and Saturdays.

    .EXAMPLE
        Register-RefreshDBPoolTask -TriggerTime "15:00"

        This example creates a scheduled task that runs every day at 3:00 PM, except on Sundays and Saturdays.

    .EXAMPLE
        Register-RefreshDBPoolTask -ExcludeDaysOfWeek 'Sunday','Monday' -TriggerTime "4:30PM"

        This example creates a scheduled task that runs every day at 4:30 PM, except on Sunday and Monday.

    .NOTES
        This function is currently designed to work only on Windows systems. It uses the Task Scheduler to create and manage the scheduled task.
        Will look to add support for Linux/MacOS using cron jobs or similar such as anacron in the future.

    .LINK
        https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtask
#>

    [CmdletBinding()]
    [Alias('New-RefreshDBPoolTask')]
    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "The time of day at which the scheduled task should run.")]
        [DateTime]$TriggerTime,

        [Parameter(Mandatory = $false, HelpMessage = "The days of the week on which the scheduled task should NOT be run.")]
        [ValidateSet('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')]
        [string[]]$ExcludeDaysOfWeek = @('Sunday','Saturday')
    )

    begin {

        # Days of the week to run the task
        $daysToRun = $( [System.DayOfWeek].GetEnumValues() ) | Where-Object { $ExcludeDaysOfWeek -notcontains [System.DayOfWeek]::$_ }

        if ($PSEdition -eq 'Desktop') {
            #$PSExecutable = Join-Path -Path $PSHOME -ChildPath 'powershell.exe'
            $PSExecutable = if (Get-Command -Name 'pwsh' -ErrorAction SilentlyContinue) {
                (Get-Command pwsh).Source
            } else {
                (Get-Command powershell).Source
            }
        } elseif ($PSEdition -eq 'Core') {
            if ($IsWindows) {
                $PSExecutable = Join-Path -Path $PSHOME -ChildPath 'pwsh.exe'
            } elseif ($IsLinux) {
            } elseif ($IsMacOS) {
            }
        }

    }

    process {

        $moduleBasePath = $( Split-Path -Path $((Get-Command Register-RefreshDBPoolTask).Module).path )
        $scriptDir = $( Join-Path -Path $moduleBasePath -ChildPath 'scripts' )
        $scriptFile = $( Join-Path -Path $scriptDir -ChildPath 'Invoke-RefreshDBPoolContainer.ps1' )

        if ($IsWindows -or $PSEdition -eq 'Desktop') {

            $taskPath = 'Datto'
            $taskName = 'DBPool-Refresh'
            $taskDescription = 'Scheduled task to automate refresh of Datto DBPool containers.'

            # Task trigger
            $triggerParams = @{
                Weekly     = $true
                DaysOfWeek = $daysToRun
                At         = $TriggerTime
            }
            $taskTrigger = New-ScheduledTaskTrigger @triggerParams

            # Task Action
            $actionParams = @{
                Execute          = "`"$PSExecutable`""
                Argument         = "-WindowStyle Minimized -NoProfile -ExecutionPolicy Bypass -File `"$scriptFile`" -Bootstrap"
                WorkingDirectory = "$moduleBasePath"
            }
            $taskAction = New-ScheduledTaskAction @actionParams

            # Task Settings
            $settingsParams = @{
                AllowStartIfOnBatteries = $true
                Compatibility           = 'Win8'
                ExecutionTimeLimit      = (New-TimeSpan -Hours 2)
                RestartCount            = 3
                RestartInterval         = (New-TimeSpan -Minutes 5)
                StartWhenAvailable      = $true
                WakeToRun               = $true
            }
            $taskSettings = New-ScheduledTaskSettingsSet @settingsParams
            # 3 corresponds to 'Stop the existing instance' https://stackoverflow.com/questions/59113643/stop-existing-instance-option-when-creating-windows-scheduled-task-using-powersh/59117015#59117015
            $taskSettings.CimInstanceProperties.Item('MultipleInstances').Value = 3

            # Task
            $taskParams = @{
                Action   = $taskAction
                Description = $taskDescription
                Settings = $taskSettings
                Trigger  = $taskTrigger
            }
            $task = New-ScheduledTask @taskParams
            $task.Author = "Kent Sapp (@cksapp)"

            $registerParams = @{
                InputObject = $task
                TaskName    = $taskName
                TaskPath    = $taskPath
                User        = $env:USERNAME
                Force       = $true
                ErrorAction = 'Stop'
            }
            try {
                $scheduledTask = Register-ScheduledTask @registerParams

                try {
                    $scheduledTask.Date = '2023-08-30T12:34:56.7890000'
                    Set-ScheduledTask -InputObject $scheduledTask -Verbose:$VerbosePreference -ErrorAction Stop | Out-Null
                }
                catch {
                    Write-Warning "Error updating 'Created Date' for scheduled task [ $taskName ]: $_"
                }
            }
            catch {
                Write-Error $_.Exception.Message
            }
        }
        else {
            Write-Warning "This function is currently only supported on Windows."
            #TODO: Add support for Linux/MacOS using cron jobs or similar such as anacron
        }

    }

    end {}

}
#EndRegion

#Region
function Update-RefreshDBPoolTask {
<#
    .SYNOPSIS
        Updates the refresh DBPool scheduled task.

    .DESCRIPTION
        This function updates the scheduled task that runs the refresh DBPool script by updating path and arguments.

    .PARAMETER Force
        Forces the update of the scheduled task.

    .INPUTS
        N/A

    .OUTPUTS
        N/A

    .EXAMPLE
        Update-RefreshDBPoolTask

        This example updates the scheduled task that runs the refresh DBPool script.

    .NOTES
        This function is currently only supported on Windows systems.

    .LINK
        N/A
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [switch]$Force
    )

    begin {

        if ($PSEdition -eq 'Desktop') {
            $PSExecutable = if (Get-Command -Name 'pwsh' -ErrorAction SilentlyContinue) {
                (Get-Command pwsh).Source
            } else {
                (Get-Command powershell).Source
            }
        } elseif ($PSEdition -eq 'Core') {
            if ($IsWindows) {
                $PSExecutable = Join-Path -Path $PSHOME -ChildPath 'pwsh.exe'
            } elseif ($IsLinux) {
            } elseif ($IsMacOS) {
            }
        }

    }

    process {

        $moduleBasePath = $( Split-Path -Path $((Get-Command Register-RefreshDBPoolTask).Module).path )
        $scriptDir = $( Join-Path -Path $moduleBasePath -ChildPath 'scripts' )
        $scriptFile = $( Join-Path -Path $scriptDir -ChildPath 'Invoke-RefreshDBPoolContainer.ps1' )

        if ($IsWindows -or $PSEdition -eq 'Desktop') {

            $taskPath = 'Datto'
            $taskName = 'DBPool-Refresh'
            try {
                $task = Get-ScheduledTask -TaskPath "*$taskPath*" -TaskName $taskName -ErrorAction SilentlyContinue

                if (-not $task) {
                    Write-Warning "Scheduled task [ $taskName ] not found. Run 'Register-RefreshDBPoolTask' first."
                    return
                }

                if ($Force -or $PSCmdlet.ShouldProcess("Scheduled task [ $taskName ]", 'Update')) {
                    $actionParams = @{
                        Execute          = "`"$PSExecutable`""
                        Argument         = "-WindowStyle Minimized -NoProfile -ExecutionPolicy Bypass -File `"$scriptFile`""
                        WorkingDirectory = "$moduleBasePath"
                    }
                    $task.Actions = New-ScheduledTaskAction @actionParams

                    Set-ScheduledTask -InputObject $task -Verbose:$VerbosePreference
                }

            }
            catch {
                Write-Error $_
            }
        }
        else {
            Write-Warning "This function is currently only supported on Windows."
            #TODO: Add support for Linux/MacOS using cron jobs or similar such as anacron
        }

    }

    end {}

}
#EndRegion

#Region
function Copy-DBPoolParentContainer {
<#
    .SYNOPSIS
        Clones the specified DBPool parent container(s) using the DBPool API.

    .DESCRIPTION
        This function clones the specified DBPool parent container(s) using the DBPool API. By default, this function will clone all containers if no IDs or DefaultDatabase values are provided.

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

    .NOTES
        N/A

    .LINK
        N/A
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
#EndRegion

#Region
function Sync-DBPoolContainer {
<#
    .SYNOPSIS
        Refreshes the specified DBPool container(s) using the DBPool API. By default, this function will refresh all containers if no IDs are provided.

    .DESCRIPTION
        This function refreshes the specified DBPool container(s) using the DBPool API. By default, this function will refresh all containers if no IDs are provided.

    .PARAMETER Id
        The ID(s) of the container(s) to refresh. If no IDs are provided, all containers will be refreshed.

    .PARAMETER TimeoutSeconds
        The maximum time in seconds to wait for the container(s) to refresh. The default value is 3600 seconds (1 hour).

    .PARAMETER Force
        If specified, the function will not prompt for confirmation before refreshing the container(s).

    .INPUTS
        [int] - Array of ID(s) of the container(s) to perform the refresh action on.

    .OUTPUTS
        [void] - No output is returned.

    .EXAMPLE
        Sync-DBPoolContainer

        Refreshes all DBPool containers.

    .EXAMPLE
        Sync-DBPoolContainer -Id 1234

        Refreshes the DBPool container with the ID 1234.

    .EXAMPLE
        Sync-DBPoolContainer -Id 1234, 5678

        Refreshes the DBPool containers with the IDs 1234 and 5678.

    .EXAMPLE
        Sync-DBPoolContainer -Id $(Get-DBPoolContainer -DefaultDatabase "Database_Name").Id

        Refreshes all DBPool containers matching the specified database name.

    .EXAMPLE
        Sync-DBPoolContainer -Id $(Get-DBPoolContainer -NotLike -Name "*Container_Name*").Id -Force

        Refreshes all DBPool containers not matching the specified container name.

    .NOTES
        N/A

    .LINK
        N/A
#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ContainerId')]
        [int[]]$Id = $RefreshDBPool_Container_Ids,

        [Parameter(DontShow = $true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$TimeoutSeconds = $RefreshDBPool_TimeoutSeconds,

        [switch]$Force
    )

    begin {

        if (!(Get-Variable -Name 'DBPool_ApiKey' -Scope Global -ErrorAction SilentlyContinue)) {
            try {
                Get-RefreshDBPoolApiKey -Force -Verbose:$false -ErrorAction Stop
            }
            catch {
                throw $_
            }
        }

        if (-not $PSBoundParameters['TimeoutSeconds']) {
            $TimeoutSeconds = 3600
        }
    }

    process {

        if (!$Id) {
            Write-Warning 'No container IDs provided. Retrieving all container IDs.'
            try {
                $Id = Get-DBPoolContainer -ListContainer -ErrorAction Stop | Select-Object -ExpandProperty Id
            } catch {
                Write-Error $_
            }
        }

        $IdsToRefresh = [System.Collections.ArrayList]::new()
        foreach ($n in $Id) {
            if ($Force -or $PSCmdlet.ShouldProcess("Container [ ID: $n ]", '[ Refresh ]')) {
                $IdsToRefresh.Add($n) | Out-Null
            }
        }

        if ($IdsToRefresh.Count -gt 0) {
            try {
                Invoke-DBPoolContainerAction -Action refresh -Id $IdsToRefresh -Force -Verbose:$VerbosePreference -ThrottleLimit $IdsToRefresh.Count -TimeoutSeconds $TimeoutSeconds -ErrorAction Continue
            }
            catch {
                Write-Error $_
            }
        } elseif ($IdsToRefresh.Count -eq 0) {
            Write-Warning 'No containers refreshed.'
        }

    }

    end {}

}
#EndRegion
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

