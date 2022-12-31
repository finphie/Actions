param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$commitMessage,

    [string]$branch = 'create-pull-request',
    [string]$labels = ''
)

# GitHub Actionsで実行している場合
if ($Env:GITHUB_ACTIONS)
{
    git config --local user.name 'github-actions[bot]'
    git config --local user.email '41898282+github-actions[bot]@users.noreply.github.com'
}

$date = Get-Date -Format 'yyyyMMddHHmmss'
$branchName = "$branch/$date"
$labelList = $labels.Split([char[]]@(',', ' ', "`n", "`r"), [StringSplitOptions]::RemoveEmptyEntries) -Join ','

Write-Output "commit message: $commitMessage"
Write-Output "branch: $branchName"
Write-Output "label: $labelList"
Write-Output ''

git checkout -b "$branchName"
git add .
git commit -m "$commitMessage"
git push --set-upstream origin "$branchName"
gh pr create --label "$labelList" --fill
