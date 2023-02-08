using namespace System.Collections.Specialized

function Get-List
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$value,

        [switch]$withoutConnma
    )

    [char[]]$separator = @(' ', "`n", "`r")

    if (!$withoutConnma)
    {
        $separator += ','
    }

    return $value.Split($separator, [StringSplitOptions]::RemoveEmptyEntries)
}

function Get-NonNullProperty
{
    [CmdletBinding()]
    [OutputType([OrderedDictionary])]
    param (
        [OrderedDictionary]$value
    )

    [OrderedDictionary]$dictionary = [Ordered] @{}
    $value.GetEnumerator() | Where-Object { $null -ne $_.Value } | ForEach-Object { $dictionary.Add($_.Key, $_.Value) }

    return $dictionary
}
