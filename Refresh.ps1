<#
    Feel free to change these varaibles as needed for your environment if needed.
#>

# Set the path to the environment variable file
$envFilePath = "$PSScriptRoot\override.env"

# Set the URL of the API you want to access
$apiUrl = "https://dbpool.datto.net/api/v2/containers"

# Define the path for the log file
$logFilePath = "$PSScriptRoot\logs\LogFile.log"

<#
    Please do not make any changes below this line unless you know what you are doing.
    If you would like to suggest a change, Pull Requests are always welcome.
#>

# Sets the Security Protocol for a .NET application to use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Check if the override.env file exists and import variables to session
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
    Write-Host "Override file does not exist at $envFilePath"
}

# Check if the variable $p_apiKey exists from override.env file, otherwise ask the user for their API key
if (-not (Test-Path variable:p_apiKey)) {
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
}

# Get the API key from environment variables
$apiKey = $env:apiKey
#Write-Host "apiKey value: $apiKey"

# Prepare headers with the API key
$headers = @{
    "X-App-Apikey" = $apiKey
}

# Make an API request with the API key in the headers
$getContainers = Invoke-WebRequest -Uri $apiUrl -Headers $headers -Method Get

# Display the response content
#Write-Host $getContainers.Content


# Convert JSON response to PowerShell object
$json = ConvertFrom-Json $getContainers

# Check if the directory of the log file exists, and create it if not
$logDirectory = [System.IO.Path]::GetDirectoryName($logFilePath)
if (-not (Test-Path $logDirectory)) {
    New-Item -Path $logDirectory -ItemType Directory
}
# Start recording the transcript
Start-Transcript -Path $logFilePath -Append
Write-Output "Logging Started."


# Extract and print the 'id' values under 'containers'
$json.containers | ForEach-Object {
    $ids = $_.id
    $names = $_.name

    # Perform API call for each 'id'
    $refreshUrl = "$apiUrl/${ids}/actions/refresh"
    $refreshResponse = Invoke-WebRequest -Uri $refreshUrl -Headers $headers -Method Post

    # Display the API response
    Write-Host "API Response for Refresh of container:${names}"
    $refreshResponse | ConvertTo-Json -Depth 4
}


# Stop recording the transcript
Write-Output "Logging Stopped."
Stop-Transcript

# Close Session
Exit-PSSession