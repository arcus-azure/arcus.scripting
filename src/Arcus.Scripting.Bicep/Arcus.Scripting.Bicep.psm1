<#
 .Synopsis
  Inject external files inside your Bicep template

 .Description
  In certain scenarios, you have to embed content into an Bicep template to deploy it.
  However, the downside of it is that it's buried inside the template and tooling around it might be less ideal - An example of this is OpenAPI specifications you'd want to deploy.
  By using this command, you can inject external files inside your Bicep template.
  Recommendation: Always inject the content in your Bicep template as soon as possible, preferably during release build that creates the artifact

 .Parameter Path
  The file path to the Bicep template to inject the external files into.
#>
function Inject-BicepContent {
    param (
        [string] $Path = $PSScriptRoot
    )
    . $PSScriptRoot\Scripts\Inject-BicepContent.ps1 -Path $Path
}

Export-ModuleMember -Function Inject-BicepContent