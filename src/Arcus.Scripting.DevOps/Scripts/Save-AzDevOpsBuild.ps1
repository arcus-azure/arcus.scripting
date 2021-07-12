param(
   [Parameter(Mandatory = $true)][string] $ProjectId = $(throw "ProjectId is required"),
   [Parameter(Mandatory = $true)][string] $BuildId = $(throw "BuildId is required")   
)

$retentionPayload = @{        
  keepforever='true'
}

$requestBody = $retentionPayload | ConvertTo-Json -Depth 1 -Compress

$collectionUri = $env:SYSTEM_COLLECTIONURI

if( $collectionUri.EndsWith('/') -eq $False ){
  $collectionUri = $collectionUri + '/'
}

$requestUri = "$collectionUri" + "$ProjectId/_apis/build/builds/" + $BuildId + "?api-version=6.0"

Write-Verbose "Saving AzDevOps build with buildid $BuildId in project $ProjectId by posting $requestBody to $requestUri"

$response = Invoke-WebRequest -Uri $requestUri -Method Patch -Body $requestBody -ContentType "application/json" -Headers @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }      

if( $response.StatusCode -ne 200 ) {
    Throw "Unable to retain build indefinetely. API request returned statuscode $($response.StatusCode)"    
}

exit 0
