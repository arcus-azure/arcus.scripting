---
title: "ARM Templates"
layout: default
---

# ARM

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.ARM
```

## Injecting content into an ARM template

In certain scenarios, you have to embed content into an ARM template to deploy it.

However, the downside of it is that it's buried inside the template and tooling around it might be less ideal - An example of this is OpenAPI specifications you'd want to deploy.

By using this script, you can inject external files inside your ARM template.

| Parameter | Mandatory | Description                                                                                     |
| --------- | --------- | ----------------------------------------------------------------------------------------------- |
| `Path`    | no        | The file path to the ARM template to inject the external files into  (default: `$PSScriptRoot`) |

### Usage
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

### Injection Instructions

It is possible to supply injection instructions in the injection annotation, this allows you to add specific functionality to the injection. These are the available injection instructions:

| Injection Instruction | Description                                                                                                 |
| --------------------- | ----------------------------------------------------------------------------------------------------------- |
| `EscapeJson`          | Replace double quotes not preceded by a backslash with escaped quotes                                       |
| `ReplaceSpecialChars` | Replace newline characters with literal equivalents, tabs with spaces and `"` with `\"`                     |
| `InjectAsJsonObject`  | Tests if the content is valid JSON and makes sure the content is injected without surrounding double quotes |
| `InjectAsBase64`      | Converts the file to a base64 string and injects the result. Useful for binary files                        |

Usage of multiple injection instructions is supported as well, for example if you need both the `EscapeJson` and `ReplaceSpecialChars` functionality.
The reference to the file to inject can either be a path relative to the 'parent' file or an absolute path.

Some examples are:
```powershell
${ FileToInject = ".\Parent Directory\file.xml" }
${ FileToInject = "c:\Parent Directory\file.xml" }
${ FileToInject = ".\Parent Directory\file.xml", EscapeJson, ReplaceSpecialChars }
${ FileToInject = '.\Parent Directory\file.json', InjectAsJsonObject }
${ FileToInject = '.\Parent Directory\file.json', InjectAsBase64 }
```

### 🥇 Recommendations
Always inject the content in your ARM template as soon as possible, preferably during release build that creates the artifact
