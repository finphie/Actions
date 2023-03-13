using namespace System.IO
using namespace System.IO.Compression

function Copy-File
{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf }, ErrorMessage='"{0}" does not exist.')]
        [string]$sourceFilePath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf -IsValid }, ErrorMessage='"{0}" is invalid.')]
        [string]$targetFilePath
    )

    [string]$parentPath = Split-Path $targetFilePath

    New-Directory -Path $parentPath
    Copy-Item $sourceFilePath $targetFilePath -Force -Verbose
}

function Get-FilePath
{
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container -IsValid }, ErrorMessage='"{0}" is invalid.')]
        [string]$path,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -IsValid }, ErrorMessage='"{0}" is invalid.')]
        [string]$childPath
    )

    return (Split-Path -IsAbsolute $childPath) ? $childPath : (Join-Path $path $childPath)
}

function Get-JsonFile
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf }, ErrorMessage='"{0}" does not exist.')]
        $path
    )

    return Get-Content $path | ConvertFrom-Json -AsHashtable -NoEnumerate
}

function New-Archive
{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
        [string]$path,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf -IsValid }, ErrorMessage='"{0}" is invalid.')]
        [string]$destinationFilePath,

        [ValidateSet('Zip', 'GZip')]
        [string]$type = 'Zip'
    )

    if (!$PSCmdlet.ShouldProcess('io'))
    {
        return
    }

    [string]$rootPath = Get-Location
    [string]$fullFilePath = Get-FilePath -Path $rootPath -ChildPath $path
    [string]$destinationFullFilePath =  Get-FilePath -Path $rootPath -ChildPath $destinationFilePath
    [string]$destinationParentPath = Split-Path $destinationFullFilePath

    Write-Verbose "Type: $type"
    Write-Verbose "Path: $fullFilePath"
    Write-Verbose "DestinationFilePath: $destinationFullFilePath"
    Write-Verbose "destinationParentPath: $destinationParentPath"

    New-Directory $destinationParentPath

    if ($type -eq 'GZip')
    {

        [string[]]$filePaths = Get-ChildItem $fullFilePath | ForEach-Object { [Path]::GetRelativePath($fullFilePath, $_) }
        tar -C $fullFilePath -czvf $destinationFullFilePath $filePaths

        return
    }

    try
    {
        # Compress-Archiveコマンドレットは、SmallestSizeに対応していない。
        [ZipFile]::CreateFromDirectory($fullFilePath, $destinationFullFilePath, [CompressionLevel]::SmallestSize, $false)
    }
    catch
    {
        Write-Error "Error: $directory"
        Write-Error $_.Exception
    }
}

function New-Directory
{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container -IsValid }, ErrorMessage='"{0}" is invalid.')]
        [string]$path
    )

    New-Item $path -ItemType Directory -Force | Out-Null
}

function Remove-File
{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf }, ErrorMessage='"{0}" does not exist.')]
        [string]$filePath
    )

    Write-Verbose "Delete file: `"$filePath`""

    # 既に存在しないファイルはエラーを出さずに無視する。
    Remove-Item $filePath -Verbose -ErrorAction SilentlyContinue
}
