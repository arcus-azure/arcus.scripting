---
title: "Azure Iot Hub"
layout: default
---

# Azure Iot Hub

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.IotHub
```

## Getting quota metrics from Azure IoT Hub
As part of the setup for alert-creations for Azure IoT Hub, a script has been included which allows you to determine the current quota of messages. 
The result can be used when creating an alert on IoT Hub that is triggered when the daily amount of messages that you have received, is reaching the quota / limit of that IoT Hub.

| Parameter           | Mandatory | Description                                                                            |
| ------------------- | --------- | -------------------------------------------------------------------------------------- |
| `IotHubName`        | yes       | The name of the Azure IoT Hub from where the message quota metric should be retrieved. |
| `ResourceGroupName` | yes       | The resource group containing the Azure IoT Hub.                                       |
| `QuotaPercentage`   | yes       | The requested percentage of the quota metric of the Azure IoT Hub's total messages.    |

**Example**

```powershell
PS> Get-AzIotHubDailyMessageQuotaThreshold `
-IotHubName "<my-iot-hub>"
-ResourceGroupName "<my-resource-grou>"
-QuotaPercentage 0.3
# Calculated '321' as quota percentage of Azure IoT Hub metric from '<my-iot-hub>' in resource group '<my-resource-group>'
```