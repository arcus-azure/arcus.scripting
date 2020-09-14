---
title: "Scripts related to interacting with Azure Logic Apps"
layout: default
---

# Azure Logic Apps

This module provides the following capabilities:
- [Disabling Azure Logic Apps from configuration file](#disabling-azure-logic-apps-from-configuration-file)

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Import-Module -Name Arcus.Scripting.LogicApps
```

## Disabling Azure Logic Apps from configuration file

Typically done the first task of the release pipeline, right before the deployment of the Logic Apps, will disable all specified Logic Apps in a specific order. 
The Logic Apps to be disabled and the order in which this will be done, will be defined in the passed-along configuration file.

| Parameter         | Mandatory | Description                                                                                                        |
| ----------------- | --------- | ------------------------------------------------------------------------------------------------------------------ |
| DeployFileName    | yes       | If your solution consists of multiple interfaces, you can specify the flow-specific name of the orderControl-file. |
| ResourceGroupName | yes       | The resource group containing the Azure Logic Apps.                                                                |

The schema of this configuration file is a JSON structure of an array with the following inputs:

| Node        | Type            | Description                                                                                                           |
| ----------- | --------------- | --------------------------------------------------------------------------------------------------------------------- |
| Description | `string`        | Description of Azure Logic App set to disable.                                                                        |
| CheckType   | `enum`          | Either `None` or `NoWaitingOrRunningRuns` which waits until there are no more waiting or running Logic App instances. |
| StopType    | `enum`          | Either `None` or `Immediate` which results in the disabling of the Logic App.                                         |
| LogicApps   | `string array`  | Set of Logic App names to disable.                                                                                    |

**Example**

With a 3 Azure Logic App (`"rcv-sthp-harvest-order-af-*"`), that doesn't looks for still-running Logic Apps (`checkType = None`) and t disables them (`stopType = Immediate`).

```json
[
    {
    "description": "Protocol Receiver(s)",
    "checkType": "None",
    "stopType": "Immediate",
    "logicApps": [
      "rcv-sthp-harvest-order-af-ftp",
      "rcv-sthp-harvest-order-af-sft",
      "rcv-sthp-harvest-order-af-file"
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

# > Executing StopType 'None' for Logic App 'rcv-sthp-harvest-order-af-ftp' in resource group 'my-resource-group'
# Attempting to disable rcv-sthp-harvest-order-af-ftp
# Successfully disabled rcv-sthp-harvest-order-af-ftp

# > Executing StopType 'None' for Logic App 'rcv-sthp-harvest-order-af-sft' in resource group 'my-resource-group'
# Attempting to disable rcv-sthp-harvest-order-af-sft
# Successfully disabled rcv-sthp-harvest-order-af-sft

# > Executing StopType 'None' for Logic App 'rcv-sthp-harvest-order-af-file' in resource group 'my-resource-group'
# Attempting to disable rcv-sthp-harvest-order-af-file
# Successfully disabled rcv-sthp-harvest-order-af-file

# -> Batch: 'Protocol Receiver(s)' has been executed
```