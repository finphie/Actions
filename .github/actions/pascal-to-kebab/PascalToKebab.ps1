[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$text
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/WriteGitHubOutput.ps1

function PascalToKebab
{
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$text
    )

    [string]$pascalText = $text.Trim()
    [string]$lowerText = $pascalText.ToLowerInvariant()

    Write-Verbose "Text: `"$text`""
    Write-Verbose "Length: $($text.Length)"
    Write-Verbose "PascalText: `"$pascalText`""
    Write-Verbose "LowerText: `"$lowerText`""

    [string]$kebabText = ''

    # 元の文字列と小文字にした文字列で比較を行い、異なる文字の場合は'-'をその文字の前に追加する。
    # 最初の一文字は、'-'を追加する必要がないのでスキップする。
    foreach ($value in [Linq.Enumerable]::Skip([Linq.Enumerable]::Zip($pascalText, $lowerText), 1))
    {
        if ($value[0] -cne $value[1])
        {
            $kebabText += '-'
        }

        $kebabText += $value[1]
    }

    # 最初の一文字を結合する。
    $kebabText = $lowerText[0] + $kebabText

    return $kebabText
}

function Get-GitHubOutput
{
    [CmdletBinding()]
    [OutputType([Collections.Specialized.OrderedDictionary])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$text
    )

    [Collections.Specialized.OrderedDictionary]$outputs = [Ordered]@{
        'text' = PascalToKebab $text
    }

    return $outputs
}

[Collections.Specialized.OrderedDictionary]$outputs = Get-GitHubOutput -Text $text
Write-GitHubOutput -OutputList $outputs
