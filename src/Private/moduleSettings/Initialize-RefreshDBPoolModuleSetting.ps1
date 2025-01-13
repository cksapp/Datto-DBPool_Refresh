# Used to auto load either baseline settings or saved configurations when the module is imported
Import-RefreshDBPoolModuleSetting -Verbose:$VerbosePreference

if (Test-SecretVault -Name 'Datto_SecretStore' -WarningAction SilentlyContinue -ErrorAction SilentlyContinue) {
    try {
        Get-RefreshDBPoolApiKey -Force -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning $_
    }
}
