function Get-Diff
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
        [string]$path,

        [Parameter(Mandatory)]
        [ValidatePattern('^[0-9a-fA-F]{40}$')]
        [string]$hash
    )

    [string[]]$result = git -C $path diff $hash --name-status --exit-code

    # 終了コード0は差分なし、1は差分ありを表す。
    # 2以上の場合は、何らかのエラー発生のはず。
    if ($LastExitCode -gt 1)
    {
        Write-Error 'Error: git diff command'
        return
    }

    return $result
}

function Get-HeadHash
{
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
        [string]$path
    )

    [string]$hash = git -C $path rev-parse HEAD
    return $hash
}

function Get-GitEmptyHash
{
    [CmdletBinding()]
    [OutputType([string])]
    param ()

    [string]$hash = git hash-object -t tree /dev/null
    return $hash
}

function Get-RepositoryFile
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
        [string]$path = '.'
    )

    [string[]]$repositoryFiles = git -C $path ls-files
    return $repositoryFiles
}

function Set-GitConfig
{
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    if ($PSCmdlet.ShouldProcess('git') -and $Env:GITHUB_ACTIONS -eq 'true')
    {
        git config --local user.name 'github-actions[bot]'
        git config --local user.email '41898282+github-actions[bot]@users.noreply.github.com'
    }
}

function Test-Diff
{
    git add -N .
    git diff --name-only --exit-code

    # 終了コードが2以上の場合は、何らかのエラー発生のはず。
    if ($LastExitCode -gt 1)
    {
        Write-Error 'Error: git diff command'
        return
    }

    # 終了コード0は差分なし、1は差分ありを表す。
    return $LastExitCode -eq 1
}
