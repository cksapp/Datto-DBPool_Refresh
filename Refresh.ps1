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
    # Read the file and convert it into key-value pairs
    $envVariables = Get-Content $envFilePath | ForEach-Object {
        $line = $_.Trim()
        $name, $value = $line -split '=', 2
        [PSCustomObject]@{
            Name = $name
            Value = $value
        }
    }

    # Import variables into the current session
    $envVariables | ForEach-Object {
        $envName = $_.Name
        $envValue = $_.Value
        Write-Host "Overriding variable: $envName with value: $envValue"
        Set-Item -Path "env:$envName" -Value $envValue
    }

    # Display the environment variables
    #$envVariables | ForEach-Object {
    #    Write-Host "Variable: $($_.Name), Value: $($_.Value)"
    #}
} else {
    $p_apiKeySecure = Read-Host "Please enter your DBPool Personal API Key" -AsSecureString
    # Convert the secure string to a plain text string
    $p_apiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p_apiKeySecure))
}

# Prepare headers with the API key
$headers = @{
    "X-App-Apikey" = $p_apiKey
}

# Make an API request with the API key in the headers
$getContainers = Invoke-WebRequest -Uri $url -Headers $headers -Method Get

# Convert JSON to PowerShell object
$json = ConvertFrom-Json $getContainers
# Extract and print the 'id' values under 'containers'
$json.containers | ForEach-Object {
    $id = $_.id

    # Perform API call for each 'id'
    $refreshUrl = "$url/$id/actions/refresh"
    $refreshResponse = Invoke-WebRequest -Uri $refreshUrl -Headers $headers -Method Get 

    # Display the API response
    Write-Host "API Response for Refresh ${id}:"
    $refreshResponse | ConvertTo-Json -Depth 4
}

# $apiResponse = 
# Display the response content
#$apiResponse.Content
#Write-Host "IDs: $ids"

# Close Session
#Exit-PSSession