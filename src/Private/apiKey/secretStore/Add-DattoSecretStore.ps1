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
                        Install-Module -Name $ModuleName -Scope CurrentUser -Force -ErrorAction Stop -AllowClobber
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

        if ($ModuleName -eq 'Microsoft.PowerShell.SecretStore') {
            $storeConfiguration = @{
                Authentication  = 'None'
                PasswordTimeout = 600 # 10 minutes
                Interaction     = 'None'
                #Password        = $password
                Confirm         = $False
            }
            Set-SecretStoreConfiguration @storeConfiguration
        }

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

    }

    end {
        #$Env:Datto_SecretStore = $Name
    }
}
