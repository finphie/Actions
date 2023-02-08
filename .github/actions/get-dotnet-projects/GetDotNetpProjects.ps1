[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$solutionName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$projects,

    [ValidateScript({ Test-Path $_ -PathType Leaf }, ErrorMessage='"{0}" does not exist.')]
    [string]$settingsFilePath = 'default.json'
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/IO.ps1
. $rootPath/Utility.ps1
. $rootPath/WriteGitHubOutput.ps1

function Get-GitHubOutput
{
    [CmdletBinding()]
    [OutputType([Collections.Specialized.OrderedDictionary])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [hashtable]$settings,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [string[]]$projectList
    )

    [OrderedDictionary[]]$projects = @()

    foreach ($project in $projectList)
    {
        [string]$projectName, [string]$platform = $project -Split ','

        # 不明なプラットフォームの場合
        if ($platform -eq '')
        {
            Write-Verbose "Unknown platform: $projectName"
            continue
        }

        $platform = $platform.ToLowerInvariant()

        if (!$settings.ContainsKey($platform))
        {
            Write-Error "`"$platform`" is invalid."
            return
        }

        $elements = $settings[$platform]

        foreach ($element in $elements)
        {
            [Collections.Specialized.OrderedDictionary]$output = [Ordered]@{
                'project' = $projectName
                'os' = $element['os']
                'architecture' = $element['architecture']
                'target-platform-identifier' = $element['target-platform-identifier']
                'target-platform-version' = $element['target-platform-version']
                'workload-restore' = $element['workload-restore']
                'runs-on' = $element['runs-on']
            }

            $projects += Get-NonNullProperty -Value $output
        }
    }

    [Collections.Specialized.OrderedDictionary]$outputs = [Ordered]@{
        'projects' = [Ordered]@{
            'include' = $projects
        }
    }

    return $outputs
}

Write-Verbose "SolutionName: $solutionName"

[hashtable]$settings = Get-JsonFile -Path $settingsFilePath
[string[]]$projectList = Get-List -Value $projects -WithoutConnma | Where-Object { $_.StartsWith($solutionName) }

[Collections.Specialized.OrderedDictionary]$outputs = Get-GitHubOutput -Settings $settings -ProjectList $projectList
Write-GitHubOutput -OutputList $outputs -Json
