
<#PSScriptInfo

.VERSION 2023.11.0

.GUID 74cd4100-d57e-4660-b681-39148119afd3

.AUTHOR Kent Sapp

.COMPANYNAME

.COPYRIGHT © 2023 Kent sapp. All rights reserved.

.TAGS

.LICENSEURI https://github.com/cksapp/Datto-DBPool_Refresh/blob/main/LICENSE

.PROJECTURI https://github.com/cksapp/Datto-DBPool_Refresh

.ICONURI

.EXTERNALMODULEDEPENDENCIES DattoDBPool

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>


<# 

.DESCRIPTION 
 PowerShell script to `Refresh` all child containers in Datto (Kaseya) DBPool, this can be combined with Scheduled Tasks in Windows or a Cron job to automate the refresh script on a set interval. 

#> 
[CmdletBinding(SupportsShouldProcess)]
Param(
    [Parameter(
        Position = 0, 
        Mandatory = $False, 
        ValueFromPipeline = $True, 
        ValueFromPipelineByPropertyName = $True
    )]
    $apiUrl = "https://dbpool.datto.net",

    [Parameter(
        Position = 1, 
        Mandatory = $False, 
        ValueFromPipeline = $True, 
        ValueFromPipelineByPropertyName = $True
    )]
    $apiKey,

    [Parameter(
        Position = 2,
        Mandatory = $False,
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True,
        HelpMessage = "Set the wait timeout in seconds."
    )]
    $waitSeconds = 0,

    [Parameter(
        Position = 3,
        Mandatory = $False,
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True
    )]
    [Boolean]$Logging = $False,

    [Parameter(
        Position = 4,
        Mandatory = $False,
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True
    )]
    [String]$logPath = $(Get-Location),

    [Parameter(
        Mandatory = $False,
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True
    )]
    $VariableScope = "Global"
)

Begin {
    # Set the execution policy within the session scope
    if ((Get-ExecutionPolicy) -ne "Bypass") {
        Set-ExecutionPolicy "Bypass" -Force -Scope Process
    }

    # Runs check for NuGet provider and installed minimum version
    if ($(Get-PackageProvider -Name "NuGet" -Force).version -lt "2.8.5.201") {
        Install-PackageProvider -Name "Nuget" -MinimumVersion "2.8.5.201" -Force
        Install-Module PowerShellGet -AllowClobber -Force
    }


    # Specify the module name
    $moduleName = "DattoDBPool"

    # Check if the module is installed
    $installedModule = Get-InstalledModule $moduleName -ErrorAction SilentlyContinue
    $onlineModule = Find-Module -Name $moduleName

    if (!$installedModule) {
        try {
            Write-Output "Module $moduleName was not installed, attempting to install."
            Install-Module $moduleName -Scope "CurrentUser" -Force -ErrorAction Stop
            Write-Output "Module $moduleName installed successfully."
        } catch {
            Write-Error "Error installing module $moduleName`: $_"
            throw
        }
    } else {
        Write-Verbose -Message "Module $moduleName is already installed."
        
        #Update the module if the version is higher
        if ($installedModule.version -lt $onlineModule.version) {
            Write-Verbose -Message "Updating $moduleName from version $installedModule.version to $onlineModule.version."
            Update-Module -Name $moduleName -Scope "CurrentUser" -Force
        } elseif ($installedModule.version -eq $onlineModule.version) {
            Write-Verbose -Message "$moduleName version installed is $installedModule.version which matches $onlineModule.version."
        }
    }

    # Imports the required Module into the scope
    Import-Module -Name $moduleName -Force


    #Import environment override variables
    . Import-Env -Verbose -VariableScope $VariableScope

    # Set logs
    . Set-Logging -logPath $logPath -doLogs $Logging -VariableScope "Global"
    if (![string]::IsNullOrEmpty($logFile)) {
        Start-Transcript -Path $logFile -NoClobber -Append
    }
    
    # Set the security for the session, defaults to TLS 1.2
    Set-SecurityProtocol
}

Process {
    

    # Set API parameters
    If ($apiUrl -and $apiKey) {
        Set-DdbpApiParameters -apiUrl $apiUrl -apiKey $apiKey -VariableScope "$VariableScope"
    }

    switch ($true) {
        # If $ids variable is set from override then get the container details, and perform Refresh task.
        { $ids } {
            # Get Containers only if API is available
            if (Test-ApiAvailability -apiUrl $apiUrl -apiKey $apiKey -Verbose) {
                $refreshJobs = @()

                $ids | ForEach-Object {
                    $id = $_

                    $refreshJobs += Start-Job -ScriptBlock {
                        param (
                            $id
                        )
                        Import-Module -Name $using:moduleName -Force
                        Write-Output "Starting Refresh job for container ID: $id."
                        Sync-Containers -apiUrl $using:apiUrl -apiKey $using:apiKey -id $id -Verbose
                    } -ArgumentList $id
                }

                # Wait for all jobs to complete with a timeout
                $null = $refreshJobs | Wait-Job -Timeout $waitSeconds

                # Retrieve all jobs (completed and potentially still running)
                $allJobs = Get-Job

                # Filter completed jobs
                $completedJobs = $allJobs | Where-Object { $_.State -eq 'Completed' }

                # Receive results from completed jobs
                $jobResults = Receive-Job -Job $completedJobs

                # Handle the results as needed
                foreach ($result in $jobResults) {
                    Write-Output $result
                }

                # Remove all jobs (optional)
                Remove-Job -Job $allJobs
            } else {
                Write-Output "API is not reachable, check the parameters and try again."
            }
        }

        # Default case when $ids are set
        Default {
            # Get Containers only if API is available
            if (Test-ApiAvailability -apiUrl $apiUrl -apiKey $apiKey -Verbose) {
                $Containers = Get-Containers -apiUrl $apiUrl -apiKey $apiKey -Verbose -VariableScope "$VariableScope"
                $refreshJobs = @()

                $Containers | ForEach-Object {
                    $name = $_.name
                    $id = $_.id

                    $refreshJobs += Start-Job -ScriptBlock {
                        param (
                            $name,
                            $id
                        )
                        Import-Module -Name $using:moduleName -Force
                        Write-Output "Starting Refresh job for container $name with ID: $id."
                        Sync-Containers -apiUrl $using:apiUrl -apiKey $using:apiKey -id $id -Verbose
                    } -ArgumentList $name, $id
                }

                # Wait for all jobs to complete with a timeout
                $null = $refreshJobs | Wait-Job -Timeout $waitSeconds

                # Retrieve all jobs (completed and potentially still running)
                $allJobs = Get-Job

                # Filter completed jobs
                $completedJobs = $allJobs | Where-Object { $_.State -eq 'Completed' }

                # Receive results from completed jobs
                $jobResults = Receive-Job -Job $completedJobs

                # Handle the results as needed
                foreach ($result in $jobResults) {
                    Write-Output $result
                }

                # Remove all jobs (optional)
                Remove-Job -Job $allJobs
            } else {
                Write-Output "API is not reachable, check the parameters and try again."
            }
        }        
    }
}

End {
    Stop-Transcript
    $null = $apiKey
    exit
}