[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$solutionName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$projects
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/Utility.ps1
. $rootPath/WriteGitHubOutput.ps1

function Get-GitHubOutput
{
    [CmdletBinding()]
    [OutputType([Collections.Specialized.OrderedDictionary])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [string[]]$projectList
    )

    [Collections.Specialized.OrderedDictionary]$outputs = [Ordered]@{
        'console' =  @()
        'windows' =  @()
        'android' =  @()
        'server' =  @()
        'browser' =  @()
    }

    foreach ($project in $projectList)
    {
        $projectName, $platform = $project -Split ','

        # 不明なプラットフォームの場合
        if ($platform -eq '')
        {
            Write-Verbose "Unknown platform: $projectName"
            continue
        }

        if ($platform -eq 'AspNet')
        {
            $outputs['server'] += $projectName
        }
        elseif ($platform -eq 'BlazorWebAssembly')
        {
            $outputs['browser'] += $projectName
        }
        else
        {
            $outputs[$platform] += $projectName
        }
    }

    return $outputs
}

Write-Verbose "SolutionName: $solutionName"
[string[]]$projectList = Get-List -Value $projects -WithoutConnma | Where-Object { $_.StartsWith($solutionName) }

[Collections.Specialized.OrderedDictionary]$outputs = Get-GitHubOutput -ProjectList $projectList
Write-GitHubOutput -OutputList $outputs -Json
