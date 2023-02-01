using namespace System.IO

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
    [string]$path,

    [Parameter(ParameterSetName='DestinationFile')]
    [ValidateScript({ Test-Path $_ -PathType Leaf -IsValid }, ErrorMessage='"{0}" is invalid.')]
    [string]$destinationFilePath,

    [Parameter(ParameterSetName='DestinationDirectory')]
    [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
    [string]$destinationDirectoryPath,

    [Parameter(ParameterSetName='DestinationDirectory')]
    [string]$suffix = ''
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
    [string]$filePath = Join-Path $destinationDirectoryPath "$($directory.Name)$suffix.zip"
    New-Archive -Path $directory.FullName -DestinationFilePath $filePath
}

exit
