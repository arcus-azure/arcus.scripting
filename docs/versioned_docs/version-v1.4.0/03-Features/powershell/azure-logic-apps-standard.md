---
title: "Azure Logic Apps - Standard"
layout: default
---

# Azure Logic Apps - Standard

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.LogicApps
```

## Cancel running instances for a Azure Logic App workflow

Use this script to cancel all running instances for a specific Azure Logic App. 

| Parameter                   | Mandatory | Description                                                                                                                                         |
| --------------------------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `EnvironmentName`           | no        | The name of the Azure environment where the Azure Logic App resides. (default: `AzureCloud`)                                                        |
| `ResourceGroupName`         | yes       | The resource group containing the Azure Logic App.                                                                                                  |
| `LogicAppName`              | yes       | The name of the Azure Logic App containing the workflow for which the runs will be cancelled.                                                       |
| `WorkflowName`              | yes       | The name of the workflow within the Azure Logic App for which the runs will be cancelled.                                                           |
| `MaximumFollowNextPageLink` | no        | This sets the amount of pages (30 runs per page) of the Logic App run history (if any) that are retrieved. If not supplied the default value is 10. |

**Example**

Taking an example in which a specific Azure Logic App (`"rcv-shopping-order-sftp"`) needs to have all its runs cancelled for the workflow 'process'.  

```powershell
PS> Cancel-AzLogicAppRuns `
-ResourceGroupName "rg-common-dev" `
-LogicAppName "rcv-shopping-order-sftp" `
-WorkflowName "process"

# Successfully cancelled all running instances for the workflow 'process' in Azure Logic App 'rcv-shopping-order-sftp' in resource group 'rg-common-dev'
```

## Resubmitting failed instances for a Azure Logic App workflow

Use this script to re-run a failed Azure Logic App run. 

| Parameter                   | Mandatory | Description                                                                                                                                                  |
| --------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `EnvironmentName`           | no        | The name of the Azure environment where the Azure Logic App resides. (default: `AzureCloud`)                                                                 |
| `ResourceGroupName`         | yes       | The resource group containing the Azure Logic App.                                                                                                           |
| `LogicAppName`              | yes       | The name of the Azure Logic App containing the workflow for which the failed runs will be resubmitted.                                                       |
| `WorkflowName`              | yes       | The name of the workflow within the Azure Logic App for which the runs will be resubmitted.                                                                  |
| `StartTime`                 | yes       | The start time in UTC for retrieving the failed instances.                                                                                                   |
| `MaximumFollowNextPageLink` | no        | This sets the amount of pages (30 runs per page) of the Logic App workflow run history (if any) that are retrieved. If not supplied the default value is 10. |

**Example**

Taking an example in which a specific Azure Logic App (`"rcv-shopping-order-sftp"`) needs to have all its failed runs resubmitted from 2023-05-01 00:00:00 for the workflow 'process'.  

```powershell
PS> Resubmit-FailedAzLogicAppRuns `
-ResourceGroupName "rg-common-dev" `
-LogicAppName "rcv-shopping-order-sftp" `
-WorkflowName "process" `
-StartTime "2023-05-01 00:00:00"
# Successfully resubmitted all failed instances for the workflow 'process' in the Azure Logic App 'rcv-shopping-order-sftp' in resource group 'rg-common-dev' from '2023-05-01 00:00:00'
```

## Disable a Azure Logic App workflow

Use this script to enable a specific Azure Logic App.  

| Parameter           | Mandatory | Description                                                                                                         |
| ------------------- | --------- | ------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure Logic Apps.                                                                 |
| `LogicAppName`      | yes       | The name of the Azure Logic App containing the workflow to be disabled.                                             |
| `WorkflowName`      | yes       | The name of the workflow within the Azure Logic App that needs to be disabled.                                      |

**Example**

Taking an example in which a specific workflow (`"process"`) in an Azure Logic App (`"rcv-shopping-order-sftp"`) needs to be disabled.  

```powershell
PS> Disable-AzLogicApp `
-ResourceGroupName "rg-common-dev" `
-LogicAppName "rcv-shopping-order-sftp" `
-WorkflowName "process"
# Successfully disabled workflow 'process' in Azure Logic App 'rcv-shopping-order-sftp' in resource group 'rg-common-dev'
```

## Enable a Azure Logic App workflow

Use this script to enable a specific Azure Logic App.  

| Parameter           | Mandatory | Description                                                                                                         |
| ------------------- | --------- | ------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure Logic Apps.                                                                 |
| `LogicAppName`      | yes       | The name of the Azure Logic App to be enabled.                                                                      |
| `WorkflowName`      | yes       | The name of the workflow within the Azure Logic App that needs to be enabled.                                       |

**Example**

Taking an example in which a specific workflow (`"process"`) in an Azure Logic App (`"rcv-shopping-order-sftp"`) needs to be enabled.  

```powershell
PS> Enable-AzLogicApp `
-ResourceGroupName "rg-common-dev" `
-LogicAppName "rcv-shopping-order-sftp" `
-WorkflowName "process"
# Successfully enabled workflow 'process' in Azure Logic App 'rcv-shopping-order-sftp' in resource group 'rg-common-dev'
```

## Disabling Azure Logic App workflows from configuration file

Typically done the first task of the release pipeline, right before the deployment of the Logic Apps, will disable all specified Logic App workflows in a specific order. 
The Azure Logic App workflows to be disabled and the order in which this will be done, will be defined in the provided configuration file.
The order of the Azure Logic App workflows in the configuration file (bottom to top) defines the order in which they will be disabled by the script. The counterpart of this script is used to enable the Azure Logic App workflows, will take the order as specified (top to bottom) in the file.

| Parameter           | Mandatory | Description                                                                                                                                                 |
| ------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure Logic Apps.                                                                                                         |
| `DeployFileName`    | yes       | If your solution consists of multiple interfaces, you can specify the flow-specific name of the configuration file.                                         |

The schema of this configuration file is a JSON structure of an array with the following inputs:

| Node                      | Type            | Description                                                                                                                                         |
| ------------------------- | --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| Description               | `string`        | Description of Azure Logic App set to disable.                                                                                                      |
| CheckType                 | `enum`          | `None`: don't perform any additional checks.                                                                                                        |
|                           |                 | `NoWaitingOrRunningRuns`: waits until there are no more waiting or running Logic App instances.                                                     |
| StopType                  | `enum`          | `None`: don't disable the given Logic Apps.                                                                                                         |
|                           |                 | `Immediate`: disable the given Logic Apps.                                                                                                          |
| LogicApps                 | `array`         | Set of Logic App names and workflow to disable.                                                                                                     |

**Example**

Taking an example in which a set of Azure Logic App workflows need to be disabled, the following configuration will not take into account any active Logic Apps runs (`checkType = None`) and will immediately disable them (`stopType = Immediate`), starting with the _receive protocol_ instances and working its way up to the _sender_ Logic App.

```json
[
  {
    "description": "Sender(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      {
        "name": "snd-shopping-order-confirmation-smtp",
        "workflows": [
          "send"
        ]
      }
    ]
  },
  {
    "description": "Orchestrator(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      {
        "name": "orc-shopping-order-processing",
        "workflows": [
          "process"
        ]
      }
    ]
  },
  {
    "description": "Generic Receiver(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      {
        "name": "rcv-shopping-order-generic",
        "workflows": [
          "process"
        ]
      }
    ]
  },
  {
    "description": "Protocol Receiver(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      {
        "name": "rcv-shopping-order-protocol",
        "workflows": [
          "receive-ftp",
		  "receive-sftp",
		  "receive-file"
        ]
      }
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

# Executing StopType 'Immediate' for Logic App 'rcv-shopping-order-protocol' in resource group 'my-resource-group'
# Successfully disabled workflow 'receive-file' in Azure Logic App 'rcv-shopping-order-protocol' in resource group 'my-resource-group'

# Executing StopType 'Immediate' for Logic App 'rcv-shopping-order-protocol' in resource group 'my-resource-group'
# Successfully disabled workflow 'receive-sftp' in Azure Logic App 'rcv-shopping-order-protocol' in resource group 'my-resource-group'

# Executing StopType 'Immediate' for Logic App 'rcv-shopping-order-protocol' in resource group 'my-resource-group'
# Successfully disabled workflow 'receive-ftp' in Azure Logic App 'rcv-shopping-order-protocol' in resource group 'my-resource-group'
# Batch: 'Protocol Receiver(s)' has been executed

# Executing batch: 'Generic Receiver(s)'
# Executing StopType 'Immediate' for Logic App 'rcv-shopping-order-generic' in resource group 'my-resource-group'
# Successfully disabled workflow 'process' in Azure Logic App 'rcv-shopping-order-generic' in resource group 'my-resource-group'
# Batch: 'Generic Receiver(s)' has been executed

# Executing batch: 'Orchestrator(s)'
# Executing StopType 'Immediate' for Logic App 'orc-shopping-order-processing' in resource group 'my-resource-group'
# Successfully disabled workflow 'process' in Azure Logic App 'orc-shopping-order-processing' in resource group 'my-resource-group'
# Batch: 'Orchestrator(s)' has been executed

# Executing batch: 'Sender(s)'
# Executing StopType 'Immediate' for Logic App 'snd-shopping-order-confirmation-smtp' in resource group 'my-resource-group'
# Successfully disabled workflow 'send' in Azure Logic App 'snd-shopping-order-smtp' in resource group 'my-resource-group'
# Batch: 'Sender(s)' has been executed
```

## Enabling Azure Logic App workflows from configuration file  

Typically done as the last task of the release pipeline, right after the deployment of the Logic Apps, as this will enable all specified Logic Apps in a specific order. 
The Azure Logic Apps to be enabled and the order in which this will be done, will be defined in the provided configuration file.
The order of the Azure Logic Apps in the configuration file (top to bottom) defines the order in which they will be enabled by the script. The counterpart of this script is used to disable the Azure Logic App workflows, will take the reversed order as specified (bottom to top) in the file.

| Parameter           | Mandatory | Description                                                                                                                                                 |
| ------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ResourceGroupName` | yes       | The resource group containing the Azure Logic Apps.                                                                                                         |
| `DeployFileName`    | yes       | If your solution consists of multiple interfaces, you can specify the flow-specific name of the configuration file.                                         |

The schema of this configuration file is a JSON structure of an array with the following inputs:

| Node          | Type            | Description                                                                                                           |
| ------------- | --------------- | --------------------------------------------------------------------------------------------------------------------- |
| `Description` | `string`        | Description of Azure Logic App set to enable.                                                                         |
| `CheckType`   | `enum`          | _Not taken into account for enabling Logic Apps._                                                                     |
| `StopType`    | `enum`          | `None`: don't enable the given Logic Apps.                                                                            |
|               |                 | `Immediate`: enable the given Logic Apps.                                                                             |
| LogicApps     | `array`         | Set of Logic App names and workflow to enable.                                                                        |

**Example**

Taking an example in which a set of Azure Logic App workflows need to be enabled, the following configuration will ignore the `checkType`, as this is only used for disabling the Logic Apps, and will simply enable them (`stopType = Immediate`), starting with the _sender_ instances and working its way down to the _receive protocol_ Logic App workflows.  
This ensures that all of the down-stream Logic App workflows are enabled by the time the initial/trigger Logic App workflows have been activated.  

```json
[
  {
    "description": "Sender(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      {
        "name": "snd-shopping-order-confirmation-smtp",
        "workflows": [
          "send"
        ]
      }
    ]
  },
  {
    "description": "Orchestrator(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      {
        "name": "orc-shopping-order-processing",
        "workflows": [
          "process"
        ]
      }
    ]
  },
  {
    "description": "Generic Receiver(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      {
        "name": "rcv-shopping-order-generic",
        "workflows": [
          "receive"
        ]
      }
    ]
  },
  {
    "description": "Protocol Receiver(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      {
        "name": "rcv-shopping-order-protocol",
        "workflows": [
          "receive-ftp",
		  "receive-sftp",
		  "receive-file"
        ]
      }
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
# Successfully enabled workflow 'send' in Azure Logic App 'snd-shopping-order-confirmation-smtp' in resource group 'my-resource-group'
# Batch: 'Sender(s)' has been executed

# Executing batch: 'Orchestrator(s)'
# Reverting StopType 'Immediate' for Logic App 'orc-shopping-order-processing' in resource group 'my-resource-group'
# Successfully enabled workflow 'process' in Azure Logic App 'orc-shopping-order-processing' in resource group 'my-resource-group'
# Batch: 'Orchestrator(s)' has been executed

# Executing batch: 'Generic Receiver(s)'
# Reverting StopType 'Immediate' for Logic App 'rcv-shopping-order-generic' in resource group 'my-resource-group'
# Successfully enabled workflow 'receive' in Azure Logic App 'rcv-shopping-order-generic' in resource group 'my-resource-group'
# Batch: 'Generic Receiver(s)' has been executed

# Executing batch: Protocol Receiver(s)
# Reverting StopType 'Immediate' for Logic App 'rcv-shopping-order-protocol' in resource group 'my-resource-group'
# Successfully enabled workflow 'receive-ftp' in Azure Logic App 'rcv-shopping-order-protocol' in resource group 'my-resource-group'

# Reverting StopType 'Immediate' for Logic App 'rcv-shopping-order-protocol' in resource group 'my-resource-group'
# Successfully enabled workflow 'receive-sftp' in Azure Logic App 'rcv-shopping-order-protocol' in resource group 'my-resource-group'

# Reverting StopType 'Immediate' for Logic App 'rcv-shopping-order-protocol' in resource group 'my-resource-group'
# Successfully enabled workflow 'receive-file' in Azure Logic App 'rcv-shopping-order-protocol' in resource group 'my-resource-group'
# Batch: 'Protocol Receiver(s)' has been executed
```
