param
(
    [string][parameter(Mandatory = $false)]$SubscriptionId = "",
    [string][parameter(Mandatory = $true)]$ResourceGroupName,
    [string][parameter(Mandatory = $true)]$LogicAppName,
    [string][parameter(Mandatory = $false)]$AccessToken = ""
)

try{
    if($SubscriptionId -eq "" -or $AccessToken -eq ""){
        # Request accessToken in case the script contains records
        $token = Get-AzCachedAccessToken

        $AccessToken = $token.AccessToken
        $SubscriptionId = $token.SubscriptionId
    }
    
    Write-Host "Attempting to disable $LogicAppName"
    $params = @{
        Method = 'Post'
        Headers = @{ 
	        'authorization'="Bearer $AccessToken"
        }
        URI = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows/$LogicAppName/disable?api-version=2016-06-01"
    }

    $web = Invoke-WebRequest @params -ErrorAction Stop
    Write-Host "Successfully disabled $LogicAppName" 
}
catch {
    Write-Warning "Failed to disable $LogicAppName"
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
} 
