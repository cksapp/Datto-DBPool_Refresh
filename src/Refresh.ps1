
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

.EXTERNALMODULEDEPENDENCIES DattoDBPool PowerShellGet

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
    # Functions Directory Path
    $functionsPath = Join-Path -path $PSScriptRoot -ChildPath "functions" -AdditionalChildPath "*.ps1"

    # Import functions
    $Functions = @( Get-ChildItem -Path $functionsPath -ErrorAction SilentlyContinue ) 
    foreach ($Import in @($Functions)) {
        try {
            . $Import.fullname
        } catch {
            throw "Could not import function $($Import.fullname): $_"
        }
    }

    #Import environment override variables
    . Import-Env

    # Specify the module name
    $moduleName = "DattoDBPool"

    # Check if the module is installed
    $installedModule = Get-InstalledModule $moduleName -ErrorAction SilentlyContinue
    $onlineModule = Find-Module -Name $moduleName

    if (!$installedModule) {
        try {
            Write-Output "Module $moduleName was not installed, attempting to install."
            Install-Module $moduleName -Force -ErrorAction Stop
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
        $Containers = Get-Containers -apiUrl $apiUrl -apiKey $apiKey -Verbose -varScope "$varScope"
        
        $Containers | ForEach-Object -Parallel {
            Import-Module -Name $using:moduleName -Force

            Write-Output "Refreshing Container $($_.name) with ID: $($_.id)."
            Sync-Containers -apiUrl $using:apiUrl -apiKey $using:apiKey -id $_.id -Verbose
        } -ThrottleLimit 10
    }

<#
    if (Test-ApiAvailability -apiUrl $apiUrl -apiKey $apiKey -Verbose) {
        $Containers = Get-Containers -apiUrl $apiUrl -apiKey $apiKey -Verbose -varScope "$varScope"
        
        $Containers | ForEach-Object -Parallel {
            Import-Module -Name $using:moduleName -Force

            Write-Output "Refreshing Container $($_.name) with ID: $($_.id)."
            Sync-Containers -apiUrl $using:apiUrl -apiKey $using:apiKey -id $_.id -Verbose
        } -ThrottleLimit 10
    }#>
}

End {

}