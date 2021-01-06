param
(
    [string][Parameter(Mandatory = $false)]$EnvironmentName = "AzureCloud",
    [string][parameter(Mandatory = $false)]$SubscriptionId = "",
    [string][parameter(Mandatory = $true)]$ResourceGroupName,
    [string][parameter(Mandatory = $true)]$LogicAppName,
    [string][Parameter(Mandatory = $false)]$ApiVersion = "2016-06-01",
    [string][parameter(Mandatory = $false)]$AccessToken = ""
)

try{
    if($SubscriptionId -eq "" -or $AccessToken -eq ""){
        # Request accessToken in case the script contains records
        $token = Get-AzCachedAccessToken

        $AccessToken = $token.AccessToken
        $SubscriptionId = $token.SubscriptionId
    }
    
    $fullUrl = . $PSScriptRoot\Get-AzLogicAppResourceManagementUrl.ps1 -EnvironmentName $EnvironmentName -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -ApiVersion $ApiVersion -Action enable
    
    Write-Host "Attempting to enable $LogicAppName"
    $params = @{
        Method = 'Post'
        Headers = @{ 
	        'authorization'="Bearer $AccessToken"
        }
        URI = $fullUrl
    }

    $web = Invoke-WebRequest @params -ErrorAction Stop
    Write-Host "Successfully enabled $LogicAppName" 
}
catch {
    Write-Warning "Failed to enable $LogicAppName"
    $ErrorMessage = $_.Exception.Message
    Write-Warning "Error: $ErrorMessage"
} 
