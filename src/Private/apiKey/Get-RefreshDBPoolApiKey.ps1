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
        https://datto-dbpool-refresh.kentsapp.com/Internal/apiKey/Get-RefreshDBPoolApiKey/
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
            return
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
        (Get-DBPoolApiKey -AsPlainText:$AsPlainText -WarningAction SilentlyContinue -ErrorAction SilentlyContinue).ApiKey
    }

}
