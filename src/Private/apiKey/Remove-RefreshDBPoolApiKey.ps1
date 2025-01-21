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
        https://datto-dbpool-refresh.kentsapp.com/Internal/apiKey/Remove-RefreshDBPoolApiKey/
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
