function Write-GitHubOutput
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Collections.Specialized.OrderedDictionary]$outputList
    )

    $outputList
    [string[]]$output = $outputList.GetEnumerator() | ForEach-Object {
        $key = $_.Key
        $value = $_.Value

        if (!($value -is [Array]))
        {
            Write-Output "$key=$value"
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
