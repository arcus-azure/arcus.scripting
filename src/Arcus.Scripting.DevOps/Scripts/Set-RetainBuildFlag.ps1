param(
   [Parameter(Mandatory = $true)][string] $OrganizationName = $(throw "The name of the organization is required"),
   [Parameter(Mandatory = $true)][string] $ProjectId = $(throw "ProjectId is required"),
   [Parameter(Mandatory = $true)][string] $BuildId = $(throw "BuildId is required"),
   [Parameter(Mandatory = $true)][string] $AccessToken = $(throw "An access Token for the DevOps API is required")
)

$retentionPayload = @{        
  keepforever='true'
}

$requestBody = $retentionPayload | ConvertTo-Json -Depth 100

$requestUri = "https://dev.azure.com/$OrganizationName/$ProjectId/_apis/build/builds/" + $BuildId + "?api-version=6.0"

$response = Invoke-WebRequest -Uri $requestUri -Method Patch -Body $requestBody -ContentType "application/json" -Headers @{ Authorization = "Bearer $accessToken" }      

if ($response.StatusCode -ne 200) {
    Write-Error "Unable to retain build indefinetely. API request returned statuscode $($response.StatusCode)"
    exit 1
}

exit 0
