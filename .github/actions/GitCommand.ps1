function Invoke-GitAdd
{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param ()

    if (!$PSCmdlet.ShouldProcess('git'))
    {
        return
    }

    git add .
}

function Invoke-GitSwitch
{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$branchName
    )

    if (!$PSCmdlet.ShouldProcess('git'))
    {
        return
    }

    Write-Verbose "Branch: $branchName"
    git switch -c $branchName
}

function Invoke-GitCommitAndPush
{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$commitMessage
    )

    if (!$PSCmdlet.ShouldProcess('git'))
    {
        return
    }

    Write-Verbose "Commit message: $commitMessage"

    Invoke-GitAdd
    git commit -m $commitMessage
    git push origin $branchName
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

    $global:LastExitCode = $null
    return $changedFiles
}

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

    $global:LastExitCode = $null
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
        [string]$path = '.',

        [ValidatePattern('^[0-9a-fA-F]{40}$')]
        [string]$hash = 'HEAD'
    )

    [string[]]$repositoryFiles = git -C $path ls-tree -r $hash --name-only
    return $repositoryFiles
}

function Set-GitConfig
{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param ()

    if ($PSCmdlet.ShouldProcess('git') -and $Env:GITHUB_ACTIONS -eq 'true')
    {
        git config --local user.name 'github-actions[bot]'
        git config --local user.email '41898282+github-actions[bot]@users.noreply.github.com'
    }
}

function Test-Diff
{
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    git add -N .
    git diff --name-only --exit-code
    [int]$exitCode = $LastExitCode

    # 終了コードが2以上の場合は、何らかのエラー発生のはず。
    if ($exitCode -gt 1)
    {
        Write-Error 'Error: git diff command'
        return
    }

    $global:LastExitCode = $null

    # 終了コード0は差分なし、1は差分ありを表す。
    return $exitCode -eq 1
}

function Invoke-GitRmCached
{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string[]])]
    param (
        [ValidateScript({ Test-Path $_ -PathType Leaf }, ErrorMessage='"{0}" does not exist.')]
        [string]$path = '.'
    )

    if (!$PSCmdlet.ShouldProcess('git'))
    {
        return
    }

    git rm --cached $path
}
