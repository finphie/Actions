[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]$paths = '*,Source/*',

    [switch]$recurse
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/Utility.ps1
. $rootPath/WriteGitHubOutput.ps1

function Test-Extension
{
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$extension,

        [Parameter(Mandatory)]
        [bool]$recurse
    )

    foreach ($directoryPath in $path)
    {
        [string]$filePath = "$(Join-Path $directoryPath '*').$extension"

        # Test-Pathは隠しファイルを取得できない。
        [string[]]$files = (Get-ChildItem $filePath -File -Force -Recurse:$recurse -ErrorAction SilentlyContinue).FullName |
            Where-Object { ($_ -Replace '\\', '/') -notlike '*/.git/*' }

        if ($files.Count -eq 0)
        {
            continue
        }

        $files | ForEach-Object { Write-Verbose "File: $_" }
        return $true
    }

    return $false
}

function Get-GitHubOutput
{
    [CmdletBinding()]
    [OutputType([Collections.Specialized.OrderedDictionary])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$path,

        [Parameter(Mandatory)]
        [bool]$recurse
    )

    [Collections.Specialized.OrderedDictionary]$outputs = [Ordered]@{
        'dotnet' = Test-Extension -Path $path -Extension 'sln' -Recurse $recurse
        'powershell' = Test-Extension -Path $path -Extension 'ps1' -Recurse $recurse
        'python' = Test-Extension -Path $path -Extension 'py' -Recurse $recurse
        'html' = Test-Extension -Path $path -Extension 'html' -Recurse $recurse
        'css' = Test-Extension -Path $path -Extension 'css' -Recurse $recurse
        'javascript' = Test-Extension -Path $path -Extension 'js' -Recurse $recurse
        'typescript' = Test-Extension -Path $path -Extension 'ts' -Recurse $recurse
        'json' = Test-Extension -Path $path -Extension 'json' -Recurse $recurse
        'yaml' = Test-Extension -Path $path -Extension 'yml' -Recurse $recurse
        'markdown' = Test-Extension -Path $path -Extension 'md' -Recurse $recurse
        'docker' = Test-Path 'Dockerfile'
        'nuget' = Test-Extension -Path $path -Extension 'nupkg' -Recurse $recurse
    }

    return $outputs
}

[string[]]$pathList = Get-List -Value $paths
$pathList | ForEach-Object { Write-Verbose "Path: $_" }

[Collections.Specialized.OrderedDictionary]$outputs = Get-GitHubOutput -Path $pathList -Recurse $recurse

Write-GitHubOutput -OutputList $outputs
