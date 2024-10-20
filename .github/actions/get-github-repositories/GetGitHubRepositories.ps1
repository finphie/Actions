using namespace System.Collections.Specialized

[CmdletBinding(SupportsShouldProcess)]
param (
    [switch]$source,
    [switch]$fork,

    [switch]$archived,
    [switch]$noArchived,

    [ValidateSet('public', 'private', 'internal')]
    [string]$visibility = '',

    [string]$language = '',
    [string]$exclude = '',
    [switch]$json
)

if ($source -and $fork)
{
    throw "Error: 'Source' and 'Fork' cannot be specified at the same time."
}

if ($archived -and $noArchived)
{
    throw "Error: 'Archived' and 'NoArchived' cannot be specified at the same time."
}

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/Profile.ps1
. $rootPath/Utility.ps1
. $rootPath/WriteGitHubOutput.ps1

function Get-GitHubOutput
{
    [CmdletBinding()]
    [OutputType([OrderedDictionary])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$repositories
    )

    [OrderedDictionary]$outputs = [Ordered]@{
        'repositories' = $repositories
    }

    return $outputs
}

function Get-GitHubRepositoryList
{
    [CmdletBinding()]
    [OutputType([Hashtable[]])]
    param (
    )

    # gh repo listでは、GraphQLを使用してリポジトリの一覧を取得している。
    # しかしながら以下の制限がある。
    #   1. GitHub ActionsのGITHUB_TOKENではそのリポジトリのみ取得できる。
    #   2. GitHub Appから生成したトークンでは、そのアプリがインストールされたリポジトリのみ取得できる。
    #   3. フィルターが機能せず、JSONを独自で解析する必要がある。
    # そのため、REST APIを使用してリポジトリの一覧を取得する。
    # この場合は、Metadataに対するRead権限のみで良い。
    # https://docs.github.com/ja/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-a-user
    [string]$json = gh api 'users/{owner}/repos' --paginate
    [Hashtable[]]$repositories = $json | ConvertFrom-Json -AsHashtable

    return $repositories
}

[string[]]$repositories = Get-GitHubRepositoryList | Where-Object {
    (!$archived -or ($archived -and $_['archived'])) -and
    (!$noArchived -or ($noArchived -and !$_['archived'])) -and
    (!$source -or ($source -and !$_['fork'])) -and
    (!$fork -or ($fork -and $_['fork'])) -and
    ([string]::IsNullOrEmpty($language) -or ($language -eq $_['language'])) -and
    ($visibility -eq '' -or ($visibility -eq $_['visibility']))
} | ForEach-Object { $_['full_name'] }

# 除外関連
if ($exclude -ne '')
{
    [string[]]$excludeRepositories = Get-List -Value $exclude
    $repositories = $repositories | Where-Object { !($_ -in $excludeRepositories) }
}

[OrderedDictionary]$outputs = Get-GitHubOutput -Repositories $repositories
Write-GitHubOutput -OutputList $outputs -Json:$json
