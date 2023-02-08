using namespace System.Collections.Specialized

[CmdletBinding(SupportsShouldProcess)]
param (
    [ValidateScript({ (Split-Path $_ -Parent) -eq '' }, ErrorMessage='Invalid file name.')]
    [string]$versionFileName = 'version.json',

    [Parameter(Mandatory)]
    [ValidatePattern('^[0-9a-fA-F]{40}$')]
    [string]$hash,

    [ValidateRange('NonNegative')]
    [int]$revision = -1
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/GitCommand.ps1
. $rootPath/WriteGitHubOutput.ps1

function Get-Version
{
    [CmdletBinding()]
    [OutputType([Version])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf }, ErrorMessage='"{0}" does not exist.')]
        [string]$versionFileName
    )

    [Hashtable]$json = Get-Content $versionFileName | ConvertFrom-Json -AsHashtable
    [Version]$version = $json['version']

    if ($null -eq $version)
    {
        Write-Error 'Error: Invalid version'
        return
    }

    return $version
}

function Get-GitHubOutput
{
    [CmdletBinding()]
    [OutputType([OrderedDictionary])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Version]$version,

        [Parameter(Mandatory)]
        [bool]$release
    )

    [OrderedDictionary]$outputs = [Ordered]@{
        'version' = $version
        'version-major' = $version.Major
        'version-minor' = $version.Minor
        'version-build' = $version.Build
        'release' = $release
    }

    if (!$release)
    {
        $outputs['version-revision'] = $version.Revision
    }

    return $outputs
}

# JSONファイルが存在しない場合、以降の処理をスキップして正常終了する。
if (!(Test-Path $versionFileName -PathType Leaf))
{
    Write-Verbose "`"$versionFileName`" does not exist."
    exit
}

[Version]$version = Get-Version -VersionFileName $versionFileName
[string[]]$changedFiles = Get-ChangedFile -Hash $hash
[bool]$release = $changedFiles -contains $versionFileName

# JSONファイルが更新されている場合はa.b.c形式、それ以外はa.b.c.d形式のバージョンとする。
[Version]$displayVersion = $release ? $version : "$version.$revision"

Write-Verbose "Version: $displayVersion"
Write-Verbose "Release: $release"

[OrderedDictionary]$outputs = Get-GitHubOutput -Version $displayVersion -Release $release
Write-GitHubOutput -OutputList $outputs
