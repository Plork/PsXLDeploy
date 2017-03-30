function Start-XLDGarbageCollection
{
    <#
            .SYNOPSIS
            Runs the garbage collector on the repository.

            .EXAMPLE
            Start-XLDGarbageCollection

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param()

    Invoke-XLDRestMethod -Resource 'server/gc' -Method Post
}
