﻿[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
    [string]$sourcePath,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
    [string]$targetPath,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf -IsValid }, ErrorMessage='"{0}" is invalid.')]
    [string]$settingsFilePath,

    [Parameter(ValueFromRemainingArguments)]
    [ValidateScript({ ($_ | ForEach-Object { Test-Path $_ }) -contains $true }, ErrorMessage='"{0}" does not exist.')]
    [string[]]$ignoreFiles = @()
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/GitCommand.ps1
. $rootPath/IO.ps1

function Get-CurrentGitHash
{
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf -IsValid }, ErrorMessage='"{0}" is invalid.')]
        [string]$settingsFilePath
    )

    # 初回実行時などには、設定ファイルが存在しない場合がある。
    if (Test-Path $settingsFilePath -PathType Leaf)
    {
        [Hashtable]$json = Get-Content $settingsFilePath | ConvertFrom-Json -AsHashtable

        if ($json.ContainsKey('hash'))
        {
            return $json['hash']
        }
    }

    return Get-GitEmptyHash
}

function Get-AddedFile
{
    # 誤検知している警告を無効にする。
    # https://github.com/PowerShell/PSScriptAnalyzer/issues/1472
    [Diagnostics.CodeAnalysis.SuppressMessage('PSReviewUnusedParameter', 'targetPath', Justification = 'false positive')]
    [CmdletBinding()]
    [OutputType([string[][]])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
        [string]$sourcePath,


        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
        [string]$targetPath
    )

    [string[]]$repositoryFiles = Get-RepositoryFile -Path $sourcePath
    return $repositoryFiles | ForEach-Object { ,@((Join-Path $sourcePath $_), (Join-Path $targetPath $_)) }
}

function Get-DeletedFile
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
        [string]$sourcePath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
        [string]$targetPath,

        [Parameter(Mandatory)]
        [ValidatePattern('^[0-9a-fA-F]{40}$')]
        [string]$hash,

        [string[]]$ignoreFiles
    )

    [string[]]$lines = Get-Diff -Path $sourcePath -Hash $hash

    foreach ($line in $lines)
    {
        $status, $filePath = $line -Split "`t"

        # ソース元リポジトリで対象のファイルが削除されている場合。
        if ($status -eq 'D')
        {
            [string]$targetFilePath = Join-Path $targetPath $filePath
            Write-Output $targetFilePath
        }

        # ソース元リポジトリで対象のファイルがリネームされている場合。
        if ($status.StartsWith('R'))
        {
            [string]$targetFilePath = Join-Path $targetPath $filePath[0]
            Write-Output $targetFilePath
        }
    }

    # 同期対象外のファイルを削除リストに追加する。
    # 相対パスの場合、ターゲットリポジトリのパスを基準とする。
    return $ignoreFiles | ForEach-Object { Get-FilePath -Path $targetPath -ChildPath $_ }
}

[string]$settingsFullFilePath = Get-FilePath -Path $targetPath -ChildPath $settingsFilePath
[string]$hash = Get-CurrentGitHash -SettingsFilePath $settingsFullFilePath

Write-Verbose "DryRun: $($PSBoundParameters.ContainsKey('WhatIf'))"
Write-Verbose "Settings File: $settingsFullFilePath"
Write-Verbose "Hash: $hash"

# ソース元リポジトリのファイルを、ターゲットリポジトリへコピーする。
[string[][]]$addedFiles = Get-AddedFile -SourcePath $sourcePath -TargetPath $targetPath
$addedFiles | ForEach-Object { Copy-File -SourceFilePath $_[0] -TargetFilePath $_[1] }

# 前回同期時との差分から、ソース元リポジトリで削除されたファイルをターゲットリポジトリでも削除する。
# また、同期対象外のファイルも削除する。
[string[]]$deletedFiles = Get-DeletedFile -SourcePath $sourcePath -TargetPath $targetPath -Hash $hash -IgnoreFiles $ignoreFiles
$deletedFiles | ForEach-Object { Remove-File -FilePath $_ }

[string]$newHash = Get-HeadHash -Path $sourcePath
[hashtable]$json = @{
    'hash' = $newHash
}

Write-Verbose "Write: $settingsFullFilePath"
$json | ConvertTo-Json | Out-File $settingsFullFilePath
