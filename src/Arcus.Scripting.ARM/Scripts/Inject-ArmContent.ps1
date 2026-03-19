<#
    Possible injection instructions in ARM templates or recursively referenced files:
    
    ${ fileToInject.xml }
    ${ FileToInject=file.xml }
    ${ FileToInject=c:\file.xml }
    ${ FileToInject = ".\Parent Directory\file.xml" }
    ${ FileToInject = "c:\Parent Directory\file.xml" }
    ${ FileToInject = ".\Parent Directory\file.xml", EscapeJson, ReplaceSpecialChars }
    ${ FileToInject = '.\Parent Directory\file.json', InjectAsJsonObject }
    ${ FileToInject = '.\Parent Directory\file.json', InjectAsBase64 }
#>

param(
    [string] $Path = $PSScriptRoot
)

function Get-FullyQualifiedChildFilePath {
    param(
        [parameter(mandatory = $true)] [string] $ParentFilePath,
        [parameter(mandatory = $true)] [string] $ChildFilePath
    )

    $parentDirectoryPath = Split-Path $ParentFilePath -Parent
    # Note: in case of a fully qualified (i.e. absolute) child path the Combine-function discards the parent directory path;
    #  otherwise the relative child path is combined with the parent directory
    $combinedPath = [System.IO.Path]::Combine($parentDirectoryPath, $ChildFilePath)
    $fullPath = [System.IO.Path]::GetFullPath($combinedPath)
    return $fullPath
}

function InjectFile {
    param(
        [string] $filePath
    )

    Write-Verbose "Checking ARM template file '$filePath' for injection tokens..." 

    $replaceContentDelegate = {
        param($match)

        $completeInjectionInstruction = $match.Groups[1].Value;
        $instructionParts = @($completeInjectionInstruction -split "," | ForEach-Object { $_.Trim() } )
                
        $filePart = $instructionParts[0];
        # Regex uses non-capturing group for 'FileToInject' part, 
        #  afterwards character classes and backreferencing to select the optional single or double quotes
        $fileToInjectPathRegex = [regex] "^(?:FileToInject\s*=\s*)?([`"`']?)(?<File>.*?)\1?$";
        $fileMatch = $fileToInjectPathRegex.Match($filePart)
        if ($fileMatch.Success -ne $True) {
            throw "The file part '$filePart' of the injection instruction could not be parsed correctly"
        }

        $fullPathOfFileToInject = Get-FullyQualifiedChildFilePath -ParentFilePath $filePath -ChildFilePath $fileMatch.Groups["File"]
        if (-not(Test-Path -Path $fullPathOfFileToInject -PathType Leaf)) {
            throw "No file can be found at '$fullPathOfFileToInject'"
        }

        # Inject content recursively first
        InjectFile($fullPathOfFileToInject)

        Write-Verbose "`t Injecting content of '$fullPathOfFileToInject' into '$filePath'" 

        $newString = Get-Content -Path $fullPathOfFileToInject -Raw

        # XML declaration can only appear on the first line of an XML document, so remove when injecting
        $newString = $newString -replace '(<\?xml).+(\?>)(\r)?(\n)?', ""

        # By default: retain double quotes around content-to-inject, if present
        $surroundContentWithDoubleQuotes = $match.Value.StartsWith('"') -and $match.Value.EndsWith('"')

        if ($instructionParts.Length -gt 1) {
            $optionParts = $instructionParts | Select-Object -Skip 1

            if ($optionParts.Contains("ReplaceSpecialChars")) {
                Write-Verbose "`t Replacing special characters"

                # Replace newline characters with literal equivalents
                if ([Environment]::OSVersion.VersionString -like "*Windows*") {
                    $newString = $newString -replace "`r`n", "\r\n"
                } else {
                    $newString = $newString -replace "`n", "\n"
                }

                # Replace tabs with spaces
                $newString = $newString -replace "`t", "    "

                # Replace " with \". Not sure why this is done, but changing this might be a breaking change.
                # I expect replacing unescaped double quotes is a compatible change.
                # $newString = $newString -replace """", "\"""
                $newString = $newString -replace '(?<!\\)"', '\"'
            }

            if ($optionParts.Contains("EscapeJson")) {
                Write-Verbose "`t JSON-escaping file content"

                # Use regex negative lookbehind to replace double quotes not preceded by a backslash with escaped quotes
                $newString = $newString -replace '(?<!\\)"', '\"'
            }

            if ($optionParts.Contains("InjectAsJsonObject")) {
                try {
                    # Test if content is valid JSON
                    Write-Verbose "Test if valid JSON: $newString"
                    ConvertFrom-Json $newString

                    $surroundContentWithDoubleQuotes = $False
                } catch {
                    Write-Warning "Content to inject into ARM template file '$filePath' cannot be parsed as a JSON object!"
                }
            }

            if ($optionParts.Contains("InjectAsBase64")) {
                Write-Verbose "Read binary file as base64 string"

                $bytes = [System.Text.Encoding]::UTF8.GetBytes($newString)
                $newString = [Convert]::ToBase64String($bytes)
            }
        }

        if ($surroundContentWithDoubleQuotes) {
            Write-Verbose "`t Surrounding content in double quotes"

            $newString = '"' + $newString + '"'
        }

        return $newString;
    }

    $rawContents = Get-Content $filePath -Raw
    $injectionInstructionRegex = [regex] '"?\${(.+)}\$"?';
    $injectionInstructionRegex.Replace($rawContents, $replaceContentDelegate) | Set-Content $filePath -NoNewline -Encoding UTF8
    
    Write-Host "Done checking ARM template file '$filePath' for injection tokens" -ForegroundColor Green 
}


$psScriptFileName = $MyInvocation.MyCommand.Name

$PathIsFound = Test-Path -Path $Path
if ($false -eq $PathIsFound) {
    throw "Passed along path '$Path' doesn't point to valid file path"
}

Write-Verbose "Starting '$psScriptFileName' script on path '$Path'..."

$armTemplates = Get-ChildItem -Path $Path -Recurse -Include *.json
$armTemplates | ForEach-Object { InjectFile($_.FullName) }

Write-Host "Finished script '$psScriptFileName' on path '$Path'" -ForegroundColor Green