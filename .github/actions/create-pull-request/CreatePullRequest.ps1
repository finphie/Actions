param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$commitMessage,

    [ValidateNotNullOrEmpty()]
    [string]$branch = 'create-pull-request',

    [string]$labels = ''
)

if ($Env:GITHUB_ACTIONS)
{
    git config --local user.name 'github-actions[bot]'
    git config --local user.email '41898282+github-actions[bot]@users.noreply.github.com'
}

[string]$date = Get-Date -AsUTC -Format 'yyyyMMddHHmmss'
[string]$branchName = "$branch/$date"
[string]$labelList = $labels.Split([char[]]@(',', ' ', "`n", "`r"), [StringSplitOptions]::RemoveEmptyEntries) -Join ','

Write-Verbose "commit message: $commitMessage"
Write-Verbose "branch: $branchName"
Write-Verbose "label: $labelList"

git checkout -b `"$branchName`"
git add .
git commit -m `"$commitMessage`"
git push --set-upstream origin `"$branchName`"
gh pr create --fill --label `"$labelList`"
