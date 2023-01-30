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

    Write-Verbose "Copy file: `"$targetFilePath`""
    Copy-Item $sourceFilePath $targetFilePath -Force
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

function New-Archive
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
        [string]$path,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf -IsValid }, ErrorMessage='"{0}" is invalid.')]
        [string]$destinationFilePath
    )

    if (!$PSCmdlet.ShouldProcess('io'))
    {
        return
    }

    [string]$rootPath = Get-Location
    [string]$fullPath = Get-FilePath -Path $rootPath -ChildPath $path
    [string]$destinationFullFilePath =  Get-FilePath -Path $rootPath -ChildPath $destinationFilePath

    Write-Verbose "path: $fullPath"
    Write-Verbose "destinationFilePath: $destinationFullFilePath"

    try
    {
        # Compress-Archiveコマンドレットは、SmallestSizeに対応していない。
        [ZipFile]::CreateFromDirectory($fullPath, $destinationFullFilePath, [CompressionLevel]::SmallestSize, $false)
    }
    catch
    {
        Write-Error "Error: $directory"
        Write-Error $_.Exception
    }
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
