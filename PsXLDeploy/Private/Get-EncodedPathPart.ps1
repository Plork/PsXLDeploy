function Get-EncodedPathPart()
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [string]$PartialPath
    )

    PROCESS
    {
        return ($PartialPath -split '/' | ForEach-Object -Process {
                [uri]::EscapeDataString($_)
        }) -join '/'
    }
}
