<#
.SYNOPSIS
    Checks if the override.ps1 file exists and imports the variables to current session
.DESCRIPTION
    This allows for a user specified file location for 
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>

function Import-Env {
    [CmdletBinding()]
    param (
        [Parameter( 
            Mandatory = $False,
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            HelpMessage = "The path for environment override file."
        )]
        [String]
        $envFilePath,

        [Parameter( 
            Mandatory = $False,
            Position = 1,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            HelpMessage = "The environment override file name."
        )]
        [String]
        $envFileName = "env_override",

        [Parameter(
            Mandatory = $False,
            Position = 2,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            HelpMessage = "Environment override file extenstion."
        )]
        [String]
        $envFileExt = "ps1",

        [Parameter( 
            Mandatory = $False,
            Position = 3,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            HelpMessage = "The environment override file filter. Defaults to remove lines begining with `#` comments"
        )]
        [regex]
        $envFilter,

        [Parameter(
            Mandatory = $False,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        $varScope = "Script"
    )
    
    begin
    {
        $envFile = "$($envFileName).$($envFileExt)"
        $currentLocation = Get-Location
        $envFilePath = Join-Path -Path $currentLocation -ChildPath $envFile

        if (Test-Path -Path $envFilePath -PathType Leaf) {
            # Convert path only if the file exists
            $envFilePath = Convert-Path $envFilePath

            # Dot source env override if file exists
            . $envFilePath
        }
        else {
            Write-Verbose -Message "Override file does not exist at $envFilePath"
        }
        #Continue
    }

    
    process {
        <#
        $envFilter = '^\s*#'
        $envContent = Get-Content -Path $envFilePath | Where-Object { $_ -notmatch $envFilter }
        foreach ($line in $envContent) {
            # Skip commented lines that start with `#`
            if ($line -match $envFilter) {
                continue
            }
    
            $line = $line.Trim()
            if (-not [string]::IsNullOrWhiteSpace($line) -and $line -match '^(.*?)=(.*)$') {
                $varName = $matches[1]
                $varValue = $matches[2]
                Write-Host "Setting override variable: $varName=$varValue"
                Set-Variable -Name "$varName" -Value "$varValue" #-Force -Scope $varScope
            }
        }
        #>

        <#
        # Check if the variable $p_apiKey exists from override.ps1 file, otherwise ask the user for their API key
        if (-not (Test-Path variable:apiKey)) {
            # If it doesn't exist, ask the user for input
            $apiKeySecure = Read-Host "Please enter your DBPool Personal API Key" -AsSecureString
            # Convert the secure string to a plain text string
            $p_apiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKeySecure))
            
            # Set environment variable using [Environment]::SetEnvironmentVariable
            [Environment]::SetEnvironmentVariable("apiKey", $p_apiKey, "Process")
        
            # Clear plaintext variable
            $p_apiKey = $null
            # Dispose of the SecureString to minimize its exposure in memory
            $apiKeySecure.Dispose()
        }#>
    }
    <#end {
        return $envContent
    }#>
}