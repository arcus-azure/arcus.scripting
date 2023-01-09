---
title: "Bicep Templates"
layout: default
---

# Bicep

## Installation

To have access to the following features, you have to import the module:

```powershell
PS> Install-Module -Name Arcus.Scripting.Bicep
```

## Injecting content into a Bicep template

In certain scenarios, you have to embed content into a Bicep template to deploy it.

However, the downside of it is that it's buried inside the template and tooling around it might be less ideal - An example of this is OpenAPI specifications you'd want to deploy.

By using this script, you can inject external files inside your Bicep template.

| Parameter | Mandatory | Description                                                                                      |
| --------- | --------- | -----------------------------------------------------------------------------------------------  |
| `Path`    | no        | The file path to the Bicep template to inject the external files into (default: `$PSScriptRoot`) |

### Usage
Annotating content to inject:

``` bicep
resource api 'Microsoft.ApiManagement/service/apis@2019-01-01' = {
  name: '${ApiManagement.Name}/${ApiManagement.Api.Name}'
  properties: {
    subscriptionRequired: true
    path: 'demo'
    value: '${ FileToInject='.\\..\\openapi\\api-sample.json', InjectAsBicepObject}$'
    format: 'swagger-json'
  }
  dependsOn: []
}

```

Injecting the content:

```powershell
PS> Inject-BicepContent -Path deploy\bicep-template.json
```

### Injection Instructions

It is possible to supply injection instructions in the injection annotation, this allows you to add specific functionality to the injection. These are the available injection instructions:

| Injection Instruction  | Description                                                                              |
| ---------------------- | ---------------------------------------------------------------------------------------- |
| `ReplaceSpecialChars`  | Replace newline characters with literal equivalents, tabs with spaces and `'` with `\'`  |
| `InjectAsBicepObject`  | Makes sure the content is injected without surrounding single quotes                     |

Usage of multiple injection instructions is supported as well, for example if you need both the `ReplaceSpecialChars` and `InjectAsBicepObject` functionality.
The reference to the file to inject can either be a path relative to the 'parent' file or an absolute path.

Some examples are:
```powershell
${ FileToInject = ".\Parent Directory\file.xml" }$
${ FileToInject = "c:\Parent Directory\file.xml" }$
${ FileToInject = ".\Parent Directory\file.xml", ReplaceSpecialChars, InjectAsBicepObject }$
${ FileToInject = '.\Parent Directory\file.json', InjectAsBicepObject }$
```

### Recommendations
Always inject the content in your Bicep template as soon as possible, preferably during release build that creates the artifact.
