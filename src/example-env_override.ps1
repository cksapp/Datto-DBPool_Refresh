function Import-EnvironmentOverride {
    <#
    .SYNOPSIS
       This function creates variables based on a hashtable of default values to import into a session.

    .DESCRIPTION
       Change the values in the hashtable defined in $variables to suit your needs.
       Users can specify the variable scope using the -VariableScope parameter.

    .PARAMETER VariableScope
       Specifies the scope in which the variables should be created (default is Global).

    .EXAMPLE
       New-OverrideVariables -VariableScope "Script"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateSet("Global", "Script", "Local", "Private", "AllUsers", "CurrentUser")]
        [String]$VariableScope = "Global"
    )

    $variables = @{
        # Container IDs to refresh, by default all containers will be refreshed
        #ids = @(1, 2, 3)

        # Enter your API key from DBPool
        #apiKey = "your_api_key_here"

        # Timeout for the script to wait for child process jobs to "complete" and return a response before exiting.
        # Default in the script is set to 60 seconds, this still appears to send the refresh command but may not wait to provide a response if you need that. 
        #waitSeconds = 300

        # URL of the API to be checked, defaulted to "https://dbpool.datto.net" in the script already and should not need to be changed or uncommented.
        #apiUrl = "https://dbpool.datto.net"
    }

    # Loop through the hashtable and create variables with default values
    foreach ($variableName in $variables.Keys) {
        New-Variable -Name $variableName -Value $variables[$variableName] -Force -Scope $VariableScope
        Write-Verbose -Message "Variable `$$variableName imported."
    }
}