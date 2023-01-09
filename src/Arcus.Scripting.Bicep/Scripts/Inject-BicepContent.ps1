<#
    Possible injection instructions in Bicep templates or recursively referenced files:
    
    ${ fileToInject.xml }$
    ${ FileToInject=file.xml }$
    ${ FileToInject=c:\file.xml }$
    ${ FileToInject = ".\Parent Directory\file.xml" }$
    ${ FileToInject = "c:\Parent Directory\file.xml" }$
    ${ FileToInject = ".\Parent Directory\file.xml", ReplaceSpecialChars }$
    ${ FileToInject = '.\Parent Directory\file.bicep', InjectAsBicepObject }$

 #>

param (
    [string] $Path = $PSScriptRoot
)

function Get-FullyQualifiedChildFilePath {
    param(
        [parameter(mandatory=$true)] [string] $ParentFilePath,
        [parameter(mandatory=$true)] [string] $ChildFilePath
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

    Write-Verbose "Checking Bicep template file '$filePath' for injection tokens..." 

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

        # By default: retain single quotes around content-to-inject, if present
        $surroundContentWithSingleQuotes = $match.Value.StartsWith('''') -and $match.Value.EndsWith('''')

        if ($instructionParts.Length -gt 1) {
            $optionParts = $instructionParts | select -Skip 1

            if ($optionParts.Contains("ReplaceSpecialChars")) {
                Write-Host "`t Replacing special characters"

                # Replace newline characters with literal equivalents
                if ([Environment]::OSVersion.VersionString -like "*Windows*") {
                    $newString = $newString -replace "`r`n", "\r\n"
                } else {
                    $newString = $newString -replace "`n", "\n"
                }

                # Replace tabs with spaces
                $newString = $newString -replace "`t", "    "

                # Replace ' with \'
                $newString = $newString -replace "'", "\'"
            }

            if ($optionParts.Contains("InjectAsBicepObject")) {
                $surroundContentWithSingleQuotes = $False
            }
        }

        if ($surroundContentWithSingleQuotes) {
            Write-Host "`t Surrounding content in double quotes"

            $newString = '''' + $newString + ''''
        }

        return $newString;
    }

    $rawContents = Get-Content $filePath -Raw
    $injectionInstructionRegex = [regex] '"?\${(.+)}\$"?';
    $injectionInstructionRegex.Replace($rawContents, $replaceContentDelegate) | Set-Content $filePath -NoNewline -Encoding UTF8
    
    Write-Host "Done checking Bicep template file '$filePath' for injection tokens" -ForegroundColor Green 
}


$psScriptFileName = $MyInvocation.MyCommand.Name

$PathIsFound = Test-Path -Path $Path
if ($false -eq $PathIsFound) {
    throw "Passed along path '$Path' doesn't point to valid file path"
}

Write-Verbose "Starting '$psScriptFileName' script on path '$Path'..."

$bicepTemplates = Get-ChildItem -Path $Path -Recurse -Include *.bicep
$bicepTemplates | ForEach-Object { InjectFile($_.FullName) }

Write-Host "Finished script '$psScriptFileName' on path '$Path'" -ForegroundColor Green