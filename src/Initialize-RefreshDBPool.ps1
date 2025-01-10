
<#PSScriptInfo

.VERSION 0.01

.GUID c629ccbe-5df8-4693-993d-94ecde3eccb8

.AUTHOR Kent Sapp (@CKSapp)

.COMPANYNAME

.COPYRIGHT '(c) 2024 Kent Sapp. All rights reserved.'

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


#>

<#

.DESCRIPTION
 Inital script to set default environment variables and setup on local machine. This script will install the necessary modules and dependencies for the DBPool_Refresh module to function properly.

#>
[CmdletBinding()]
Param(
    #[Parameter( Position = 0, Mandatory = $False, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]

)

# Pass the InformationAction parameter if bound, default to 'Continue'
if ($PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSBoundParameters['InformationAction'] } else { $InformationPreference = 'Continue' }

# Set the execution policy within the session scope
if ((Get-ExecutionPolicy) -ne "Bypass") {
    Set-ExecutionPolicy "Bypass" -Force -Scope Process
}

# Set Transport Layer Security (TLS) 1.2 or higher
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# Upgrade PowerShellGet according to https://learn.microsoft.com/en-us/powershell/gallery/powershellget/update-powershell-51?view=powershellget-3.x
# Archive URL: https://web.archive.org/web/20240701020907/https://learn.microsoft.com/en-us/powershell/gallery/powershellget/update-powershell-51?view=powershellget-3.x
if ( !( (Get-Module -Name PowerShellGet -ListAvailable -Verbose:$false).Version -gt '1.0.0.1') ) {
    # Install NuGet provider and PowerShellGet module
    try {
        Install-PackageProvider -Name NuGet -Scope CurrentUser -Force -ErrorAction Stop
        Install-Module -Name PowerShellGet -Force -AllowClobber -Scope CurrentUser -Repository PSGallery -ErrorAction Stop
    }
    catch {
        Write-Error $_
    }

    # Set the PSGallery repository as trusted
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
}

# Install PSResourceGet after upgrading PowerShellGet version based on https://learn.microsoft.com/en-us/powershell/gallery/powershellget/install-powershellget?view=powershellget-3.x
# Archive URL: https://web.archive.org/web/20240625180431/https://learn.microsoft.com/en-us/powershell/gallery/powershellget/install-powershellget?view=powershellget-3.x
if ( !(Get-Module -Name Microsoft.PowerShell.PSResourceGet -Verbose:$false -ListAvailable) ) {
    try {
        Install-Module -Name Microsoft.PowerShell.PSResourceGet -Force -AllowClobber -Scope CurrentUser -Repository PSGallery -ErrorAction Stop
    }
    catch {
        Write-Error $_
    }

    # Set the PSGallery repository as trusted
    Set-PSResourceRepository -Name PSGallery -Trusted -Confirm:$false -ErrorAction SilentlyContinue
}

# Install PowerShell Core on Windows
if ($PSEdition -eq 'Desktop') {
    try {
        # Check if pwsh is installed
        if (Get-Command pwsh -ErrorAction SilentlyContinue) {
            Write-Verbose 'PowerShell Core is already installed.'
            # Relaunch the script in the new PowerShell Core session
            $scriptPath = $PSCommandPath
            pwsh -NoExit -File $scriptPath -InformationAction:$InformationPreference -Verbose:$PSBoundParameters.ContainsKey('Verbose')
        } else {
            Write-Information 'PowerShell Core is not installed. Installing the latest version... This may take some time...'

            # Define the URL for the latest PowerShell Core installer
            $pwshInstallerUrl = 'https://github.com/PowerShell/PowerShell/releases/latest/download/PowerShell-7.4.6-win-x64.msi'
            $pwshInstallerHash = 'ED331A04679B83D4C013705282D1F3F8D8300485EB04C081F36E11EAF1148BD0'

            $pwshInstallerPath = Join-Path -Path $env:TEMP -ChildPath 'PowerShell-7.4.6-win-x64.msi'

            # Check if the installer file already exists
            if (-Not (Test-Path $pwshInstallerPath)) {
                # Download the installer
                try {
                    Invoke-WebRequest -Uri $pwshInstallerUrl -OutFile $pwshInstallerPath
                    Write-Verbose 'Installer downloaded successfully.'
                    # Verify the installer file exists
                    if (-Not (Test-Path $pwshInstallerPath)) {
                        Write-Error "Installer file not found at $pwshInstallerPath"
                        return
                    }
                } catch {
                    Write-Error "Failed to download the installer. Error: $_"
                    return
                }
            } else {
                Write-Verbose 'Installer already exists. Skipping download.'
                if ($(Get-FileHash -Path $pwshInstallerPath -Algorithm SHA256).Hash -ne $pwshInstallerHash) {
                    Write-Warning 'Installer file hash does not match. Redownloading...'
                    Remove-Item $pwshInstallerPath -ErrorAction SilentlyContinue
                    # Download the installer
                    try {
                        Invoke-WebRequest -Uri $pwshInstallerUrl -OutFile $pwshInstallerPath
                        Write-Verbose 'Installer downloaded successfully.'
                        # Verify the installer file exists
                        if (-Not (Test-Path $pwshInstallerPath)) {
                            Write-Error "Installer file not found at $pwshInstallerPath"
                            return
                        }
                    } catch {
                        Write-Error "Failed to download the installer. Error: $_"
                        return
                    }
                }
            }

            # Unblock the downloaded file
            try {
                Unblock-File -Path $pwshInstallerPath
                Write-Information 'Installer file unblocked successfully.'
            } catch {
                Write-Error "Failed to unblock the installer file. Error: $_"
                return
            }

            # Install PowerShell Core with additional parameters
            try {
                $process = Start-Process msiexec.exe -ArgumentList @(
                    '/package', $pwshInstallerPath, '/norestart',
                    'ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1',
                    'ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1',
                    'ENABLE_PSREMOTING=0',
                    'REGISTER_MANIFEST=1',
                    'USE_MU=1',
                    'ENABLE_MU=1',
                    'ADD_PATH=1'
                ) -PassThru -Wait

                if ($process.ExitCode -eq 0) {
                    Write-Information 'PowerShell Core has been installed successfully.'
                    # Relaunch the script in the new PowerShell Core session
                    & pwsh -File $MyInvocation.MyCommand.Path
                } else {
                    Write-Error "PowerShell Core installation failed with exit code $($process.ExitCode)."
                }
            } catch {
                Write-Error "$_"
            } finally {
                #Remove-Item $pwshInstallerPath -ErrorAction SilentlyContinue
            }
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
}

# Install dependencies for DattoDBPool module
# Install Microsoft.PowerShell.SecretManagement and Microsoft.PowerShell.SecretStore module for storing secrets
if (!(Get-InstalledPSResource -Name Microsoft.PowerShell.SecretStore -Verbose:$false -ErrorAction SilentlyContinue)) {
    try {
        Install-PSResource -Name Microsoft.PowerShell.SecretStore -Scope CurrentUser -Repository PSGallery -TrustRepository -Reinstall -ErrorAction Stop
    }
    catch {
        Write-Error $_
    }
}

# Install main Datto.DBPool.Refresh module
if (-not ((Get-InstalledPSResource -Name Datto.DBPool.Refresh -Verbose:$false -ErrorAction SilentlyContinue) -or (Get-Module -Name Datto.DBPool.Refresh -Verbose:$false -ListAvailable -ErrorAction SilentlyContinue))) {
    try {
        Install-PSResource -Name Datto.DBPool.Refresh -Scope CurrentUser -Repository PSGallery -TrustRepository -Reinstall -ErrorAction Stop
    }
    catch {
        Write-Error $_
    }
}

# Import the Datto.DBPool.Refresh module
if (-not (Get-Module -Name Datto.DBPool.Refresh -ListAvailable -Verbose:$false)) {
    try {
        Import-Module -Name Datto.DBPool.Refresh -Force -ErrorAction Stop
    }
    catch {
        throw $_
    }
}

# Set the environment variables for the Datto.DBPool.Refresh module
try {
    Add-DattoSecretStore -ErrorAction Stop

    Get-RefreshDBPoolApiKey -Verbose:$false -Force -ErrorAction Ignore -InformationAction SilentlyContinue
    if (!((Test-DBPoolApiKey -Verbose:$false -WarningAction SilentlyContinue -ErrorAction SilentlyContinue).StatusCode -eq 200)) {
        $apiKeyValid = $false
        $attempts = 0
        $maxAttempts = 3

        do {
            Read-Host -AsSecureString "Get API key from [ $(Get-DBPoolBaseURI)/web/self ]" | Set-RefreshDBPoolApiKey -Force -ErrorAction Stop
            Get-RefreshDBPoolApiKey -Force -ErrorAction Stop

            if (!(Test-DBPoolApi -WarningAction SilentlyContinue -ErrorAction SilentlyContinue)) {
                Write-Warning "DBPool API not available to test provided API key! Storing in the SecretManagement vault, use 'Set-RefreshDBPoolApiKey' to change the API key later if needed."
            } else {
                $apiKeyResponse = Test-DBPoolApiKey -Verbose:$false -ErrorAction SilentlyContinue
                if ($apiKeyResponse.StatusCode -eq 200) {
                    Write-Host 'DBPool API key tested successfully. Storing in the Secret Management Vault' -ForegroundColor Green
                    $apiKeyValid = $true
                } else {
                    Write-Warning "API key invalid. Remaining attempts: $($attempts+1) / $maxAttempts"
                    $attempts++
                    if ($attempts -ge $maxAttempts) {
                        throw "Maximum attempts reached. Please use 'Set-RefreshDBPoolApiKey' to try update the DBPool API key later."
                    }
                }
            }
        } until ($apiKeyValid -or -not (Test-DBPoolApi -WarningAction SilentlyContinue -ErrorAction SilentlyContinue))
    } elseif ((Test-DBPoolApiKey -Verbose:$false -WarningAction SilentlyContinue -ErrorAction SilentlyContinue).StatusCode -eq 200) {
        Write-Verbose 'API key retrieved from SecretManagement vault tested successfully'
    }
} catch {
    Write-Error $_
    Write-Warning 'An error occurred, please try to add the Datto Secret Store and API Key later on.'
}


# Create a scheduled task to run the Datto.DBPool.Refresh module
try {
    # Get shift start time
    $shiftStartTimeValid = $false
    $shiftRunOffsetHours = 1
    do {
        $shiftStartTime = Read-Host "Enter your shift start time (HH:mm). The script will run '$shiftRunOffsetHours' hour prior"
        try {
            [void][System.DateTime]::Parse($shiftStartTime)
            $shiftStartTimeValid = $true
        } catch {
            Write-Warning 'Invalid format. Please enter a valid start time.'
        }
    } until ($shiftStartTimeValid)
    $scriptRunTime = (Get-Date $shiftStartTime).AddHours(-($shiftRunOffsetHours)).ToString('HH:mm')


    # Get days of the week to exclude
    $defaultExcludedDays = 'Saturday,Sunday'
    $validDaysOfWeek = [Enum]::GetNames([System.DayOfWeek])

    do {
        $inputDays = Read-Host "Enter the days of the week to exclude (comma-separated, default is $defaultExcludedDays). Enter 'none' to run every day"
        if ($inputDays -eq 'none') {
            $excludedDays = $null
            $excludeDaysValid = $true
        } elseif ([string]::IsNullOrWhiteSpace($inputDays)) {
            $excludedDays = $defaultExcludedDays -split ','
            $excludeDaysValid = $true
        } else {
            $excludedDays = $inputDays -split ',' | ForEach-Object { $_.Trim() }
            $daysToExclude = @()
            $excludeDaysValid = $true
            foreach ($day in $excludedDays) {
                $matchedDay = $validDaysOfWeek | Where-Object { $_.StartsWith($day, 'InvariantCultureIgnoreCase') }
                if ($matchedDay.Count -eq 1) {
                    $daysToExclude += $matchedDay
                } else {
                    $excludeDaysValid = $false
                    Write-Warning "Invalid day '$day'. Please enter valid days of the week."
                    break
                }
            }
            if ($excludeDaysValid) {
                $excludedDays = $daysToExclude
            }
        }
    } until ($excludeDaysValid)

    Register-RefreshDBPoolTask -TriggerTime $scriptRunTime -ExcludedDaysOfWeek $excludedDays -ErrorAction Stop | Out-Null
    $daysToRun = $( [System.DayOfWeek].GetEnumValues() ) | Where-Object { $ExcludedDaysOfWeek -notcontains $_ }
    Write-Host "Scheduled task created to run the 'Datto.DBPool.Refresh' module at $scriptRunTime on $($daysToRun -join ', ')." -ForegroundColor Green
}
catch {
    Write-Warning "An error occurred, please use 'Register-RefreshDBPoolTask' to create the scheduled task later on."
    Write-Error $_
}


# Clone the parent container(s) to create child containers
Write-Host 'Attempting to clone parent containers to create DBPool containers...'
try {
    $modulePath = if (Get-Command Copy-DBPoolParentContainer -Verbose:$false -ErrorAction SilentlyContinue) {
        ((Get-Command Copy-DBPoolParentContainer -Verbose:$false -ErrorAction SilentlyContinue).Module).Path
    } else {
        (Get-Module -Name Datto.DBPool.Refresh -Verbose:$false -ListAvailable -ErrorAction SilentlyContinue).Path
    }
    $runspace = [powershell]::Create().AddScript({
            param ($modulePath)
            try {
                Import-Module -Name $modulePath
                Copy-DBPoolParentContainer -Id @(17, 27, 14) -Verbose
                Start-Sleep -Seconds 5
            } catch {
                Write-Error "Error in runspace execution: $_"
            }
        }).AddArgument($modulePath)

    # Start the runspace
    $handle = $runspace.BeginInvoke()

    # Wait for a specified amount of time (e.g., 60 seconds)
    $timeoutSeconds = 20
    $startTime = Get-Date

    while ($true) {
        # Process output streams from the runspace based on [Microsoft KB](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_output_streams)
        # Check for new information messages
        while ($runspace.Streams.Information.Count -gt 0) {
            $info = $runspace.Streams.Information[0]
            Write-Information $info.MessageData
            $runspace.Streams.Information.RemoveAt(0)
        }
        # Check for new debug messages
        while ($runspace.Streams.Debug.Count -gt 0) {
            $debug = $runspace.Streams.Debug[0]
            Write-Debug $debug.Message
            $runspace.Streams.Debug.RemoveAt(0)
        }
        # Check for new verbose messages
        while ($runspace.Streams.Verbose.Count -gt 0) {
            $verbose = $runspace.Streams.Verbose[0]
            Write-Verbose $verbose.Message
            $runspace.Streams.Verbose.RemoveAt(0)
        }
        # Check for new warning messages
        while ($runspace.Streams.Warning.Count -gt 0) {
            $warning = $runspace.Streams.Warning[0]
            Write-Warning $warning.Message
            $runspace.Streams.Warning.RemoveAt(0)

        }
        # Check for new error messages
        while ($runspace.Streams.Error.Count -gt 0) {
            $runspaceError = $runspace.Streams.Error[0]
            Write-Error $runspaceError.Exception.Message
            $runspace.Streams.Error.RemoveAt(0)
        }

        if ($handle.IsCompleted) {
            try {
                # Check for errors in the runspace
                $runspace.EndInvoke($handle)
                if ($runspace.Streams.Error.Count -gt 0) {
                    foreach ($runspaceError in $runspace.Streams.Error) {
                        Write-Error "'Copy-DBPoolParentContainer' encountered an error: $($runspaceError.Exception.Message)"
                    }
                } else {
                    Write-Host "Parent container(s) 'clone' command sent. Review at [ $( (Get-DBPoolBaseURI) + '/web/containers' ) ] " -ForegroundColor Blue
                }
            } catch {
                Write-Error "'Copy-DBPoolParentContainer' encountered an error: $_"
            }
            break
        }

        $elapsedTime = (Get-Date) - $startTime
        if ($elapsedTime.TotalSeconds -ge $timeoutSeconds) {
            Write-Error "Timeout of '$timeoutSeconds' exceeded. Parent container(s) 'clone' command may not have completed. Review at [ $( (Get-DBPoolBaseURI) + '/web/containers' ) ]"
            break
        }

        Start-Sleep -Seconds 1
    }
}
catch {
    Write-Error $_
    Write-Warning "An error occurred, manually clone the parent containers to create DBPool containers at [ $((Get-DBPoolBaseURI) + '/web/containers' ) ]."
}
finally {
    if (-not $handle.IsCompleted) {
        $runspace.Stop()
        Write-Debug "'Copy-DBPoolParentContainer' runspace was stopped."
    }

    $runspace.Dispose()
}

# Export the module settings and prompt the user for any configuration changes
Export-RefreshDBPoolModuleSetting -Verbose -ErrorAction Stop
$userConfigChoice = Read-Host 'Would you like to make any configuration changes now? (yes/no)'
if ($userConfigChoice -imatch '^(yes|y)$') {
    Get-RefreshDBPoolModuleSetting -openConfFile -ErrorAction Stop
}
