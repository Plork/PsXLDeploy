function New-XLDRepositoryQuery
{
    <#
            .SYNOPSIS
            Retrieves configuration items by way of a query.

            .DESCRIPTION
            Retrieves configuration items by way of a query. All parameters are optional.

            .PARAMETER type
            the type of the CI

            .PARAMETER parent
            the parent ID of the CI. If set, only the direct children of this CI are searched.

            .PARAMETER ancestor
            the ancestor ID of the CI. If set, only the subtree of this CI is searched.

            .PARAMETER namePattern
            a search pattern for the name. This is like the SQL "LIKE" pattern: the character '%'
            represents any string of zero or more characters, and the character '_' (underscore)
            represents any single character. Any literal use of these two characters must be
            escaped with a backslash ('\'). Consequently, any literal instance of a backslash
            must also be escaped, resulting in a double backslash ('\\').

            .PARAMETER lastModifiedBefore
            look for CIs modified before this date.

            .PARAMETER lastModifiedAfter
            look for CIs modified after this date.

            .PARAMETER page
            the desired page, in case of a paged query.

            .PARAMETER resultsPerPage
            the page size, or -1 for no paging.

            .OUTPUTS
            a list of CIs

            .EXAMPLE
            New-XLDRepositoryQuery -type overthere.CifsHost -Parent 'Infrastructure/Folder' -namePattern Win%

            .EXAMPLE
            Add-EnvironmentMember -environmentId 'Environment/Env' -members (New-XLDRepositoryQuery -type overthere.CifsHost -Parent 'Infrastructure/Folder' -namePattern Win%)

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [cmdletbinding()]
    [OutputType([string])]
    param(
        [ValidateSet('overthere.CifsHost','overthere.SSHHost','udm.Environment','udm.Dictionary','core.Directory','iis.Server')]
        [string]$type,

        [string]$parent,

        [string]$ancestor,

        [string]$namePattern,

        [datetime]$lastModifiedBefore,

        [datetime]$lastModifiedAfter,

        [int]$page,

        [int]$resultsPerPage
    )

    $uriParams = @{}
    foreach($psbp in $PSBoundParameters.GetEnumerator())
    {
        Write-Verbose -Message ('Key={0} Value={1}' -f $psbp.Key, $psbp.Value)
        $uriParams[$psbp.Key] = $psbp.Value
    }

    $Response = Invoke-XLDRestMethod -Resource 'repository/query' -UriParams $uriParams

    return $Response.list.ci | Select-Object -ExpandProperty ref
}
