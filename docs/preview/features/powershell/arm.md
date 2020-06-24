---
title: "Scripts related to ARM templates"
layout: default
---

# ARM

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Import-Module -Name Arcus.Scripting.ARM
```

## Inject content in ARM template

In certain scenarios, you have to embed content into an ARM template to deploy it.
However, the downside of it is that it's buried inside the template and tooling around it might be less ideal - An example of this is OpenAPI specifications you'd want to deploy.
By using this script, you can inject external files inside your ARM template.

| Parameter | Mandatory | Description                                                         |
| --------- | --------- | ------------------------------------------------------------------- |
| `Path`    | no        | The file path to the ARM template to inject the external files into |

**Usage**
Annotating content to inject:

```json
{
    "type": "Microsoft.ApiManagement/service/apis",
    "name": "[concat(parameters('ApiManagement.Name'),'/', parameters('ApiManagement.Api.Name'))]",
    "apiVersion": "2019-01-01",
    "properties": {
        "subscriptionRequired": true,
        "path": "demo",
        "value": "${ FileToInject='.\\..\\openapi\\api-sample.json', InjectAsJsonObject}$",
        "format": "swagger-json"
    },
    "tags": "[variables('Tags')]",
    "dependsOn": [
    ]
}
```

Injecting the content:

```powershell
PS> Inject-ArmContent -Path deploy\arm-template.json
```

**Recommendations**
Always inject the content in your ARM template as soon as possible, preferably during release build that creates the artifact