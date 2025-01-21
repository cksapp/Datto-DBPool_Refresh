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
        https://datto-dbpool-refresh.kentsapp.com/Internal/Set-DBPoolSecurityProtocol/
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
