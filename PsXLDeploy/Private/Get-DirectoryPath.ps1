function Get-DirectoryPath
{
    [cmdletbinding()]
    [OutputType([string])]
    param
    (
        [parameter(Mandatory)]
        [string]$RepositoryId
    )

    $pathArray = $RepositoryId.split('/')
    If ($pathArray.length -gt 2)
    {
        return $pathArray[0..($pathArray.count -2)] -join '/'
    }
    Else
    {
        return $pathArray[0]
    }
}
