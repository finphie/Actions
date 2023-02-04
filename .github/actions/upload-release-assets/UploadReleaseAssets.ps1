[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$tag,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$files
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/Utility.ps1

[string[]]$fileList = Get-List -Value $files | ForEach-Object { Get-Item $_ }

gh release upload $tag $fileList
