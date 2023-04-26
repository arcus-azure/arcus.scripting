param(
   [Parameter(Mandatory = $true)][string] $ProjectId = $(throw "ProjectId is required"),
   [Parameter(Mandatory = $true)][string] $BuildId = $(throw "BuildId is required"),
   [Parameter(Mandatory = $false)][int] $DaysToKeep
)

if ($DaysToKeep -eq '' -Or $DaysToKeep -eq 0) {
    $daysValid = 36501
} else {
    $daysValid = $DaysToKeep
}

$retentionPayload = @{ daysValid = $daysValid; definitionId = $env:SYSTEM_DEFINITIONID; ownerId = "User:$env:BUILD_REQUESTEDFORID"; protectPipeline = $true; runId = $BuildId };
$requestBody = ConvertTo-Json @($retentionPayload);

$collectionUri = $env:SYSTEM_COLLECTIONURI
if ($collectionUri.EndsWith('/') -eq $false) {
    $collectionUri = $collectionUri + '/'
}

$urlEncodedProjectId = [uri]::EscapeDataString($ProjectId)
$requestUri = "$collectionUri" + "$urlEncodedProjectId/_apis/build/retention/leases?api-version=7.0"

Write-Verbose "Saving Azure DevOps build for $daysValid days with build ID $BuildId in project $ProjectId by posting '$requestBody' to '$requestUri'..."
$response = Invoke-WebRequest -Uri $requestUri -Method Post -Body $requestBody -ContentType "application/json" -Headers @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }

if ($response.StatusCode -ne 200) {
    throw "Unable to retain Azure DevOps build with build ID $BuildId in project $ProjectId. API request returned statuscode $($response.StatusCode)"
}

if ($DaysToKeep -eq '') {
    Write-Host "Saved Azure DevOps build indefinitely with build ID $BuildId in project $ProjectId" -ForegroundColor Green
} else {
    Write-Host "Saved Azure DevOps build for $DaysToKeep days with build ID $BuildId in project $ProjectId" -ForegroundColor Green
}