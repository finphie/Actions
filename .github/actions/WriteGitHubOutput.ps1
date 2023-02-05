using namespace System.Diagnostics.CodeAnalysis

function Write-GitHubOutput
{
    [SuppressMessage('PSReviewUnusedParameter', 'json', Justification = '誤検知')]
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Collections.Specialized.OrderedDictionary]$outputList,

        [switch]$json
    )

    [string[]]$output = $outputList.GetEnumerator() | ForEach-Object {
        [string]$key = $_.Key
        $value = $_.Value

        if ($value -isnot [Array])
        {
            if ($value -is [string] -and $value -eq '')
            {
                return
            }

            Write-Output "$key=$value"
            return
        }

        if ($value.Count -eq 0)
        {
            return
        }

        if ($json)
        {
            [string]$values = $value | ConvertTo-Json -AsArray -Compress

            Write-Output "$key=$values"
            return
        }

        Write-Output "$key<<EOF"
        Write-Output $value
        Write-Output 'EOF'
    }

    $output | ForEach-Object { Write-Verbose $_ }

    if ($Env:GITHUB_ACTIONS)
    {
        Write-Verbose 'Set GITHUB_OUTPUT'
        $output | Out-File $Env:GITHUB_OUTPUT -Append
    }
}
