# This is an example override.env file, accepts lines commented out with `#`
$variables = @{
    # Container IDs to refresh, by default all containers will be refreshed
    #ids = @(1, 2, 3)

    # Enter your API key from DBPool
    #apiKey = "your_api_key_here"

    # URL of the API to be checked, defaulted to "https://dbpool.datto.net" in the script already and should not need to be changed or uncommented.
    #apiUrl = "https://dbpool.datto.net"
}

# Loop through the hashtable and create variables with default values
foreach ($variableName in $variables.Keys) {
    New-Variable -Name $variableName -Value $variables[$variableName] -Force
    Write-Verbose -Message "Variable `$$variableName imported."
}