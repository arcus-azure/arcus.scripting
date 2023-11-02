param(
    [Parameter(Mandatory = $false)][string] $EnvironmentName = "AzureCloud",
    [Parameter(Mandatory = $false)][string] $SubscriptionId = "",
    [Parameter(Mandatory = $true)][string] $ResourceGroupName = $(throw "Name of the resource group is required"),
    [Parameter(Mandatory = $true)][string] $LogicAppName = $(throw "Name of the logic app is required"),
    [Parameter(Mandatory = $false)][string] $WorkflowName = "",
    [Parameter(Mandatory = $false)][string] $ApiVersion = "2016-06-01",
    [Parameter(Mandatory = $false)][string] $AccessToken = ""
)

try{
    if($WorkflowName -eq "") {
        if($SubscriptionId -eq "" -or $AccessToken -eq ""){
            # Request accessToken in case the script contains records
            $token = Get-AzCachedAccessToken

            $AccessToken = $token.AccessToken
            $SubscriptionId = $token.SubscriptionId
        }

        $fullUrl = . $PSScriptRoot\Get-AzLogicAppConsumptionResourceManagementUrl.ps1 -EnvironmentName $EnvironmentName -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -ApiVersion $ApiVersion -Action "disable"
    
        Write-Verbose "Attempting to disable Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'..."
        $params = @{
            Method = 'Post'
            Headers = @{ 
                'authorization'="Bearer $AccessToken"
            }
            URI = $fullUrl
        }

        $web = Invoke-WebRequest @params -ErrorAction Stop
        Write-Host "Successfully disabled Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'" -ForegroundColor Green 
    } else {
        Set-AzAppServiceSetting -ResourceGroupName $ResourceGroupName -AppServiceName $LogicAppName -AppServiceSettingName "Workflows.$WorkflowName.FlowState" -AppServiceSettingValue "Disabled"
        Write-Host "Successfully disabled workflow '$WorkflowName' in Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'" -ForegroundColor Green
    }
}
catch {
    if($WorkflowName -eq "") {
        Write-Warning "Failed to disable Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'"
    } else {
        Write-Warning "Failed to disable workflow '$WorkflowName' in Azure Logic App '$LogicAppName' in resource group '$ResourceGroupName'"
    }
    $ErrorMessage = $_.Exception.Message
    Write-Debug "Error: $ErrorMessage"
}