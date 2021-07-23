# Contributing to Arcus.Scripting
🎉 First off, thanks for taking the time to contribute! We're really glad you're reading this. 🎉

The following set of guidelines will help you contributing to this Arcus repository. Other than other repositories, it's written in PowerShell which can be an extra hurtle to take for some.

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
This file is the module manifest file of the PowerShell module. This contains metadata information like the module version, required dependency modules, module description, etc.

### `.psm1` file
This file is the script module file. This contains the actual exposed functionality that will be available when the PowerShell module gets installed.

### `Scripts\` folder
This folder contains all the PowerShell scripts in the module. As you will see, each of these scripts will have corresponding links with the `.psm1` file to expose it.

For more information on PowerShell modules, see [the official Microsoft docs](https://docs.microsoft.com/en-us/powershell/scripting/developer/module/understanding-a-windows-powershell-module).

## How to add a new script in an existing module
A new script to an existing PowerShell module means that the script will be available as a module function.
These are the steps you need to take:

1. Add your PowerShell `.ps1` script file to the `Scripts\` folder of the PowerShell module you want to extend.
2. Expose your script in the `.psm1` script module. This is normally something in the line of this.

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

3. Add your function name to the `FunctionsToExport` in the `.psd1` file.

Voila! Now your script will be part as a module function the next time the PowerShell module will be installed.


Also, make sure that you include some unit and/or integration tests to prove workings of your scripts.

The tests are written in [Pester](https://pester.dev/docs/quick-start).