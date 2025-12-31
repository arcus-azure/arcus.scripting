---
title: "Installation"
layout: default
---

# Installation

To have access to the Arcus Scripting features, you have to import the modules.
The best practice for usage in your build and release pipelines is to use the following commands:

``` powershell
PS> Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
PS> Install-Module -Name Arcus.Scripting.{Module} -AllowClobber
```

This drastically improves performance over using the `-Force` parameter and as such, usage of the `-Force` parameter is not recommended.