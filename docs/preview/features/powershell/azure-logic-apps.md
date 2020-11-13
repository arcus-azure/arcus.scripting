---
title: "Scripts related to interacting with Azure Logic Apps"
layout: default
---

# Azure Logic Apps

This module provides the following capabilities:
- [Disabling Azure Logic Apps from configuration file](#disabling-azure-logic-apps-from-configuration-file)
- [Enabling Azure Logic Apps from configuration file](#enabling-azure-logic-apps-from-configuration-file)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.LogicApps
```

## Disabling Azure Logic Apps from configuration file

Typically done the first task of the release pipeline, right before the deployment of the Logic Apps, will disable all specified Logic Apps in a specific order. 
The Azure Logic Apps to be disabled and the order in which this will be done, will be defined in the provided configuration file.
The order of the Azure Logic Apps in the configuration file (bottom to top) defines the order in which they will be disabled by the script. The counterpart of this script used to enable the Azure Logic Apps, will take the order as specified (top to bottom) in the file.

| Parameter         | Mandatory | Description                                                                                                         |
| ----------------- | --------- | ------------------------------------------------------------------------------------------------------------------- |
| ResourceGroupName | yes       | The resource group containing the Azure Logic Apps.                                                                 |
| DeployFileName    | no        | If your solution consists of multiple interfaces, you can specify the flow-specific name of the configuration file. |

The schema of this configuration file is a JSON structure of an array with the following inputs:

| Node        | Type            | Description                                                                                                           |
| ----------- | --------------- | --------------------------------------------------------------------------------------------------------------------- |
| Description | `string`        | Description of Azure Logic App set to disable.                                                                        |
| CheckType   | `enum`          | `None`: don't perform any additional checks. |
|             |                 | `NoWaitingOrRunningRuns`: waits until there are no more waiting or running Logic App instances. |
| StopType    | `enum`          | `None`: don't disable to given Logic Apps. |
|             |                 | `Immediate`: disable the given Logic Apps. |
| LogicApps   | `string array`  | Set of Logic App names to disable.                                                                                    |

**Example**

Taking an example in which a set of Azure Logic Apps (`"rcv-shopping-order-*"`) need to be disabled, the following configuration will not take into account any active Logic Apps runs (`checkType = None`) and will immediately disable them (`stopType = Immediate`), starting with the _receive protocol_ instances and working its way up to the _sender_ Logic App.

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

Disables all the Logic Apps based on the `./deploy-orderControl.json` configuration file.
Uses the sample configuration file here above.

```powershell
PS> Disable-AzLogicAppsFromConfig -DeployFilename "./deploy-orderControl" -ResourceGroupName "my-resource-group"
# Executing batch: Protocol Receiver(s)
# ==========================
# > Executing CheckType 'None' for batch 'Protocol Receiver(s)' in resource group 'my-resource-group'"
# Executing Check 'None' => peforming no check and executing stopType

# > Executing StopType 'Immediate' for Logic App 'rcv-shopping-order-ftp' in resource group 'my-resource-group'
# Attempting to disable rcv-shopping-order-ftp
# Successfully disabled rcv-shopping-order-ftp

# > Executing StopType 'Immediate' for Logic App 'rcv-shopping-order-sftp' in resource group 'my-resource-group'
# Attempting to disable rcv-shopping-order-sftp
# Successfully disabled rcv-shopping-order-sftp

# > Executing StopType 'Immediate' for Logic App 'rcv-shopping-order-file' in resource group 'my-resource-group'
# Attempting to disable rcv-shopping-order-file
# Successfully disabled rcv-shopping-order-file

# -> Batch: 'Protocol Receiver(s)' has been executed

# Executing batch: 'Generic Receiver(s)'
# ==========================
# > Executing StopType 'Immediate' for Logic App 'rcv-shopping-order' in resource group 'my-resource-group'
# Attempting to disable rcv-shopping-order
# Successfully disabled rcv-shopping-order

# -> Batch: 'Generic Receiver(s)' has been executed

# Executing batch: 'Orchestrator(s)'
# ==========================
# > Executing StopType 'Immediate' for Logic App 'orc-shopping-order-processing' in resource group 'my-resource-group'
# Attempting to disable orc-shopping-order-processing
# Successfully disabled orc-shopping-order-processing

# -> Batch: 'Orchestrator(s)' has been executed

# Executing batch: 'Sender(s)'
# ==========================
# > Executing StopType 'Immediate' for Logic App 'snd-shopping-order-confirmation-smtp' in resource group 'my-resource-group'
# Attempting to disable snd-shopping-order-confirmation-smtp
# Successfully disabled snd-shopping-order-confirmation-smtp

# -> Batch: 'Sender(s)' has been executed
```


## Enabling Azure Logic Apps from configuration file  

Typically done as the last task of the release pipeline, right after the deployment of the Logic Apps, as this will enable all specified Logic Apps in a specific order. 
The Azure Logic Apps to be enabled and the order in which this will be done, will be defined in the provided configuration file.
The order of the Azure Logic Apps in the configuration file (top to bottom) defines the order in which they will be enabled by the script. The counterpart of this script used to disable the Azure Logic Apps, will take the reversed order as specified (bottom to top) in the file.

| Parameter         | Mandatory | Description                                                                                                         |
| ----------------- | --------- | ------------------------------------------------------------------------------------------------------------------- |
| ResourceGroupName | yes       | The resource group containing the Azure Logic Apps.                                                                 |
| DeployFileName    | no        | If your solution consists of multiple interfaces, you can specify the flow-specific name of the configuration file. |

The schema of this configuration file is a JSON structure of an array with the following inputs:

| Node        | Type            | Description                                                                                                           |
| ----------- | --------------- | --------------------------------------------------------------------------------------------------------------------- |
| Description | `string`        | Description of Azure Logic App set to enable.                                                                        |
| CheckType   | `enum`          | _Not taken into account for enabling Logic Apps._ |
| StopType    | `enum`          | `None`: don't enable to given Logic Apps. |
|             |                 | `Immediate`: enable the given Logic Apps. |
| LogicApps   | `string array`  | Set of Logic App names to enable.                                                                                    |

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
PS> Enable-AzLogicAppsFromConfig -DeployFilename "./deploy-orderControl" -ResourceGroupName "my-resource-group"
# Executing batch: 'Sender(s)'
# ==========================
# > Reverting StopType 'Immediate' for Logic App 'snd-shopping-order-confirmation-smtp' in resource group 'my-resource-group'
# Attempting to enable snd-shopping-order-confirmation-smtp
# Successfully enabled snd-shopping-order-confirmation-smtp

# -> Batch: 'Sender(s)' has been executed

# Executing batch: 'Orchestrator(s)'
# ==========================
# > Reverting StopType 'Immediate' for Logic App 'orc-shopping-order-processing' in resource group 'my-resource-group'
# Attempting to enable orc-shopping-order-processing
# Successfully enabled orc-shopping-order-processing

# -> Batch: 'Orchestrator(s)' has been executed

# Executing batch: 'Generic Receiver(s)'
# ==========================
# > Reverting StopType 'Immediate' for Logic App 'rcv-shopping-order' in resource group 'my-resource-group'
# Attempting to enable rcv-shopping-order
# Successfully enabled rcv-shopping-order

# -> Batch: 'Generic Receiver(s)' has been executed

# Executing batch: Protocol Receiver(s)
# ==========================
# > Reverting StopType 'Immediate' for Logic App 'rcv-shopping-order-ftp' in resource group 'my-resource-group'
# Attempting to enable rcv-shopping-order-ftp
# Successfully enabled rcv-shopping-order-ftp

# > Reverting StopType 'Immediate' for Logic App 'rcv-shopping-order-sftp' in resource group 'my-resource-group'
# Attempting to enable rcv-shopping-order-sftp
# Successfully enabled rcv-shopping-order-sftp

# > Reverting StopType 'Immediate' for Logic App 'rcv-shopping-order-file' in resource group 'my-resource-group'
# Attempting to enable rcv-shopping-order-file
# Successfully enabled rcv-shopping-order-file

# -> Batch: 'Protocol Receiver(s)' has been executed
```
