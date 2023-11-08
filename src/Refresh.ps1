
<#PSScriptInfo

.VERSION 2023.11.0

.GUID 74cd4100-d57e-4660-b681-39148119afd3

.AUTHOR Kent Sapp

.COMPANYNAME

.COPYRIGHT © 2023 Kent sapp. All rights reserved.

.TAGS

.LICENSEURI https://github.com/cksapp/DBPool_Refresh/blob/main/LICENSE

.PROJECTURI https://github.com/cksapp/DBPool_Refresh

.ICONURI

.EXTERNALMODULEDEPENDENCIES DattoDBPool, PowerShellGet

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
        Mandatory = $False,
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True
    )]
    $varScope = "Script"
)

Begin {
    # Set the execution policy within the session scope
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process


    # Specify the module name
    $moduleName = "DattoDBPool"

    # Check if the module is installed
    $installedModule = Get-InstalledModule $moduleName -ErrorAction SilentlyContinue
    $onlineModule = Find-Module -Name $moduleName

    if (!$installedModule) {
        try {
            Write-Output "Module $moduleName was not installed, attempting to install."
            Install-Module $moduleName -Scope CurrentUser -Force -ErrorAction Stop
            Write-Output "Module $moduleName installed successfully."
        } catch {
            Write-Error "Error installing module $moduleName`: $_"
            throw
        }
    } else {
        Write-Verbose -Message "Module $moduleName is already installed."
        
        #Update the module if the version is higher
        if ($installedModule.version -lt $onlineModule.version) {
            Write-Verbose -Message "Updating $moduleName from version $installedModuleVersion to $onlineModuleVersion."
            Update-Module -Name $moduleName -Force
        } elseif ($installedModule.version -eq $onlineModule.version) {
            Write-Verbose -Message "$moduleName version installed is $installedModuleVersion which matches $onlineModuleVersion."
        }
    }

    #Import environment override variables
    . Import-Env -Verbose
}

Process {
    Import-Module -Name $moduleName -Force
    Set-SecurityProtocol

    # Set API parameters
    If ($apiUrl -and $apiKey) {
        Set-DdbpApiParameters -apiUrl $apiUrl -apiKey $apiKey -varScope "$varScope"
    }

    # Get Containers only if API is available
    while (Test-ApiAvailability -apiUrl $apiUrl -apiKey $apiKey -Verbose) {
        $timeoutSeconds = 60  # Set the timeout in seconds
        $Containers = Get-Containers -apiUrl $apiUrl -apiKey $apiKey -Verbose -varScope "$varScope"
        
        $Containers | ForEach-Object {
            $name = $_.name
            $id = $_.id

            Start-Job -ScriptBlock {
                param (
                    $name,
                    $id
                )
                Import-Module -Name $using:moduleName -Force

                Write-Output "Refreshing Container $name with ID: $id."
                Sync-Containers -apiUrl $using:apiUrl -apiKey $using:apiKey -id $id -Verbose
            } -ArgumentList $name, $id
        }

        # Wait for all jobs to complete with a timeout
        $null = $jobs | Wait-Job -Timeout $timeoutSeconds

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
    }
}

End {

}