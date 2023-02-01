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
    [string]$suffix = '',

    [Parameter(ParameterSetName='DestinationDirectory')]
    [string]$exclude = ''
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/IO.ps1
. $rootPath/Utility.ps1

if ($destinationFilePath -ne '')
{
    New-Archive -Path $path -DestinationFilePath $destinationFilePath
    exit
}

[DirectoryInfo[]]$directories = Get-ChildItem $path -Directory
[string[]]$excludeList = $exclude -eq '' ? '' : (Get-List -Value $exclude | ForEach-Object { ".$_" })

Write-Verbose "Exclude: $($exclude -join ',')"

foreach ($directory in $directories)
{
    # フォルダ・ファイル数の合計
    [int]$count = (Get-ChildItem $directory | Measure-Object).Count

    Write-Verbose $count

    [string]$filePath = Join-Path $destinationDirectoryPath "$($directory.Name)$suffix"

    if ($count -eq 1 -and $excludeList.Count -gt 0)
    {
        [FileInfo]$file = Get-ChildItem $directory -File
        [string]$extension = $file.Extension

        if ($extension -in $excludeList)
        {
            Write-Verbose "Skip: $directory"
            Copy-File -SourceFilePath $file -TargetFilePath "$filePath$extension"
            continue
        }
    }

    New-Archive -Path $directory.FullName -DestinationFilePath "$filePath.zip"
}

exit
