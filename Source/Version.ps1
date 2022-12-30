param (
    [Parameter(Mandatory)]
    [ValidateScript({(Split-Path $_ -Parent) -eq ''}, ErrorMessage='Invalid file name.')]
    [string]$versionFileName = 'version.json',

    [Parameter(Mandatory)]
    [ValidatePattern('^[0-9a-fA-F]{40}$')]
    [string]$sha,

    [ValidateRange('NonNegative')]
    [int]$revision = -1
)

function Get-Version
{
    param (
        [string]$versionFileName
    )

    $json = Get-Content $versionFileName | ConvertFrom-Json -AsHashtable
    $version = $json.version -as [Version]

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
        [string]$sha
    )

    return git diff-tree --no-commit-id --name-only -r $sha
}

function Write-Version
{
    [CmdletBinding()]
    param (
        [Version]$version,
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

if (!(Test-Path $versionFileName))
{
    exit
}

$version = Get-Version $versionFileName
$changedFiles = Get-ChangedFiles $sha
$release = $changedFiles -contains $versionFileName

# JSONファイルが更新されている場合はa.b.c形式、それ以外はa.b.c.d形式のバージョンとする。
$displayVersion = $release ? $version : "$version.$revision"
Write-Output "version: $displayVersion"
Write-Output "release: $release"

$output = Write-Version $displayVersion $release
Write-Output ''
Write-Output $output

# GitHub Actionsで実行している場合
if ($Env:GITHUB_ACTIONS)
{
    Write-Output 'Set GITHUB_OUTPUT'
    $output | Out-File $Env:GITHUB_OUTPUT -Append
}
