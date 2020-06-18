param(
    [Parameter(Mandatory=$true)][string]$Action = $(throw "Action is required [Start|Stop]"),
    [Parameter(Mandatory=$true)][string]$ResourceGroupName = $(throw "ResourceGroup is required"),
    [Parameter(Mandatory=$true)][string]$DataFactoryName = $(throw "The name of the data factory is required"),
    [Parameter(Mandatory=$true)][string]$DataFactoryTriggerName = $(throw "The name of the trigger is required"),
    [Parameter(Mandatory=$false)][switch]$FailWhenTriggerIsNotFound = $false
)

try
{
    $dataFactory = Get-AzDataFactoryV2 -ResourceGroupName $ResourceGroupName -Name $DataFactoryName -ErrorAction Stop
}
catch
{
    throw "Error finding data factory '$DataFactoryName' in resource group '$ResourceGroupName'"
}

try 
{
    $DataFactoryTrigger = Get-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $DataFactoryTriggerName -ErrorAction Stop
}
catch 
{
    $message = "Error retrieving trigger '$DataFactoryTriggerName' in data factory '$DataFactoryName'"
    if($FailWhenTriggerIsNotFound)
    {
        throw $message
    }
    else 
    {
        Write-Host $message
        Write-Host "Skipping the '$Action'-operation."
        return
    }
}

if($Action -eq "Start")
{
    try 
    {
        if($null -ne $DataFactoryTrigger)
        {
            $succeeded = Start-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $DataFactoryTriggerName -Force -ErrorAction Stop
            Write-Host "The trigger '$DataFactoryTriggerName' has been started."
        }
    }
    catch 
    {
        throw "Error starting trigger '$DataFactoryTriggerName' in data factory '$DataFactoryName'"
    }
}

if($Action -eq "Stop")
{
    try 
    {
        if($null -ne $DataFactoryTrigger)
        {
            $succeeded = Stop-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $DataFactoryTriggerName -Force -ErrorAction Stop
            Write-Host "The trigger '$DataFactoryTriggerName' has been stopped."
        }
    }
    catch 
    {
        throw "Error stopping trigger '$DataFactoryTrigger' in data factory '$DataFactoryName'"
    }
}