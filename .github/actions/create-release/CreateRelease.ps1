[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$title,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$tag,

    [string]$files = ''
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/Utility.ps1

[string[]]$fileList = Get-List -Value $files | ForEach-Object { Get-ChildItem $_ -File }

Write-Verbose 'Create release'
gh release create $tag --title $title --generate-notes --fail-on-no-commits $fileList
