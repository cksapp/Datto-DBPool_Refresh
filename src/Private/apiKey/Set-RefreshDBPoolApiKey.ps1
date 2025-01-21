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
        https://datto-dbpool-refresh.kentsapp.com/Internal/apiKey/Set-RefreshDBPoolApiKey/
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
