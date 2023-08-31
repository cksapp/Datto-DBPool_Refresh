<#
    Feel free to change these varaibles as needed for your environment if needed.
#>

# Set the path to the environment variable file
$envFilePath = "$PSScriptRoot\override.env"

# Set the URL of the API you want to access
$url = "https://dbpool.datto.net/api/v2/containers"

<#
    Please do not make any changes below this line unless you know what you are doing.
    If you would like to suggest a change, Pull Requests are always welcome.
#>

# Sets the Security Protocol for a .NET application to use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Check if the Override.env file exists, otherwise ask the user for their API key
if (Test-Path -Path $envFilePath -PathType Leaf) {
    $envLines = Get-Content -Path $envFilePath

    foreach ($line in $envLines) {
        $line = $line.Trim()
        if (-not [string]::IsNullOrWhiteSpace($line) -and $line -match '^(.*?)=(.*)$') {
            $envName = $matches[1]
            $envValue = $matches[2]
            Write-Host "Setting environment variable: $envName=$envValue"
            [Environment]::SetEnvironmentVariable($envName, $envValue, "Process")
        }
    }
} else {
    $apiKeySecure = Read-Host "Please enter your DBPool Personal API Key" -AsSecureString
    # Convert the secure string to a plain text string
    $p_apiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKeySecure))
    
    # Set environment variable using [Environment]::SetEnvironmentVariable
    [Environment]::SetEnvironmentVariable("apiKey", $p_apiKey, "Process")

    # Clear plaintext variable
    $p_apiKey = $null
    # Dispose of the SecureString to minimize its exposure in memory
    $apiKeySecure.Dispose()
}

# Get the API key from environment variables
$apiKey = $env:apiKey
#Write-Host "apiKey value: $apiKey"

# Prepare headers with the API key
$headers = @{
    "X-App-Apikey" = $apiKey
}

# Make an API request with the API key in the headers
$getContainers = Invoke-WebRequest -Uri $url -Headers $headers -Method Get

# Convert JSON to PowerShell object
$json = ConvertFrom-Json $getContainers
# Extract and print the 'id' values under 'containers'
$json.containers | ForEach-Object {
    $id = $_.id

    # Perform API call for each 'id'
    $refreshUrl = "$url/${id}/actions/refresh"
    $refreshResponse = Invoke-WebRequest -Uri $refreshUrl -Headers $headers -Method Post

    # Display the API response
    Write-Host "API Response for Refresh of container ID:${id}"
    $refreshResponse | ConvertTo-Json -Depth 4
}

# $apiResponse = 
# Display the response content
#$apiResponse.Content

# Close Session
Exit-PSSession