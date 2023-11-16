---
title: "Azure Logic Apps - Consumption"
layout: default
---

# Azure Logic Apps - Consumption

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.LogicApps
```

## Cancel running instances for an Azure Logic App

Use this script to cancel all running instances for a specific Azure Logic App. 

| Parameter                   | Mandatory | Description                                                                                                                                         |
| --------------------------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`         | yes       | The resource group containing the Azure Logic App.                                                                                                  |
| `LogicAppName`              | yes       | The name of the Azure Logic App for which the runs will be cancelled.                                                                               |
| `MaximumFollowNextPageLink` | no        | This sets the amount of pages (30 runs per page) of the Logic App run history (if any) that are retrieved. If not supplied the default value is 10. |

**Example**

Taking an example in which a specific Azure Logic App (`"rcv-shopping-order-sftp"`) needs to have all its runs cancelled.  

```powershell
PS> Cancel-AzLogicAppRuns `
-ResourceGroupName "rg-common-dev" `
-LogicAppName "rcv-shopping-order-sftp"
# Successfully cancelled all running instances for the Azure Logic App 'rcv-shopping-order-sftp' in resource group 'rg-common-dev'
```

## Resubmitting failed instances for an Azure Logic App

Use this script to re-run a failed Azure Logic App run. 

| Parameter                   | Mandatory | Description                                                                                                                                         |
| --------------------------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName`         | yes       | The resource group containing the Azure Logic App.                                                                                                  |
| `LogicAppName`              | yes       | The name of the Azure Logic App for which the failed runs will be resubmitted.                                                                      |
| `StartTime`                 | yes       | The start time in UTC for retrieving the failed instances.                                                                                          |
| `EndTime`                   | no        | The end time in UTC for retrieving the failed instances, if not supplied it will use the current datetime.                                          |
| `MaximumFollowNextPageLink` | no        | This sets the amount of pages (30 runs per page) of the Logic App run history (if any) that are retrieved. If not supplied the default value is 10. |

**Example**

Taking an example in which a specific Azure Logic App (`"rcv-shopping-order-sftp"`) needs to have all its failed runs resubmitted from 2023-05-01 00:00:00.  

```powershell
PS> Resubmit-FailedAzLogicAppRuns `
-ResourceGroupName "rg-common-dev" `
-LogicAppName "rcv-shopping-order-sftp" `
-StartTime "2023-05-01 00:00:00"
# Successfully resubmitted all failed instances for the Azure Logic App 'rcv-shopping-order-sftp' in resource group 'rg-common-dev' from '2023-05-01 00:00:00'
```

Taking an example in which a specific Azure Logic App (`"rcv-shopping-order-sftp"`) needs to have all its failed runs resubmitted from 2023-05-01 00:00:00 until 2023-05-01 10:00:00.  

```powershell
PS> Resubmit-FailedAzLogicAppRuns `
-ResourceGroupName "rg-common-dev" `
-LogicAppName "rcv-shopping-order-sftp" `
-StartTime "2023-05-01 00:00:00" `
-EndTime "2023-05-01 10:00:00"
# Successfully resubmitted all failed instances for the Azure Logic App 'rcv-shopping-order-sftp' in resource group 'rg-common-dev' from '2023-05-01 00:00:00' and until '2023-05-01 10:00:00'
```

## Disable an Azure Logic App

Use this script to enable a specific Azure Logic App.  

| Parameter           | Mandatory | Description                                                                                                         |
| ------------------- | --------- | ------------------------------------------------------------------------------------------------------------------- |
| `EnvironmentName`   | no        | The name of the Azure environment where the Azure Logic App resides. (default: `AzureCloud`)                        |
| `SubscriptionId`    | no        | The Id of the subscription containing the Azure Logic App.                                                          |
|                     |           | When not provided, it will be retrieved from the current context (Get-AzContext).                                   |
| `ResourceGroupName` | yes       | The resource group containing the Azure Logic Apps.                                                                 |
| `LogicAppName`      | yes       | The name of the Azure Logic App to be disabled.                                                                     |
| `ApiVersion`        | no        | The version of the management API to be used.  (default: `2016-06-01`)                                              |
| `AccessToken`       | no        | The access token to be used to disable the Azure Logic App.                                                         |
|                     |           | When not provided, it will be retrieved from the current context (Get-AzContext).                                   |

**Example**

Taking an example in which a specific Azure Logic App (`"rcv-shopping-order-sftp"`) needs to be disabled, without providing the subscriptionId or accesstoken.  

```powershell
PS> Disable-AzLogicApp `
-ResourceGroupName "rg-common-dev" `
-LogicAppName "rcv-shopping-order-sftp"
# Successfully disabled Azure Logic App 'rcv-shopping-order-sftp' in resource group 'rg-common-dev'
```

Taking an example in which a specific Azure Logic Apps (`"rcv-shopping-order-sftp"`) needs to be disabled, with providing the subscriptionId or accesstoken.  

```powershell
PS> Disable-AzLogicApp `
-SubscriptionId $SubscriptionId `
-ResourceGroupName "rg-common-dev" `
-LogicAppName "rcv-shopping-order-sftp" `
-AccessToken $AccessToken
# Successfully disabled Azure Logic App 'rcv-shopping-order-sftp' in resource group 'rg-common-dev'
```

## Enable an Azure Logic App

Use this script to enable a specific Azure Logic App.  

| Parameter           | Mandatory | Description                                                                                                         |
| ------------------- | --------- | ------------------------------------------------------------------------------------------------------------------- |
| `EnvironmentName`   | no        | The name of the Azure environment where the Azure Logic App resides. (default: `AzureCloud`)                        |
| `SubscriptionId`    | no        | The Id of the subscription containing the Azure Logic App.                                                          |
|                     |           | When not provided, it will be retrieved from the current context (Get-AzContext).                                   |
| `ResourceGroupName` | yes       | The resource group containing the Azure Logic Apps.                                                                 |
| `LogicAppName`      | yes       | The name of the Azure Logic App to be enabled.                                                                      |
| `ApiVersion`        | no        | The version of the management API to be used.  (default: `2016-06-01`)                                              |
| `AccessToken`       | no        | The access token to be used to enable the Azure Logic App.                                                          |
|                     |           | When not provided, it will be retrieved from the current context (Get-AzContext).                                   |

**Example**

Taking an example in which a specific Azure Logic Apps (`"rcv-shopping-order-sftp"`) needs to be enabled, without providing the subscriptionId or accesstoken.  

```powershell
PS> Enable-AzLogicApp `
-ResourceGroupName "rg-common-dev" `
-LogicAppName "rcv-shopping-order-sftp"
# Successfully enabled Azure Logic App 'rcv-shopping-order-sftp' in resource group 'rg-common-dev'
```

Taking an example in which a specific Azure Logic App (`"rcv-shopping-order-sftp"`) needs to be enabled, with providing the subscriptionId or accesstoken.  

```powershell
PS> Enable-AzLogicApp `
-SubscriptionId $SubscriptionId `
-ResourceGroupName "rg-common-dev" `
-LogicAppName "rcv-shopping-order-sftp" `
-AccessToken $AccessToken
# Successfully enabled Azure Logic App 'rcv-shopping-order-sftp' in resource group 'rg-common-dev'
```

## Disabling Azure Logic Apps from configuration file

Typically done the first task of the release pipeline, right before the deployment of the Logic Apps, will disable all specified Logic Apps in a specific order. 
The Azure Logic Apps to be disabled and the order in which this will be done, will be defined in the provided configuration file.
The order of the Azure Logic Apps in the configuration file (bottom to top) defines the order in which they will be disabled by the script. The counterpart of this script used to enable the Azure Logic Apps, will take the order as specified (top to bottom) in the file.

| Parameter           | Mandatory | Description                                                                                                                                                 |
| ------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure Logic Apps.                                                                                                         |
| `DeployFileName`    | yes       | If your solution consists of multiple interfaces, you can specify the flow-specific name of the configuration file.                                         |
| `ResourcePrefix`    | no        | In case the Azure Logic Apps all start with the same prefix, you can specify this prefix through this parameter instead of updating the configuration-file. | 
| `EnvironmentName`   | no        | The name of the Azure environment where the Azure Logic App resides. (default: `AzureCloud`)                                                                |
| `ApiVersion`        | no        | The version of the management API to be used.  (default: `2016-06-01`)                                                                                      |

The schema of this configuration file is a JSON structure of an array with the following inputs:

| Node                      | Type            | Description                                                                                                                                         |
| ------------------------- | --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| Description               | `string`        | Description of Azure Logic App set to disable.                                                                                                      |
| MaximumFollowNextPageLink | `integer`       | This sets the amount of pages (30 runs per page) of the Logic App run history (if any) that are retrieved. If not supplied the default value is 10. |
| CheckType                 | `enum`          | `None`: don't perform any additional checks.                                                                                                        |
|                           |                 | `NoWaitingOrRunningRuns`: waits until there are no more waiting or running Logic App instances.                                                     |
| StopType                  | `enum`          | `None`: don't disable the given Logic Apps.                                                                                                         |
|                           |                 | `Immediate`: disable the given Logic Apps.                                                                                                          |
| LogicApps                 | `string array`  | Set of Logic App names to disable.                                                                                                                  |

**Example**

Taking an example in which a set of Azure Logic Apps (`"rcv-shopping-order-*"`) need to be disabled, the following configuration will not take into account any active Logic Apps runs (`checkType = None`) and will immediately disable them (`stopType = Immediate`), starting with the _receive protocol_ instances and working its way up to the _sender_ Logic App.

```json
[
  {
    "description": "Sender(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "maximumFollowNextPageLink": 25,
    "logicApps": [
      "snd-shopping-order-confirmation-smtp"
    ]
  },
  {
    "description": "Orchestrator(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      "orc-shopping-order-processing"
    ]
  },
  {
    "description": "Generic Receiver(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      "rcv-shopping-order"
    ]
  },
  {
    "description": "Protocol Receiver(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      "rcv-shopping-order-ftp",
      "rcv-shopping-order-sftp",
      "rcv-shopping-order-file"
    ]
  }
]
```

**Example**

Disables all the Logic Apps based on the `./deploy-orderControl.json` configuration file.
Uses the sample configuration file here above.

```powershell
PS> Disable-AzLogicAppsFromConfig `
-DeployFilename "./deploy-orderControl" `
-ResourceGroupName "my-resource-group"
# Executing batch: Protocol Receiver(s)
# Executing CheckType 'None' for batch 'Protocol Receiver(s)' in resource group 'my-resource-group'"
# Executing Check 'None' => performing no check and executing stopType

# Executing StopType 'Immediate' for Logic App 'rcv-shopping-order-ftp' in resource group 'my-resource-group'
# Successfully disabled Azure Logic App 'rcv-shopping-order-ftp' in resource group 'my-resource-group'

# Executing StopType 'Immediate' for Logic App 'rcv-shopping-order-sftp' in resource group 'my-resource-group'
# Successfully disabled Azure Logic App 'rcv-shopping-order-sftp' in resource group 'my-resource-group'

# Executing StopType 'Immediate' for Logic App 'rcv-shopping-order-file' in resource group 'my-resource-group'
# Successfully disabled Azure Logic App 'rcv-shopping-order-file' in resource group 'my-resource-group'
# Batch: 'Protocol Receiver(s)' has been executed

# Executing batch: 'Generic Receiver(s)'
# Executing StopType 'Immediate' for Logic App 'rcv-shopping-order' in resource group 'my-resource-group'
# Successfully disabled Azure Logic App 'rcv-shopping-order' in resource group 'my-resource-group'
# Batch: 'Generic Receiver(s)' has been executed

# Executing batch: 'Orchestrator(s)'
# Executing StopType 'Immediate' for Logic App 'orc-shopping-order-processing' in resource group 'my-resource-group'
# Successfully disabled Azure Logic App 'orc-shopping-order-processing' in resource group 'my-resource-group'
# Batch: 'Orchestrator(s)' has been executed

# Executing batch: 'Sender(s)'
# Executing StopType 'Immediate' for Logic App 'snd-shopping-order-confirmation-smtp' in resource group 'my-resource-group'
# Successfully disabled Azure Logic App 'snd-shopping-order-smtp' in resource group 'my-resource-group'
# Batch: 'Sender(s)' has been executed
```

Disables all the Logic Apps based on the `./deploy-orderControl.json` configuration file with specifying a resource-prefix.
Uses the sample configuration file here above.

```powershell
PS> Disable-AzLogicAppsFromConfig `
-DeployFilename "./deploy-orderControl" `
-ResourceGroupName "my-resource-group" `
-ResourcePrefix "la-cod-dev-we-"
# Executing batch: Protocol Receiver(s)
# Executing CheckType 'None' for batch 'Protocol Receiver(s)' in resource group 'my-resource-group'"
# Executing Check 'None' => performing no check and executing stopType

# Executing StopType 'Immediate' for Logic App 'la-cod-dev-we-rcv-shopping-order-ftp' in resource group 'my-resource-group'
# Successfully disabled Azure Logic App 'la-cod-dev-we-rcv-shopping-order-ftp' in resource group 'my-resource-group'

# Executing StopType 'Immediate' for Logic App 'la-cod-dev-we-rcv-shopping-order-sftp' in resource group 'my-resource-group'
# Successfully disabled Azure Logic App 'la-cod-dev-we-rcv-shopping-order-sftp' in resource group 'my-resource-group'

# Executing StopType 'Immediate' for Logic App 'la-cod-dev-we-rcv-shopping-order-file' in resource group 'my-resource-group'
# Successfully disabled Azure Logic App 'la-cod-dev-we-rcv-shopping-order-file' in resource group 'my-resource-group'
# Batch: 'Protocol Receiver(s)' has been executed

# Executing batch: 'Generic Receiver(s)'
# Executing StopType 'Immediate' for Logic App 'la-cod-dev-we-rcv-shopping-order' in resource group 'my-resource-group'
# Successfully disabled  Azure Logic App 'la-cod-dev-we-rcv-shopping-order' in resource group 'my-resource-group'
# Batch: 'Generic Receiver(s)' has been executed

# Executing batch: 'Orchestrator(s)'
# Executing StopType 'Immediate' for Logic App 'la-cod-dev-we-orc-shopping-order-processing' in resource group 'my-resource-group'
# Successfully disabled Azure Logic App 'la-cod-dev-we-orc-shopping-order-processing' in resource group 'my-resource-group'
# Batch: 'Orchestrator(s)' has been executed

# Executing batch: 'Sender(s)'
# Executing StopType 'Immediate' for Logic App 'la-cod-dev-we-snd-shopping-order-confirmation-smtp' in resource group 'my-resource-group'
# Successfully disabled Azure Logic App 'la-cod-dev-we-snd-shopping-order-confirmation-smtp' in resource group 'my-resource-group'
# Batch: 'Sender(s)' has been executed
```

## Enabling Azure Logic Apps from configuration file  

Typically done as the last task of the release pipeline, right after the deployment of the Logic Apps, as this will enable all specified Logic Apps in a specific order. 
The Azure Logic Apps to be enabled and the order in which this will be done, will be defined in the provided configuration file.
The order of the Azure Logic Apps in the configuration file (top to bottom) defines the order in which they will be enabled by the script. The counterpart of this script used to disable the Azure Logic Apps, will take the reversed order as specified (bottom to top) in the file.

| Parameter           | Mandatory | Description                                                                                                                                                 |
| ------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure Logic Apps.                                                                                                         |
| `DeployFileName`    | yes       | If your solution consists of multiple interfaces, you can specify the flow-specific name of the configuration file.                                         |
| `ResourcePrefix`    | no        | In case the Azure Logic Apps all start with the same prefix, you can specify this prefix through this parameter instead of updating the configuration-file. |
| `EnvironmentName`   | no        | The name of the Azure environment where the Azure Logic App resides. (default: `AzureCloud`)                                                                |
| `ApiVersion`        | no        | The version of the management API to be used.  (default: `2016-06-01`)                                                                                      |

The schema of this configuration file is a JSON structure of an array with the following inputs:

| Node          | Type            | Description                                                                                                           |
| ------------- | --------------- | --------------------------------------------------------------------------------------------------------------------- |
| `Description` | `string`        | Description of Azure Logic App set to enable.                                                                         |
| `CheckType`   | `enum`          | _Not taken into account for enabling Logic Apps._                                                                     |
| `StopType`    | `enum`          | `None`: don't enable the given Logic Apps.                                                                            |
|               |                 | `Immediate`: enable the given Logic Apps.                                                                             |
| `LogicApps`   | `string array`  | Set of Logic App names to enable.                                                                                     |
**Example**

Taking an example in which a set of Azure Logic Apps (`"rcv-shopping-order-*"`) need to be enabled, the following configuration will ignore the `checkType`, as this is only used for disabling the Logic Apps, and will simply enable them (`stopType = Immediate`), starting with the _sender_ instances and working its way down to the _receive protocol_ Logic Apps.  
This ensures that all of the down-stream Logic Apps are enabled by the time the initial/trigger Logic App have been activated.  

```json
[
  {
    "description": "Sender(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      "snd-shopping-order-confirmation-smtp"
    ]
  },
  {
    "description": "Orchestrator(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      "orc-shopping-order-processing"
    ]
  },
  {
    "description": "Generic Receiver(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      "rcv-shopping-order"
    ]
  },
  {
    "description": "Protocol Receiver(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      "rcv-shopping-order-ftp",
      "rcv-shopping-order-sftp",
      "rcv-shopping-order-file"
    ]
  }
]
```

**Example**

Enables all the Logic Apps based on the `./deploy-orderControl.json` configuration file.
Uses the sample configuration file here above.

```powershell
PS> Enable-AzLogicAppsFromConfig `
-DeployFilename "./deploy-orderControl" `
-ResourceGroupName "my-resource-group"
# Executing batch: 'Sender(s)'
# Reverting StopType 'Immediate' for Logic App 'snd-shopping-order-confirmation-smtp' in resource group 'my-resource-group'
# Successfully enabled Azure Logic App 'snd-shopping-order-confirmation-smtp' in resource group 'my-resource-group'
# Batch: 'Sender(s)' has been executed

# Executing batch: 'Orchestrator(s)'
# Reverting StopType 'Immediate' for Logic App 'orc-shopping-order-processing' in resource group 'my-resource-group'
# Successfully enabled Azure Logic App 'orc-shopping-order-processing' in resource group 'my-resource-group'
# Batch: 'Orchestrator(s)' has been executed

# Executing batch: 'Generic Receiver(s)'
# Reverting StopType 'Immediate' for Logic App 'rcv-shopping-order' in resource group 'my-resource-group'
# Successfully enabled Azure Logic App 'rcv-shopping-order' in resource group 'my-resource-group'
# Batch: 'Generic Receiver(s)' has been executed

# Executing batch: Protocol Receiver(s)
# Reverting StopType 'Immediate' for Logic App 'rcv-shopping-order-ftp' in resource group 'my-resource-group'
# Successfully enabled Azure Logic App 'rcv-shopping-order-ftp' in resource group 'my-resource-group'

# Reverting StopType 'Immediate' for Logic App 'rcv-shopping-order-sftp' in resource group 'my-resource-group'
# Successfully enabled rcv-shopping-order-sftp

# Reverting StopType 'Immediate' for Logic App 'rcv-shopping-order-file' in resource group 'my-resource-group'
# Successfully enabled Azure Logic App 'rcv-shopping-order-file' in resource group 'my-resource-group'
# Batch: 'Protocol Receiver(s)' has been executed
```

Enables all the Logic Apps based on the `./deploy-orderControl.json` configuration file with specifying a resource-prefix.
Uses the sample configuration file here above.

```powershell
PS> Enable-AzLogicAppsFromConfig `
-DeployFilename "./deploy-orderControl" `
-ResourceGroupName "my-resource-group" `
-ResourcePrefix "la-cod-dev-we-"
# Executing batch: 'Sender(s)'
# Reverting StopType 'Immediate' for Logic App 'la-cod-dev-we-snd-shopping-order-confirmation-smtp' in resource group 'my-resource-group'
# Successfully enabled Azure Logic App 'la-cod-dev-we-snd-shopping-order-confirmation-smtp' in resource group 'my-resource-group'
# Batch: 'Sender(s)' has been executed

# Executing batch: 'Orchestrator(s)'
# Reverting StopType 'Immediate' for Logic App 'la-cod-dev-we-orc-shopping-order-processing' in resource group 'my-resource-group'
# Successfully enabled Azure Logic App 'la-cod-dev-we-orc-shopping-order-processing' in resource group 'my-resource-group'
# Batch: 'Orchestrator(s)' has been executed

# Executing batch: 'Generic Receiver(s)'
# Reverting StopType 'Immediate' for Logic App 'la-cod-dev-we-rcv-shopping-order' in resource group 'my-resource-group'
# Successfully enabled Azure Logic App 'la-cod-dev-we-rcv-shopping-order' in resource group 'my-resource-group'
# Batch: 'Generic Receiver(s)' has been executed

# Executing batch: Protocol Receiver(s)
# Reverting StopType 'Immediate' for Logic App 'la-cod-dev-we-rcv-shopping-order-ftp' in resource group 'my-resource-group'
# Successfully enabled Azure Logic App 'la-cod-dev-we-rcv-shopping-order-ftp' in resource group 'my-resource-group'

# Reverting StopType 'Immediate' for Logic App 'la-cod-dev-we-rcv-shopping-order-sftp' in resource group 'my-resource-group'
# Successfully enabled Azure Logic App 'la-cod-dev-we-rcv-shopping-order-sftp' in resource group 'my-resource-group'

# Reverting StopType 'Immediate' for Logic App 'la-cod-dev-we-rcv-shopping-order-file' in resource group 'my-resource-group'
# Successfully enabled Azure Logic App 'la-cod-dev-we-rcv-shopping-order-file' in resource group 'my-resource-group'
# Batch: 'Protocol Receiver(s)' has been executed
```