[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$commitMessage,

    [ValidateNotNullOrEmpty()]
    [string]$branch = 'create-pull-request',

    [string]$labels = ''
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/GitCommand.ps1
. $rootPath/Utility.ps1

# 差分なしの場合、以降の処理をスキップして正常終了する。
if (!(Test-Diff))
{
    Write-Verbose 'Skip'
    exit
}

Set-GitConfig

[string]$date = Get-Date -AsUTC -Format 'yyyyMMddHHmmss'
[string]$branchName = "$branch/$date"
[string]$labelList = (Get-List -Value $labels) -Join ','

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