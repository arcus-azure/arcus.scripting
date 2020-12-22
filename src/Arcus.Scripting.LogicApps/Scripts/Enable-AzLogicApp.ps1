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
        $token = . $PSScriptRoot\Get-AzCachedAccessToken.ps1

        $Global:acces_token = $token.AccessToken
        $Global:subscriptionId = $token.SubscriptionId
    }
    else{
        $Global:acces_token = $AccessToken
        $Global:subscriptionId = $SubscriptionId
    }
    
    Write-Host "Attempting to enable $LogicAppName"
    $params = @{
        Method = 'Post'
        Headers = @{ 
	        'authorization'="Bearer $Global:acces_token"
        }
        URI = "https://management.azure.com/subscriptions/$Global:subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows/$LogicAppName/enable?api-version=2016-06-01"
    }

    $web = Invoke-WebRequest @params -ErrorAction Stop
    Write-Host "Successfully enabled $LogicAppName" 
}
catch {
    Write-Warning "Failed to enable $LogicAppName"
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
} 
