# Contributing to Arcus.Scripting
🎉 First off, thanks for taking the time to contribute! We're really glad you're reading this. 🎉

The following set of guidelines will help you in contributing to this Arcus repository. The difference with other Arcus repositories is that `Arcus.Scripting` is written in PowerShell which can be an extra hurdle to take for some.

But, no worries, if you forget something or have problems with some of these steps, we're happy to help! In those cases: create a PullRequest on this repository so we can talk about it.

## PowerShell modules
Our PowerShell functionality is hosted as seperate modules. Each module contains a set of PowerShell scripts that can be accessed as regular functions.

Each of our modules consists of the following structure:
```
Arcus.Scripting.ModuleName\
- Scripts\
- Arcus.Scripting.ModuleName.psm1
- Arcus.Scripting.ModuleName.psd1
```

### `.psd1` file
This file is the module manifest file for the PowerShell module. This manifest contains metadata information such as: the module version, required dependency modules, module description, etc...

### `.psm1` file
This file is the script module file. This file describes the functionality that is exposed and that will be available when the PowerShell module is installed.

### `Scripts\` folder
This folder contains all the PowerShell scripts in the module. As you will see, each of these scripts will have corresponding links with the `.psm1` file to expose it.

For more information on PowerShell modules, see [the official Microsoft docs](https://docs.microsoft.com/en-us/powershell/scripting/developer/module/understanding-a-windows-powershell-module).

## How to add a new script in an existing module
A new script to an existing PowerShell module means that the script will be available as a module function.
These are the steps you need to take:

1. Add your PowerShell `.ps1` script file to the `Scripts\` folder of the PowerShell module you want to extend.
2. Expose your script in the `.psm1` script module. This normally looks like this:

```powershell
<#
 .Synopsis
  My custom synopsis of my script.

 .Description
  A more detailed description of the workings of the script.

 .Parameter MyParameter
  The parameter that has to be given to my script. 
#>
function My-AzCustomFunction {
    param(
        [Parameter(Mandatory=$true)][string] $MyParameter = $(throw "My custom script requires this parameter")
    )

    . $PSScriptRoot\Scripts\My-AzCustomScript.ps1 -MyParameter $MyParameter
}

Export-ModuleMember -Function My-AzCustomFunction
```

3. Add your function name to the `FunctionsToExport` in the `.psd1` file: `FunctionsToExport = @('My-AzCustomFunction')`

Voila! Now your script will be part as a module function the next time the PowerShell module will be installed.

## How to add tests for a new script
As test framework, we use [Pester](https://pester.dev/docs/quick-start). These tests can be found under the solution folder `/Tests`. Both unit and integration tests follow the same principle: 1 file per PowerShell module. So, if you have created a new PowerShell module, you can create a new `.tests.ps1` file, otherwise append your test to the exising one for the module.

The Pester docs already contain a very clean explanation of how to get started to write these tests. We suggest that you also look into the existing test files to get some ideas.
Normally, such a test looks like this:

```powershell
Import-Module $PSScriptRoot\..\Arcus.Scripting.YourModule -ErrorAction Stop

InModuleScope Arcus.Scripting.YourModule {
    Describe "Arcus Azure your module tests" {
        BeforeEach {

        }
        Context "Tests for the 1st function in the module" {
            It "1st function should do this" {
                # Arrange

                # Act

                # Assert
            }
        }
        Context "Tests for the 2nd function in the module" {
            It "2nd function should do this" {
                # Arrange

                # Act

                # Assert
            }
        }
    }
}
```

When you want to tests these locally, we recommand to provide a valid `ModuleVersion` in the `.psd1` file, as it's required for loading the module in Pester.

```powershell
Invoke-Pester .\src\Arcus.Scripting.Unit.Tests\Arcus.Scripting.YourModule.tests.ps1
```

## How to add a new module
We use the [PowerShell Tools for Visual Studio](https://ironmansoftware.com/powershell-pro-tools) to manage our project. When creating a new PowerShell module, this corresponds with creating a new PowerShell project to our code solution. Make sure that you name the module in the format `Arcus.Scripting.*`.

Normally, you would already be presented with a `.psd1` and `.psm1` file. If you don't know what these files are, see our section [PowerShell modules](#powershell-modules) or [the official Microsoft docs](https://docs.microsoft.com/en-us/powershell/scripting/developer/module/understanding-a-windows-powershell-module) for more information.

Make sure that you provide the correct metadata information in the `.psd1` file:
- `RootModule = 'Arcus.Scripting.YourModule'`
- `ModuleVersion = '#{Package.Version}#'` (this module version will be replaced at build-time on the build server).
- `Author = Arcus`
- ```powershell
  PrivateData = @{ 
    PSData = @{
        Tags = 'Azure','DevOps', 'Arcus'
        LicenseUri = 'https://github.com/arcus-azure/arcus.scripting/blob/master/LICENSE'
        ProjectUri = 'https://github.com/arcus-azure/arcus.scripting'
        IconUri = 'https://raw.githubusercontent.com/arcus-azure/arcus/master/media/arcus.png'
        ReleaseNotes = 'https://github.com/arcus-azure/arcus.scripting/releases/tag/v#{Package.Version}#'
    }
  }
  ```

    > Note that any PowerShell dependencies are to be added to the `RequiredModules` in the form of `RequiredModules = @{ @{ ModuleName = 'YourDependency'; ModuleVersion = '1.2.3' } }`

These is all the important parts. After you updated this file, you're good to go!
See [How to add a new script in an existing module](#how-to-add-a-new-script-in-an-existing-module) for the next step.
