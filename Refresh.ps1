## Set the URL of the API you want to access
$url = "https://dbpool.datto.net/api/v2/containers"

## Set the path to the environment variable file
$envFilePath = "$PSScriptRoot\override.env"

## Check if the Override.env file exists, otherwise ask the user for their API key
if (Test-Path -Path $envFilePath -PathType Leaf) {
    ## Read the file and convert it into key-value pairs
    $envVariables = Get-Content $envFilePath | ForEach-Object {
        $parts = $_ -split '='
        $key = $parts[0]
        $value = $parts[1]
        [PSCustomObject]@{
            Key = $key
            Value = $value
        }
    }

    ## Display the environment variables
    #foreach ($variable in $envVariables) {
    #    Write-Host "Key: $($variable.Key), Value: $($variable.Value)"
    #}
} else {
    $p_apiKey = Read-Host "Please enter your DBPool Personal API Key" -AsSecureString
}

## Prepare headers with the API key
$headers = @{
    "X-App-Apikey" = $($p_apiKey)
}

## Make an API request with the API key in the headers
$apiResponse = Invoke-WebRequest -Uri $url -Headers $headers -Method Get
#$ids = $apiResponse | Select-Object -ExpandProperty id

## Display the response content
$apiResponse.Content
#Write-Host "IDs: $ids"