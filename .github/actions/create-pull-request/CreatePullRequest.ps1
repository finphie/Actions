[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$commitMessage,

    [ValidateNotNullOrEmpty()]
    [string]$branch = 'create-pull-request',

    [string]$labels = ''
)

function Check-Diff
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

# 差分なしの場合、以降の処理をスキップして正常終了する。
if (!(Check-Diff))
{
    Write-Verbose 'Skip'
    exit
}

if ($Env:GITHUB_ACTIONS)
{
    git config --local user.name 'github-actions[bot]'
    git config --local user.email '41898282+github-actions[bot]@users.noreply.github.com'
}

[string]$date = Get-Date -AsUTC -Format 'yyyyMMddHHmmss'
[string]$branchName = "$branch/$date"
[string]$labelList = $labels.Split([char[]]@(',', ' ', "`n", "`r"), [StringSplitOptions]::RemoveEmptyEntries) -Join ','

Write-Verbose "Commit message: $commitMessage"
Write-Verbose "Branch: $branchName"
Write-Verbose "Label: $labelList"

git checkout -b $branchName
git add .
git commit -m $commitMessage
git push origin $branchName

Write-Verbose 'Create pull request'

if ($labelList -eq '')
{
    gh pr create --fill
}
else
{
    gh pr create --fill --label $labelList
}