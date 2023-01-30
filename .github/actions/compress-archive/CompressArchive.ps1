using namespace System.IO

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
    [string]$path,

    [ValidateScript({ Test-Path $_ -PathType Leaf -IsValid }, ErrorMessage='"{0}" is invalid.')]
    [string]$destinationFilePath
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/IO.ps1

if ($destinationFilePath -ne '')
{
    New-Archive -Path $path -DestinationFilePath $destinationFilePath
    exit
}

[DirectoryInfo[]]$directories = Get-ChildItem $path -Directory

foreach ($directory in $directories)
{
    New-Archive -Path $directory.FullName -DestinationFilePath "$($directory.Name).zip"
}

exit
