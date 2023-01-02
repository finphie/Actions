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
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$versionFileName
    )

    $json = Get-Content $versionFileName | ConvertFrom-Json -AsHashtable
    $version = $json['version'] -as [Version]

    if ($version -eq $null)
    {
        throw 'Parse error.'
    }

    return $version
}

function Get-ChangedFiles
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidatePattern('^[0-9a-fA-F]{40}$')]
        [string]$hash
    )

    return git diff-tree --no-commit-id --name-only -r $hash
}

function Write-Version
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Version]$version,

        [Parameter(Mandatory)]
        [bool]$release
    )

    Write-Output "version={$version}"
    Write-Output "version-major=$($version.Major)"
    Write-Output "version-minor=$($version.Minor)"
    Write-Output "version-build=$($version.Build)"

    if ($release)
    {
        Write-Output "release=$true"
        return
    }

    Write-Output "version-revision=$($version.Revision)"
}

# JSONファイルが存在しない場合、以降の処理をスキップして正常終了する。
if (!(Test-Path $versionFileName -PathType Leaf))
{
    exit
}

[Version]$version = Get-Version -VersionFileName $versionFileName
[string[]]$changedFiles = Get-ChangedFiles -Hash $hash
[bool]$release = $changedFiles -contains $versionFileName

# JSONファイルが更新されている場合はa.b.c形式、それ以外はa.b.c.d形式のバージョンとする。
[Version]$displayVersion = $release ? $version : "$version.$revision"

Write-Output "version: $displayVersion"
Write-Output "release: $release"

[string[]]$output = Write-Version -Version $displayVersion -Release $release
Write-Output ''
Write-Output $output

if ($Env:GITHUB_ACTIONS)
{
    Write-Output 'Set GITHUB_OUTPUT'
    $output | Out-File $Env:GITHUB_OUTPUT -Append
}
