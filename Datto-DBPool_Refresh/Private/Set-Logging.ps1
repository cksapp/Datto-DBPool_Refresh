function Set-Logging {
<#
    .SYNOPSIS
        Sets logging and creates log file
    .DESCRIPTION
        Validates log directory exists and creates it if not. Sets log location and creates log file.
    .NOTES
        Should work for both Windows and Unix based systems.
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Set-Logging -logPath '/path/to/logging'
        -logPath will specifiy the log path to be used, will default to the current working path for scripts.
    .PARAMETER
        Log 
#>

    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $False, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True
        )]
        [boolean]$doLogs,

        [Parameter(
            Position = 1, 
            Mandatory = $False, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$logPath = (Get-Location),

        [Parameter(
            Position = 2, 
            Mandatory = $False, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True
        )]
        $logFileName = "logFile.log",

        [Parameter(
            Position = 3, 
            Mandatory = $False, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True
        )]
        $logDateFormat = "yyyy-MM-dd",

        [Parameter(
            Mandatory = $False,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        $VariableScope = "Script"
    )

    switch ($doLogs) {
        $true {
            # Directory for "logs"
            $logDir = Get-ChildItem $logPath | Where-Object { $_.PSIsContainer -and $_.Name -imatch "logs" } 
            
            # Check if log directory was found
            if ($logDir) {
                # Join the paths and assign to $logDir
                $logDir = Join-Path -Path $logPath -ChildPath $logDir.Name
                Write-Information "Logging directory set to: $logDir" -InformationAction Continue
            }
            else {
                # Create the directory if not found
                Write-Verbose -Message "Log directory not found at $logPath"
                $logDir = Join-Path -Path $logPath -ChildPath "logs"
                New-Item -ItemType Directory -Path $logDir -ErrorAction SilentlyContinue
                if (Test-Path -Path $logDir -PathType Container) {
                    Write-Verbose -Message "Directory created: $logDir" -InformationAction Continue 
                    Write-Verbose -Message "Logging to: $logDir" -InformationAction Continue 
                } else {
                    Write-Error -Message "Failed to create log directory at $logDir" -Category ObjectNotFound -ErrorAction SilentlyContinue
                }
            }
            # Log file params
            $logDate = Get-Date -Format "$logDateFormat"
            $logName = "$logDate`_$logFileName"
            $logFile = Join-Path -Path $logDir -ChildPath $logName
            
            # Sets the logFile variable
            New-Variable -Name 'logFile' -Value "$logFile" -Force -Scope $VariableScope
            return $logFile
        }
        Default {
            Write-Verbose -Message "Logging disabled."
        }
    }
}