<#
    Possible injection instructions in ARM templates or recursively referenced files:
    
    ${ fileToInject.xml }
    ${ FileToInject=file.xml }
    ${ FileToInject = ".\Parent Directory\file.xml" }
    ${ FileToInject = ".\Parent Directory\file.xml", EscapeJson, ReplaceSpecialChars }
    ${ FileToInject = '.\Parent Directory\file.json', InjectAsJsonObject }
 #>

param (
    [string] $Path = $PSScriptRoot
)

function InjectFile {
    param(
        [string] $filePath
    )

    Write-Host "Checking file $filePath" 

    $replaceContentDelegate = {
        param($match)

        $completeInjectionInstruction = $match.Groups[1].Value;
        $instructionParts = @($completeInjectionInstruction -split "," | foreach { $_.Trim() } )
                
        $filePart = $instructionParts[0];
        # Regex uses non-capturing group for 'FileToInject' part, 
        #  afterwards character classes and backreferencing to select the optional single or double quotes
        $fileToInjectPathRegex = [regex] "^(?:FileToInject\s*=\s*)?([`"`']?)(?<File>.*?)\1?$";
        $fileMatch = $fileToInjectPathRegex.Match($filePart)
        if ($fileMatch.Success -ne $True){
            throw "The file part '$filePart' of the injection instruction could not be parsed correctly"
        }

        $relativePathOfFileToInject = $fileMatch.Groups["File"];
        $fullPathOfFileToInject = Join-Path (Split-Path $filePath -Parent) $relativePathOfFileToInject
        $fileToInjectIsFound = Test-Path -Path $fullPathOfFileToInject -PathType Leaf
        if ($false -eq $fileToInjectIsFound) {
            throw "No file can be found at '$fullPathofFileToInject'"
        }

        # Inject content recursively first
        InjectFile($fullPathOfFileToInject)

        Write-Host "`t Injecting content of $fullPathOfFileToInject into $filePath" 

        $newString = Get-Content -Path $fullPathOfFileToInject -Raw

        # XML declaration can only appear on the first line of an XML document, so remove when injecting
        $newString = $newString -replace '(<\?xml).+(\?>)(\r)?(\n)?', ""

        # By default: retain double quotes around content-to-inject, if present
        $surroundContentWithDoubleQuotes = $match.Value.StartsWith('"') -and $match.Value.EndsWith('"')

        if ($instructionParts.Length -gt 1) {
            $optionParts = $instructionParts | select -Skip 1

            if ($optionParts.Contains("ReplaceSpecialChars")){
                Write-Host "`t Replacing special characters"

                # Replace newline characters with literal equivalents
                $newString = $newString -replace "`r`n", "\r\n"

                # Replace tabs with spaces
                $newString = $newString -replace "`t", "    "

                # Replace " with \"
                $newString = $newString -replace """", "\"""
            }

            if ($optionParts.Contains("EscapeJson")) {
                Write-Host "`t JSON-escaping file content"

                # Use regex negative lookbehind to replace double quotes not preceded by a backslash with escaped quotes
                $newString = $newString -replace '(?<!\\)"', '\"'
            }


            if ($optionParts.Contains("InjectAsJsonObject")){
                try{
                    # Test if content is valid JSON
                    ConvertFrom-Json $newString

                    $surroundContentWithDoubleQuotes = $False
                }
                catch{
                    Write-Error "Content to inject cannot be parsed as a JSON object!"
                }
            }
        }

        if ($surroundContentWithDoubleQuotes){
            Write-Host "`t Surrounding content in double quotes"

            $newString = '"' + $newString + '"'
        }

        return $newString;
    }

    $rawContents = Get-Content $filePath -Raw
    $injectionInstructionRegex = [regex] '"?\${(.+)}\$"?';
    $injectionInstructionRegex.Replace($rawContents, $replaceContentDelegate) | Set-Content $filePath -Encoding UTF8
    
    Write-Host "Done checking file $filePath" 
}


$psScriptFileName = $MyInvocation.MyCommand.Name

$PathIsFound = Test-Path -Path $Path
if ($false -eq $PathIsFound) {
    throw "Provided path '$Path' doesn't point to valid file path"
}

Write-Host "Starting $psScriptFileName script on path $Path"

$armTemplates = Get-ChildItem -Path $Path -Recurse -Include *.json
$armTemplates | ForEach-Object { InjectFile($_.FullName) }

Write-Host "Finished script $psScriptFileName"
