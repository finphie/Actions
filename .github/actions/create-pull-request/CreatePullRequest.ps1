param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$commitMessage,

    [string]$title = '',
    [string]$branch = 'create-pull-request/',
    [string]$body = '',
    [string]$labels = ''
)

# GitHub Actionsで実行している場合
if ($Env:GITHUB_ACTIONS)
{
    git config --local user.name 'github-actions[bot]'
    git config --local user.email '41898282+github-actions[bot]@users.noreply.github.com'
}

if ($title -eq '')
{
    $title = $commitMessage
}

$date = Get-Date -Format 'yyyyMMddHHmmss'
$branchName = "$branch$date"
$labelList = $labels -Replace "[ `r`n]", ','

git checkout -b $branchName
git add .
git commit -m $commitMessage
git push --set-upstream origin $branchName

gh pr create `
    --body "$body" `
    --title "$title" `
    --label "$labelList"
