[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]$paths = '*,Source/*'
)

function Test-Extension
{
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$directoryPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$extension
    )

    foreach ($path in $directoryPath)
    {
        if (Test-Path "$(Join-Path $path '*').$extension")
        {
            return $true
        }
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
        [string[]]$directoryPath
    )

    [Collections.Specialized.OrderedDictionary]$outputs = [Ordered]@{
        'dotnet' = Test-Extension -DirectoryPath $directoryPath -Extension 'sln'
        'powershell' = Test-Extension -DirectoryPath $directoryPath -Extension 'ps1'
        'python' = Test-Extension -DirectoryPath $directoryPath -Extension 'py'
        'html' = Test-Extension -DirectoryPath $directoryPath -Extension 'html'
        'css' = Test-Extension -DirectoryPath $directoryPath -Extension 'css'
        'javascript' = Test-Extension -DirectoryPath $directoryPath -Extension 'js'
        'typescript' = Test-Extension -DirectoryPath $directoryPath -Extension 'ts'
        'json' = Test-Extension -DirectoryPath $directoryPath -Extension 'json'
        'yaml' = Test-Extension -DirectoryPath $directoryPath -Extension 'yml'
        'markdown' = Test-Extension -DirectoryPath $directoryPath -Extension 'md'
        'docker' = Test-Path 'Dockerfile'
        'nuget' = Test-Extension -DirectoryPath $directoryPath -Extension 'nupkg'
    }

    return $outputs
}

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/WriteGitHubOutput.ps1

[string[]]$pathList = $paths.Split([char[]]@(',', ' ', "`n", "`r"), [StringSplitOptions]::RemoveEmptyEntries)
[Collections.Specialized.OrderedDictionary]$outputs = Get-GitHubOutput -DirectoryPath $pathList

Write-GitHubOutput -OutputList $outputs
