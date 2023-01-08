[CmdletBinding()]
param (
    [ValidateScript({ (Split-Path $_ -Parent) -eq '' }, ErrorMessage='Invalid file name.')]
    [string]$versionFileName = 'version.json',

    [Parameter(Mandatory)]
    [ValidatePattern('^[0-9a-fA-F]{40}$')]
    [string]$hash,

    [ValidateRange('NonNegative')]
    [int]$revision = -1
)

function Get-Version
{
    [CmdletBinding()]
    [OutputType([Version])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
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

function Get-ChangedFile
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory)]
        [ValidatePattern('^[0-9a-fA-F]{40}$')]
        [string]$hash
    )

    [string[]]$changedFiles = git diff-tree --no-commit-id --name-only -r $hash --exit-code

    # 終了コードが2以上の場合は、何らかのエラー発生のはず。
    if ($LastExitCode -gt 1)
    {
        Write-Error 'Error: git diff-tree command'
        return
    }

    return $changedFiles
}

function Get-GitHubOutput
{
    [CmdletBinding()]
    [OutputType([Collections.Specialized.OrderedDictionary])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Version]$version,

        [Parameter(Mandatory)]
        [bool]$release
    )

    [Collections.Specialized.OrderedDictionary]$outputs = [Ordered]@{
        'version' = $version
        'version-major' = $version.Major
        'version-minor' = $version.Minor
        'version-build' = $version.Build
    }

    if ($release)
    {
        $outputs['release'] = $true
    }
    else
    {
        $outputs['version-revision'] = $version.Revision
    }

    return $outputs
}

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/WriteGitHubOutput.ps1

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

[Collections.Specialized.OrderedDictionary]$outputs = Get-GitHubOutput -Version $displayVersion -Release $release
Write-GitHubOutput -OutputList $outputs
