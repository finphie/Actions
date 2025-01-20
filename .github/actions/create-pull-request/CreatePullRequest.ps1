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
if (!(Test-Diff -Normalize))
{
    Write-Verbose 'Skip'
    exit
}

Invoke-GitRmCached
Set-GitConfig

[string]$date = Get-Date -AsUTC -Format 'yyyyMMddHHmmss'
[string]$branchName = "$branch/$date"
Invoke-GitCommitAndPush -CommitMessage $commitMessage -BranchName $branchName -Normalize

Write-Verbose 'Create pull request'

[string]$labelList = $labels -eq '' ? '' : ((Get-List -Value $labels) -Join ',')
Write-Verbose "Label: $labelList"

# GitHub CLI v2.64.0で発生する不具合の回避のため、headを指定する。
# v2.65.0で修正
if ($labelList -eq '')
{
    gh pr create --fill --head $(git branch --show-current)
}
else
{
    gh pr create --fill --label $labelList --head $(git branch --show-current)
}
