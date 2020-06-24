<#
 .Synopsis
  Inject external files inside your ARM template

 .Description
  In certain scenarios, you have to embed content into an ARM template to deploy it.
  However, the downside of it is that it's buried inside the template and tooling around it might be less ideal - An example of this is OpenAPI specifications you'd want to deploy.
  By using this command, you can inject external files inside your ARM template.
  Recommandation: Always inject the content in your ARM template as soon as possible, preferably during release build that creates the artifact

 .Parameter Path
  The file path to the ARM template to inject the external files into.
#>
function Inject-ArmContent {
	param (
		[string] $Path = $PSScriptRoot
	)
	. $PSScriptRoot\Scripts\Inject-ArmContent.ps1 -Path $Path
}

Export-ModuleMember -Function Inject-ArmContent