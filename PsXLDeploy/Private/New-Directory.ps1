function New-Directory
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Directory
    )
    $ConfigurationItem = New-ConfigurationItem -repositoryid $Directory -type 'core.Directory'

    Write-Verbose -Message ("Creating folder '{0}'." -f $Directory)

    $Resource = 'repository/ci/{0}' -f $Directory
    $Response = Invoke-XLDRestMethod -Resource $Resource -Method POST -Body $ConfigurationItem

    return $Response
}
