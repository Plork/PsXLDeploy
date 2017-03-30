function Test-ValidForTags
{
    param
    (
        [parameter(Mandatory)]
        [string]$RepositoryId
    )

    If ($RepositoryId.StartsWith('Environments/', 'InvariantCultureIgnoreCase'))
    {
        return $false
    }
    return $true
}
