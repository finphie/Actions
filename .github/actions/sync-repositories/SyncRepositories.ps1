[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
    [string]$sourcePath,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
    [string]$targetPath,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf }, ErrorMessage='"{0}" does not exist.')]
    [string]$settingsFilePath,

    [Parameter(ValueFromRemainingArguments)]
    [ValidateScript({ ($_ | ForEach-Object { Test-Path $_ }) -contains $true }, ErrorMessage='"{0}" does not exist.')]
    [string[]]$ignoreFiles = @()
)

function Get-FilePath
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
        [string]$path,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ }, ErrorMessage='"{0}" does not exist.')]
        [string]$childPath
    )

    return (Split-Path -IsAbsolute $childPath) ? $childPath : (Join-Path $path $childPath)
}

function Get-GitEmptyHash
{
    [CmdletBinding()]
    param ()

    [string]$hash = git hash-object -t tree /dev/null
    return $hash
}

function Get-CurrentGitHash
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
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

function Get-HeadHash
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
        [string]$path
    )

    [string]$hash = git -C $path rev-parse HEAD
    return $hash
}

function Get-Diff
{
    [CmdletBinding()]
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

function Get-RepositoryFiles
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
        [string]$path
    )

    [string[]]$repositoryFiles = git -C $path ls-files
    return $repositoryFiles
}

function Get-AddedFiles
{
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
        [string]$sourcePath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
        [string]$targetPath
    )

    [string[]]$repositoryFiles = Get-RepositoryFiles -Path $sourcePath
    return $repositoryFiles | ForEach-Object { ,@((Join-Path $sourcePath $_), (Join-Path $targetPath $_)) }
}

function Get-DeletedFiles
{
    [CmdletBinding()]
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

function Copy-File
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf }, ErrorMessage='"{0}" does not exist.')]
        [string]$sourceFilePath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf -IsValid }, ErrorMessage='"{0}" does not exist.')]
        [string]$targetFilePath
    )

    Write-Verbose "Copy file: `"$targetFilePath`""
    Copy-Item $sourceFilePath $targetFilePath -Force
}

function Delete-File
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf }, ErrorMessage='"{0}" does not exist.')]
        [string]$filePath
    )

    Write-Verbose "Delete file: `"$filePath`""

    # 既に存在しないファイルはエラーを出さずに無視する。
    Remove-Item $filePath -Verbose -ErrorAction SilentlyContinue
}

[string]$settingsFullFilePath = Get-FilePath -Path $targetPath -ChildPath $settingsFilePath
[string]$hash = Get-CurrentGitHash -SettingsFilePath $settingsFullFilePath

Write-Verbose "DryRun: $($PSBoundParameters.ContainsKey('WhatIf'))"
Write-Verbose "Settings File: $settingsFullFilePath"
Write-Verbose "Hash: $hash"

# ソース元リポジトリのファイルを、ターゲットリポジトリへコピーする。
$AddedFiles = Get-AddedFiles -SourcePath $sourcePath -TargetPath $targetPath
$AddedFiles | ForEach-Object { Copy-File -SourceFilePath $_[0] -TargetFilePath $_[1] }

# 前回同期時との差分から、ソース元リポジトリで削除されたファイルをターゲットリポジトリでも削除する。
# また、同期対象外のファイルも削除する。
[string[]]$deletedFiles = Get-DeletedFiles -SourcePath $sourcePath -TargetPath $targetPath -Hash $hash -IgnoreFiles $ignoreFiles
$deletedFiles | ForEach-Object { Delete-File -FilePath $_ }

[string]$newHash = Get-HeadHash -Path $sourcePath
[hashtable]$json = @{
    'hash' = $newHash
}

Write-Verbose "Write: $settingsFullFilePath"
$json | ConvertTo-Json | Out-File $settingsFullFilePath -NoNewline
